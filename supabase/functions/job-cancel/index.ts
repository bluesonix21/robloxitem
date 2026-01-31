import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { createUserClient } from "../_shared/supabase.ts";

serve(async (req) => {
  const optionsResponse = handleOptions(req);
  if (optionsResponse) return optionsResponse;

  if (req.method !== "POST") {
    return errorResponse("Method not allowed", 405);
  }

  const auth = await authenticateRequest(req);
  if (!auth.userId) {
    return errorResponse("Unauthorized", 401);
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

  const authHeader = req.headers.get("Authorization");
  const userClient = createUserClient(authHeader);

  const { error } = await userClient.rpc("cancel_ai_job", { job_id: jobId });
  if (error) {
    return errorResponse("Failed to cancel job", 500, { detail: error.message });
  }

  return jsonResponse({ job_id: jobId, status: "CANCELLED" });
});
