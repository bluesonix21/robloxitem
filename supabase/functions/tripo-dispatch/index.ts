import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { createAdminClient } from "../_shared/supabase.ts";
import { createTripoTask } from "../_shared/tripo.ts";
import { logJobEvent } from "../_shared/jobs.ts";
import { refundJobCredits } from "../_shared/credits.ts";

interface AiJob {
  id: string;
  user_id: string;
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

function buildPreviewPayload(requestPayload: Record<string, unknown> | null) {
  const payload = requestPayload ?? {};
  const tripo = typeof payload.tripo === "object" && payload.tripo !== null
    ? (payload.tripo as Record<string, unknown>)
    : {};
  const preview = typeof tripo.preview === "object" && tripo.preview !== null
    ? (tripo.preview as Record<string, unknown>)
    : (typeof payload.preview === "object" && payload.preview !== null
      ? (payload.preview as Record<string, unknown>)
      : payload);

  const prompt = typeof preview.prompt === "string"
    ? preview.prompt
    : (typeof payload.prompt === "string" ? payload.prompt : "");
  if (!prompt) {
    throw new Error("prompt is required in request_payload");
  }

  return {
    ...preview,
    type: typeof preview.type === "string" ? preview.type : "text_to_model",
    prompt
  };
}

serve(async (req) => {
  const optionsResponse = handleOptions(req);
  if (optionsResponse) return optionsResponse;

  if (req.method !== "POST") {
    return errorResponse("Method not allowed", 405);
  }

  let body: Record<string, unknown> = {};
  try {
    body = await req.json();
  } catch (_err) {
    return errorResponse("Invalid JSON body", 400);
  }

  const jobId = typeof body.job_id === "string" ? body.job_id : "";
  if (!jobId) {
    return errorResponse("job_id is required", 400);
  }

  const auth = await authenticateRequest(req);
  if (!auth.isInternal && !auth.userId) {
    return errorResponse("Unauthorized", 401);
  }

  const admin = createAdminClient();
  const { data: job, error } = await admin
    .from("ai_jobs")
    .select("id, user_id, stage, status, provider, provider_task_id, request_payload, result_payload")
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

  if (job.stage !== "PREVIEW") {
    return errorResponse("Job stage is not PREVIEW", 409, { stage: job.stage });
  }

  if (job.status !== "QUEUED" && job.status !== "FAILED") {
    return jsonResponse({ status: job.status, message: "Job already in progress" }, 200);
  }

  let previewPayload: Record<string, unknown>;
  try {
    previewPayload = buildPreviewPayload(job.request_payload ?? {});
  } catch (err) {
    return errorResponse(err instanceof Error ? err.message : "Invalid payload", 400);
  }

  try {
    const tripoApiKey = await getAppSetting(admin, "tripo_api_key");
    const taskId = await createTripoTask(previewPayload, tripoApiKey);
    const resultPayload = {
      ...(job.result_payload ?? {}),
      preview_task_id: taskId,
      preview_request: previewPayload
    };

    const { error: updateError } = await admin
      .from("ai_jobs")
      .update({
        status: "IN_PROGRESS",
        provider_task_id: taskId,
        result_payload: resultPayload,
        started_at: new Date().toISOString()
      })
      .eq("id", job.id);

    if (updateError) {
      return errorResponse("Failed to update job", 500, { detail: updateError.message });
    }

    await logJobEvent(admin, job.id, job.user_id, "PREVIEW", "IN_PROGRESS", taskId, {
      request: previewPayload
    });

    return jsonResponse({ job_id: job.id, task_id: taskId, status: "IN_PROGRESS", stage: "PREVIEW" });
  } catch (err) {
    const message = err instanceof Error ? err.message : "Tripo preview failed";
    await admin
      .from("ai_jobs")
      .update({ status: "FAILED", error_message: message })
      .eq("id", job.id);

    await refundJobCredits(admin, job.id);
    await logJobEvent(admin, job.id, job.user_id, "PREVIEW", "FAILED", job.provider_task_id ?? null, {
      error: message
    });

    return errorResponse(message, 500);
  }
});
