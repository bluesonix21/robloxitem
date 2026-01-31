import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { createUserClient } from "../_shared/supabase.ts";

serve(async (req) => {
  const optionsResponse = handleOptions(req);
  if (optionsResponse) return optionsResponse;

  if (req.method !== "GET") {
    return errorResponse("Method not allowed", 405);
  }

  const auth = await authenticateRequest(req);
  if (!auth.userId) {
    return errorResponse("Unauthorized", 401);
  }

  const jobId = new URL(req.url).searchParams.get("job_id");
  if (!jobId) {
    return errorResponse("job_id is required", 400);
  }

  const authHeader = req.headers.get("Authorization");
  const userClient = createUserClient(authHeader);

  const { data: job, error: jobError } = await userClient
    .from("ai_jobs")
    .select("id, user_id, asset_id, stage, status, provider, provider_task_id, request_payload, result_payload, error_message, credit_cost, created_at, updated_at")
    .eq("id", jobId)
    .maybeSingle();

  if (jobError) {
    return errorResponse("Failed to fetch job", 500, { detail: jobError.message });
  }
  if (!job) {
    return errorResponse("Job not found", 404);
  }

  const { data: events } = await userClient
    .from("ai_job_events")
    .select("id, stage, status, provider_task_id, payload, created_at")
    .eq("job_id", jobId)
    .order("created_at", { ascending: true });

  return jsonResponse({ job, events: events ?? [] });
});
