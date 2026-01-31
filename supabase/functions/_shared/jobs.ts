import { SupabaseClient } from "@supabase/supabase-js";

export async function logJobEvent(
  admin: SupabaseClient,
  jobId: string,
  userId: string,
  stage: string,
  status: string,
  providerTaskId: string | null,
  payload: Record<string, unknown>
) {
  await admin.from("ai_job_events").insert({
    job_id: jobId,
    user_id: userId,
    stage,
    status,
    provider_task_id: providerTaskId,
    payload
  });
}
