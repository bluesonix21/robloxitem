import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { createAdminClient } from "../_shared/supabase.ts";
import {
  createRemeshTask,
  createTextTo3DTask,
  getRemeshTask,
  getTextTo3DTask,
  MeshyTask
} from "../_shared/meshy.ts";
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

function getRefineConfig(payload: Record<string, unknown>) {
  const refine = typeof payload.refine === "object" && payload.refine !== null
    ? (payload.refine as Record<string, unknown>)
    : {};
  const enabled = typeof refine.enabled === "boolean" ? refine.enabled : true;
  return {
    enabled,
    payload: {
      mode: "refine",
      enable_pbr: typeof refine.enable_pbr === "boolean" ? refine.enable_pbr : true,
      texture_prompt: typeof refine.texture_prompt === "string" ? refine.texture_prompt : undefined,
      texture_image_url: typeof refine.texture_image_url === "string" ? refine.texture_image_url : undefined,
      art_style: typeof refine.art_style === "string" ? refine.art_style : undefined,
      ai_model: typeof refine.ai_model === "string" ? refine.ai_model : undefined,
      negative_prompt: typeof refine.negative_prompt === "string" ? refine.negative_prompt : undefined,
      seed: typeof refine.seed === "number" ? refine.seed : undefined
    }
  };
}

function getRemeshConfig(payload: Record<string, unknown>) {
  const remesh = typeof payload.remesh === "object" && payload.remesh !== null
    ? (payload.remesh as Record<string, unknown>)
    : {};
  const enabled = typeof remesh.enabled === "boolean" ? remesh.enabled : true;
  const targetFormat = typeof remesh.target_format === "string"
    ? remesh.target_format
    : (Array.isArray(remesh.target_formats) && typeof remesh.target_formats[0] === "string"
      ? String(remesh.target_formats[0])
      : "fbx");
  const targetPolycount = typeof remesh.target_polycount === "number"
    ? remesh.target_polycount
    : (typeof payload.target_polycount === "number" ? payload.target_polycount : 3500);
  const topology = typeof remesh.topology === "string" ? remesh.topology : "triangle";

  return {
    enabled,
    payload: {
      target_format: targetFormat,
      target_polycount: targetPolycount,
      topology,
      origin_at: typeof remesh.origin_at === "string" ? remesh.origin_at : undefined,
      resize_height: typeof remesh.resize_height === "number" ? remesh.resize_height : undefined
    }
  };
}

function pickTextureUrl(textureUrls: Record<string, string> | undefined, keys: string[]) {
  if (!textureUrls) return null;
  for (const key of keys) {
    if (textureUrls[key]) return textureUrls[key];
  }
  return null;
}

function shouldStoreAssets(payload: Record<string, unknown> | null) {
  if (!payload) return true;
  if (payload.store_assets === false) return false;
  return true;
}

async function updateAssetFromTask(admin: ReturnType<typeof createAdminClient>, job: AiJob, task: MeshyTask) {
  if (!job.asset_id) return;

  const meshUrl = task.model_urls?.fbx ?? task.model_urls?.glb ?? null;
  const textureUrl = pickTextureUrl(task.texture_urls, ["albedo", "base_color", "baseColor", "diffuse"]);
  const metalnessUrl = pickTextureUrl(task.texture_urls, ["metalness", "metallic"]);
  const roughnessUrl = pickTextureUrl(task.texture_urls, ["roughness"]);
  const normalUrl = pickTextureUrl(task.texture_urls, ["normal"]);

  const updatePayload: Record<string, string> = {
    source_job_id: job.id
  };
  if (meshUrl) updatePayload.mesh_url = meshUrl;
  if (textureUrl) updatePayload.texture_url = textureUrl;
  if (metalnessUrl) updatePayload.pbr_metalness_url = metalnessUrl;
  if (roughnessUrl) updatePayload.pbr_roughness_url = roughnessUrl;
  if (normalUrl) updatePayload.pbr_normal_url = normalUrl;

  if (shouldStoreAssets(job.request_payload)) {
    try {
      const stored = await persistRemoteAssets(admin, job.user_id, job.asset_id, {
        mesh_url: meshUrl,
        texture_url: textureUrl,
        pbr_metalness_url: metalnessUrl,
        pbr_roughness_url: roughnessUrl,
        pbr_normal_url: normalUrl
      });
      if (stored.mesh_storage_path) updatePayload.mesh_storage_path = stored.mesh_storage_path;
      if (stored.texture_storage_path) updatePayload.texture_storage_path = stored.texture_storage_path;
      if (stored.pbr_metalness_storage_path) {
        updatePayload.pbr_metalness_storage_path = stored.pbr_metalness_storage_path;
      }
      if (stored.pbr_roughness_storage_path) {
        updatePayload.pbr_roughness_storage_path = stored.pbr_roughness_storage_path;
      }
      if (stored.pbr_normal_storage_path) updatePayload.pbr_normal_storage_path = stored.pbr_normal_storage_path;
    } catch (err) {
      await admin
        .from("ai_jobs")
        .update({ error_message: `Storage import failed: ${err instanceof Error ? err.message : "unknown"}` })
        .eq("id", job.id);
    }
  }

  const { error } = await admin
    .from("assets")
    .update(updatePayload)
    .eq("id", job.asset_id);

  if (error) {
    await admin
      .from("ai_jobs")
      .update({
        error_message: `Asset update failed: ${error.message}`
      })
      .eq("id", job.id);
  }
}

async function handleFailure(admin: ReturnType<typeof createAdminClient>, job: AiJob, task: MeshyTask) {
  const errorMessage = task.message ?? "Meshy task failed";
  await admin
    .from("ai_jobs")
    .update({
      status: "FAILED",
      error_message: errorMessage,
      result_payload: mergeResult(job, { last_task: task }),
      completed_at: new Date().toISOString()
    })
    .eq("id", job.id);
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

  if (job.provider !== "MESHY") {
    return errorResponse("Unsupported provider", 400);
  }

  if (job.status === "SUCCEEDED" || job.status === "FAILED" || job.status === "CANCELLED") {
    return jsonResponse({ job_id: job.id, stage: job.stage, status: job.status });
  }

  if (!job.provider_task_id) {
    return errorResponse("provider_task_id missing for job", 409);
  }

  try {
    const meshyApiKey = await getAppSetting(admin, "meshy_api_key");
    let task: MeshyTask;
    if (job.stage === "REMESH") {
      task = await getRemeshTask(job.provider_task_id, meshyApiKey);
    } else {
      task = await getTextTo3DTask(job.provider_task_id, meshyApiKey);
    }

    if (task.status === "PENDING" || task.status === "IN_PROGRESS") {
      await admin
        .from("ai_jobs")
        .update({
          status: "IN_PROGRESS",
          result_payload: mergeResult(job, { last_task: task })
        })
        .eq("id", job.id);

      if (job.status !== "IN_PROGRESS") {
        await logJobEvent(admin, job.id, job.user_id, job.stage, "IN_PROGRESS", job.provider_task_id, {
          message: "Meshy task in progress"
        });
      }

      return jsonResponse({ job_id: job.id, stage: job.stage, status: "IN_PROGRESS" });
    }

    if (task.status === "FAILED") {
      await handleFailure(admin, job, task);
      await refundJobCredits(admin, job.id);
      await logJobEvent(admin, job.id, job.user_id, job.stage, "FAILED", job.provider_task_id, {
        message: task.message ?? "Meshy task failed"
      });
      return jsonResponse({ job_id: job.id, stage: job.stage, status: "FAILED" });
    }

    if (task.status === "SUCCEEDED") {
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

        const refineTaskId = await createTextTo3DTask({
          ...refineConfig.payload,
          preview_task_id: job.provider_task_id
        }, meshyApiKey);

        const resultPayload = mergeResult(job, {
          preview_result: task,
          refine_task_id: refineTaskId,
          refine_request: refineConfig.payload,
          last_task: task
        });

        await admin
          .from("ai_jobs")
          .update({
            stage: "REFINE",
            status: "IN_PROGRESS",
            provider_task_id: refineTaskId,
            result_payload: resultPayload
          })
          .eq("id", job.id);

        await logJobEvent(admin, job.id, job.user_id, "REFINE", "IN_PROGRESS", refineTaskId, {
          request: refineConfig.payload
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

        const remeshTaskId = await createRemeshTask({
          input_task_id: job.provider_task_id,
          ...remeshConfig.payload
        }, meshyApiKey);

        const resultPayload = mergeResult(job, {
          refine_result: task,
          remesh_task_id: remeshTaskId,
          remesh_request: remeshConfig.payload,
          last_task: task
        });

        await admin
          .from("ai_jobs")
          .update({
            stage: "REMESH",
            status: "IN_PROGRESS",
            provider_task_id: remeshTaskId,
            result_payload: resultPayload
          })
          .eq("id", job.id);

        await logJobEvent(admin, job.id, job.user_id, "REMESH", "IN_PROGRESS", remeshTaskId, {
          request: remeshConfig.payload
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
    const message = err instanceof Error ? err.message : "Meshy polling failed";
    await admin
      .from("ai_jobs")
      .update({
        status: "FAILED",
        error_message: message
      })
      .eq("id", job.id);

    return errorResponse(message, 500);
  }
});
