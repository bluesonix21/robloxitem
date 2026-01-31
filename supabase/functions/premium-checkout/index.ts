import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { createAdminClient } from "../_shared/supabase.ts";
import { getEnv } from "../_shared/env.ts";

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

  const planId = typeof body.plan_id === "string" ? body.plan_id : "monthly";

  const envUrl = getEnv("PREMIUM_CHECKOUT_URL", false);
  if (envUrl) {
    return jsonResponse({ checkout_url: envUrl, plan_id: planId });
  }

  const admin = createAdminClient();
  const { data: setting, error } = await admin
    .from("app_settings")
    .select("value")
    .eq("key", "premium_checkout_url")
    .maybeSingle();

  if (error) {
    return errorResponse("Failed to fetch checkout url", 500, { detail: error.message });
  }

  if (!setting?.value) {
    return errorResponse("Premium checkout not configured", 501);
  }

  return jsonResponse({ checkout_url: setting.value, plan_id: planId });
});
