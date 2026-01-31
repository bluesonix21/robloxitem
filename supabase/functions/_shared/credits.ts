import { SupabaseClient } from "@supabase/supabase-js";

export async function refundJobCredits(admin: SupabaseClient, jobId: string) {
  await admin.rpc("refund_job_credits", { job_id: jobId });
}
