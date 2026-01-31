import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { createAdminClient } from "../_shared/supabase.ts";
import { createTripoTask, getTripoTask, TripoTask } from "../_shared/tripo.ts";
import { logJobEvent } from "../_shared/jobs.ts";
import { refundJobCredits } from "../_shared/credits.ts";
import { persistRemoteAssets } from "../_shared/storage.ts";

interface AiJob {
  id: string;
  user_id: string;
  asset_id: string | null;
  stage: string;
  status: string;
  provider: string;
  provider_task_id: string | null;
  request_payload: Record<string, unknown> | null;
  result_payload: Record<string, unknown> | null;
}

async function getAppSetting(
  admin: ReturnType<typeof createAdminClient>,
  key: string
): Promise<string | null> {
  const { data, error } = await admin
    .from("app_settings")
    .select("value")
    .eq("key", key)
    .maybeSingle();

  if (error) {
    console.error("app_settings lookup failed", error);
    return null;
  }

  return typeof data?.value === "string" ? data.value : null;
}

function mergeResult(job: AiJob, patch: Record<string, unknown>) {
  return { ...(job.result_payload ?? {}), ...patch };
}

function shouldStoreAssets(payload: Record<string, unknown> | null) {
  if (!payload) return true;
  if (payload.store_assets === false) return false;
  return true;
}

function getTripoConfig(payload: Record<string, unknown>) {
  const tripo = typeof payload.tripo === "object" && payload.tripo !== null
    ? (payload.tripo as Record<string, unknown>)
    : {};
  return {
    preview: typeof tripo.preview === "object" && tripo.preview !== null ? (tripo.preview as Record<string, unknown>) : payload,
    refine: typeof tripo.refine === "object" && tripo.refine !== null ? (tripo.refine as Record<string, unknown>) : payload.refine as Record<string, unknown> | undefined,
    remesh: typeof tripo.remesh === "object" && tripo.remesh !== null ? (tripo.remesh as Record<string, unknown>) : payload.remesh as Record<string, unknown> | undefined
  };
}

function getRefineConfig(payload: Record<string, unknown>) {
  const config = getTripoConfig(payload).refine ?? {};
  const enabled = typeof config.enabled === "boolean" ? config.enabled : true;
  return { enabled, payload: config };
}

function getRemeshConfig(payload: Record<string, unknown>) {
  const config = getTripoConfig(payload).remesh ?? {};
  const enabled = typeof config.enabled === "boolean" ? config.enabled : true;
  const targetPolycount = typeof config.target_polycount === "number"
    ? config.target_polycount
    : (typeof payload.target_polycount === "number" ? payload.target_polycount : 3500);
  const format = typeof config.format === "string" ? config.format : "FBX";
  return { enabled, payload: { ...config, target_polycount: targetPolycount, format } };
}

function mapTripoStatus(status?: string) {
  if (!status) return "IN_PROGRESS";
  if (status === "queued" || status === "running") return "IN_PROGRESS";
  if (status === "success") return "SUCCEEDED";
  if (status === "cancelled") return "CANCELLED";
  return "FAILED";
}

async function updateAssetFromTask(admin: ReturnType<typeof createAdminClient>, job: AiJob, task: TripoTask) {
  if (!job.asset_id) return;
  const output = (task.output ?? {}) as Record<string, unknown>;
  const meshUrl = typeof output.pbr_model === "string"
    ? output.pbr_model
    : (typeof output.model === "string" ? output.model : (typeof output.base_model === "string" ? output.base_model : null));

  const updatePayload: Record<string, string> = {
    source_job_id: job.id
  };
  if (meshUrl) updatePayload.mesh_url = meshUrl;

  if (meshUrl && shouldStoreAssets(job.request_payload)) {
    try {
      const stored = await persistRemoteAssets(admin, job.user_id, job.asset_id, {
        mesh_url: meshUrl
      });
      if (stored.mesh_storage_path) updatePayload.mesh_storage_path = stored.mesh_storage_path;
    } catch (err) {
      await admin
        .from("ai_jobs")
        .update({ error_message: `Storage import failed: ${err instanceof Error ? err.message : "unknown"}` })
        .eq("id", job.id);
    }
  }

  await admin
    .from("assets")
    .update(updatePayload)
    .eq("id", job.asset_id);
}

serve(async (req) => {
  const optionsResponse = handleOptions(req);
  if (optionsResponse) return optionsResponse;

  if (req.method !== "GET" && req.method !== "POST") {
    return errorResponse("Method not allowed", 405);
  }

  let jobId = new URL(req.url).searchParams.get("job_id") ?? "";
  if (!jobId && req.method === "POST") {
    try {
      const body = await req.json();
      if (typeof body.job_id === "string") {
        jobId = body.job_id;
      }
    } catch (_err) {
      return errorResponse("Invalid JSON body", 400);
    }
  }

  if (!jobId) {
    return errorResponse("job_id is required", 400);
  }

  const auth = await authenticateRequest(req);
  if (!auth.isInternal && !auth.userId) {
    return errorResponse("Unauthorized", 401);
  }

  const admin = createAdminClient();
  if (!auth.isInternal && auth.userId) {
    const { data: settings } = await admin
      .from("app_settings")
      .select("value")
      .eq("key", "rate_poll_per_minute")
      .maybeSingle();

    const maxPerMinute = settings?.value ? Number(settings.value) : 30;
    const { data: rateAllowed, error: rateError } = await admin.rpc("check_rate_limit", {
      key: `poll:${auth.userId}`,
      window_seconds: 60,
      max_requests: Number.isFinite(maxPerMinute) && maxPerMinute > 0 ? maxPerMinute : 30
    });

    if (rateError) {
      return errorResponse("Rate limit error", 500, { detail: rateError.message });
    }
    if (!rateAllowed) {
      return errorResponse("Rate limit exceeded", 429);
    }
  }
  const { data: job, error } = await admin
    .from("ai_jobs")
    .select("id, user_id, asset_id, stage, status, provider, provider_task_id, request_payload, result_payload")
    .eq("id", jobId)
    .maybeSingle();

  if (error || !job) {
    return errorResponse("Job not found", 404);
  }

  if (!auth.isInternal && auth.userId !== job.user_id) {
    return errorResponse("Forbidden", 403);
  }

  if (job.provider !== "TRIPO") {
    return errorResponse("Unsupported provider", 400);
  }

  if (job.status === "SUCCEEDED" || job.status === "FAILED" || job.status === "CANCELLED") {
    return jsonResponse({ job_id: job.id, stage: job.stage, status: job.status });
  }

  if (!job.provider_task_id) {
    return errorResponse("provider_task_id missing for job", 409);
  }

  try {
    const tripoApiKey = await getAppSetting(admin, "tripo_api_key");
    const task = await getTripoTask(job.provider_task_id, tripoApiKey);
    const mappedStatus = mapTripoStatus(task.status);

    if (mappedStatus === "IN_PROGRESS") {
      await admin
        .from("ai_jobs")
        .update({
          status: "IN_PROGRESS",
          result_payload: mergeResult(job, { last_task: task })
        })
        .eq("id", job.id);

      if (job.status !== "IN_PROGRESS") {
        await logJobEvent(admin, job.id, job.user_id, job.stage, "IN_PROGRESS", job.provider_task_id, {
          message: "Tripo task in progress"
        });
      }

      return jsonResponse({ job_id: job.id, stage: job.stage, status: "IN_PROGRESS" });
    }

    if (mappedStatus === "FAILED") {
      await admin
        .from("ai_jobs")
        .update({
          status: "FAILED",
          error_message: typeof task.status === "string" ? `Tripo task ${task.status}` : "Tripo task failed",
          result_payload: mergeResult(job, { last_task: task }),
          completed_at: new Date().toISOString()
        })
        .eq("id", job.id);

      await refundJobCredits(admin, job.id);
      await logJobEvent(admin, job.id, job.user_id, job.stage, "FAILED", job.provider_task_id, {
        message: task.status ?? "failed"
      });
      return jsonResponse({ job_id: job.id, stage: job.stage, status: "FAILED" });
    }

    if (mappedStatus === "CANCELLED") {
      await admin
        .from("ai_jobs")
        .update({
          status: "CANCELLED",
          result_payload: mergeResult(job, { last_task: task }),
          completed_at: new Date().toISOString()
        })
        .eq("id", job.id);

      await refundJobCredits(admin, job.id);
      await logJobEvent(admin, job.id, job.user_id, job.stage, "CANCELLED", job.provider_task_id, {
        message: "cancelled"
      });
      return jsonResponse({ job_id: job.id, stage: job.stage, status: "CANCELLED" });
    }

    if (mappedStatus === "SUCCEEDED") {
      const payload = job.request_payload ?? {};
      if (job.stage === "PREVIEW") {
        const refineConfig = getRefineConfig(payload);
        if (!refineConfig.enabled) {
          await admin
            .from("ai_jobs")
            .update({
              status: "SUCCEEDED",
              result_payload: mergeResult(job, { preview_result: task, last_task: task }),
              completed_at: new Date().toISOString()
            })
            .eq("id", job.id);

          await logJobEvent(admin, job.id, job.user_id, "PREVIEW", "SUCCEEDED", job.provider_task_id, {
            preview_result: task
          });

          await updateAssetFromTask(admin, job, task);
          return jsonResponse({ job_id: job.id, stage: "PREVIEW", status: "SUCCEEDED" });
        }

        const existingRefineId = typeof (job.result_payload as Record<string, unknown> | null)?.refine_task_id === "string"
          ? String((job.result_payload as Record<string, unknown>).refine_task_id)
          : null;
        if (existingRefineId) {
          await admin
            .from("ai_jobs")
            .update({
              stage: "REFINE",
              status: "IN_PROGRESS",
              provider_task_id: existingRefineId
            })
            .eq("id", job.id);

          await logJobEvent(admin, job.id, job.user_id, "REFINE", "IN_PROGRESS", existingRefineId, {
            resumed: true
          });

          return jsonResponse({ job_id: job.id, stage: "REFINE", status: "IN_PROGRESS" });
        }

        const refinePayload = {
          ...refineConfig.payload,
          type: "refine_model",
          draft_model_task_id: job.provider_task_id
        };

        const refineTaskId = await createTripoTask(refinePayload, tripoApiKey);

        await admin
          .from("ai_jobs")
          .update({
            stage: "REFINE",
            status: "IN_PROGRESS",
            provider_task_id: refineTaskId,
            result_payload: mergeResult(job, {
              preview_result: task,
              refine_task_id: refineTaskId,
              refine_request: refinePayload,
              last_task: task
            })
          })
          .eq("id", job.id);

        await logJobEvent(admin, job.id, job.user_id, "REFINE", "IN_PROGRESS", refineTaskId, {
          request: refinePayload
        });

        return jsonResponse({ job_id: job.id, stage: "REFINE", status: "IN_PROGRESS" });
      }

      if (job.stage === "REFINE") {
        const remeshConfig = getRemeshConfig(payload);
        if (!remeshConfig.enabled) {
          await admin
            .from("ai_jobs")
            .update({
              status: "SUCCEEDED",
              result_payload: mergeResult(job, { refine_result: task, last_task: task }),
              completed_at: new Date().toISOString()
            })
            .eq("id", job.id);

          await logJobEvent(admin, job.id, job.user_id, "REFINE", "SUCCEEDED", job.provider_task_id, {
            refine_result: task
          });

          await updateAssetFromTask(admin, job, task);
          return jsonResponse({ job_id: job.id, stage: "REFINE", status: "SUCCEEDED" });
        }

        const existingRemeshId = typeof (job.result_payload as Record<string, unknown> | null)?.remesh_task_id === "string"
          ? String((job.result_payload as Record<string, unknown>).remesh_task_id)
          : null;
        if (existingRemeshId) {
          await admin
            .from("ai_jobs")
            .update({
              stage: "REMESH",
              status: "IN_PROGRESS",
              provider_task_id: existingRemeshId
            })
            .eq("id", job.id);

          await logJobEvent(admin, job.id, job.user_id, "REMESH", "IN_PROGRESS", existingRemeshId, {
            resumed: true
          });

          return jsonResponse({ job_id: job.id, stage: "REMESH", status: "IN_PROGRESS" });
        }

        const remeshPayload = {
          ...remeshConfig.payload,
          type: "convert_model",
          format: remeshConfig.payload.format ?? "FBX",
          face_limit: remeshConfig.payload.target_polycount,
          original_model_task_id: job.provider_task_id
        };

        const remeshTaskId = await createTripoTask(remeshPayload, tripoApiKey);

        await admin
          .from("ai_jobs")
          .update({
            stage: "REMESH",
            status: "IN_PROGRESS",
            provider_task_id: remeshTaskId,
            result_payload: mergeResult(job, {
              refine_result: task,
              remesh_task_id: remeshTaskId,
              remesh_request: remeshPayload,
              last_task: task
            })
          })
          .eq("id", job.id);

        await logJobEvent(admin, job.id, job.user_id, "REMESH", "IN_PROGRESS", remeshTaskId, {
          request: remeshPayload
        });

        return jsonResponse({ job_id: job.id, stage: "REMESH", status: "IN_PROGRESS" });
      }

      if (job.stage === "REMESH") {
        await admin
          .from("ai_jobs")
          .update({
            status: "SUCCEEDED",
            result_payload: mergeResult(job, { remesh_result: task, last_task: task }),
            completed_at: new Date().toISOString()
          })
          .eq("id", job.id);

        await logJobEvent(admin, job.id, job.user_id, "REMESH", "SUCCEEDED", job.provider_task_id, {
          remesh_result: task
        });

        await updateAssetFromTask(admin, job, task);
        return jsonResponse({ job_id: job.id, stage: "REMESH", status: "SUCCEEDED" });
      }
    }

    return errorResponse("Unhandled task status", 500);
  } catch (err) {
    const message = err instanceof Error ? err.message : "Tripo polling failed";
    await admin
      .from("ai_jobs")
      .update({
        status: "FAILED",
        error_message: message
      })
      .eq("id", job.id);

    await refundJobCredits(admin, job.id);
    return errorResponse(message, 500);
  }
});
