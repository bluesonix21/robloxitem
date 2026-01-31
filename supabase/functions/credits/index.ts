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

  const url = new URL(req.url);
  const limit = Number(url.searchParams.get("limit") ?? 20);
  const authHeader = req.headers.get("Authorization");
  const userClient = createUserClient(authHeader);

  const { data: account, error: accountError } = await userClient
    .from("credit_accounts")
    .select("user_id, balance, updated_at")
    .eq("user_id", auth.userId)
    .maybeSingle();

  if (accountError) {
    return errorResponse("Failed to fetch credit account", 500, { detail: accountError.message });
  }

  const { data: ledger, error: ledgerError } = await userClient
    .from("credit_ledger")
    .select("id, amount, reason, metadata, created_at, job_id")
    .eq("user_id", auth.userId)
    .order("created_at", { ascending: false })
    .limit(Number.isFinite(limit) && limit > 0 ? Math.min(limit, 100) : 20);

  if (ledgerError) {
    return errorResponse("Failed to fetch credit ledger", 500, { detail: ledgerError.message });
  }

  return jsonResponse({
    account: account ?? { user_id: auth.userId, balance: 0, updated_at: null },
    ledger: ledger ?? []
  });
});
