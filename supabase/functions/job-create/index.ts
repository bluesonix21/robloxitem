import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { createAdminClient, createUserClient } from "../_shared/supabase.ts";

function extractPayload(body: Record<string, unknown>): Record<string, unknown> {
  if (typeof body.request_payload === "object" && body.request_payload !== null) {
    return body.request_payload as Record<string, unknown>;
  }
  return body;
}

function selectProvider(payload: Record<string, unknown>): string {
  const provider = typeof payload.provider === "string" ? payload.provider.toUpperCase() : "";
  if (provider === "TRIPO" || provider === "MESHY") {
    return provider;
  }

  const requiresRig = payload.requires_rig === true || payload.auto_rig === true;
  const category = typeof payload.category === "string" ? payload.category.toLowerCase() : "";
  if (requiresRig || category === "avatar" || category === "character") {
    return "TRIPO";
  }

  return "MESHY";
}

function validatePrompt(payload: Record<string, unknown>) {
  const preview = typeof payload.preview === "object" && payload.preview !== null
    ? (payload.preview as Record<string, unknown>)
    : null;
  const prompt = preview && typeof preview.prompt === "string"
    ? preview.prompt
    : (typeof payload.prompt === "string" ? payload.prompt : "");
  if (!prompt) {
    throw new Error("prompt is required");
  }
}

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

  const admin = createAdminClient();
  const { data: settings } = await admin
    .from("app_settings")
    .select("value")
    .eq("key", "rate_job_create_per_minute")
    .maybeSingle();

  const maxPerMinute = settings?.value ? Number(settings.value) : 5;
  const { data: rateAllowed, error: rateError } = await admin.rpc("check_rate_limit", {
    key: `job-create:${auth.userId}`,
    window_seconds: 60,
    max_requests: Number.isFinite(maxPerMinute) && maxPerMinute > 0 ? maxPerMinute : 5
  });

  if (rateError) {
    return errorResponse("Rate limit error", 500, { detail: rateError.message });
  }
  if (!rateAllowed) {
    return errorResponse("Rate limit exceeded", 429);
  }

  let body: Record<string, unknown> = {};
  try {
    body = await req.json();
  } catch (_err) {
    return errorResponse("Invalid JSON body", 400);
  }

  const payload = extractPayload(body);
  try {
    validatePrompt(payload);
  } catch (err) {
    return errorResponse(err instanceof Error ? err.message : "Invalid prompt", 400);
  }

  const provider = selectProvider(payload);

  const createAsset = typeof body.create_asset === "boolean" ? body.create_asset : true;
  const assetId = typeof body.asset_id === "string" ? body.asset_id : null;
  const assetTitle = typeof body.asset_title === "string" ? body.asset_title : null;
  const assetDescription = typeof body.asset_description === "string" ? body.asset_description : null;

  const authHeader = req.headers.get("Authorization");
  const userClient = createUserClient(authHeader);

  const { data, error } = await userClient.rpc("create_ai_job_with_credits", {
    request_payload: payload,
    create_asset: createAsset,
    asset_title: assetTitle,
    asset_description: assetDescription,
    asset_id: assetId,
    provider
  });

  if (error || !data || !Array.isArray(data) || data.length === 0) {
    const message = error?.message?.includes("insufficient credits")
      ? "Insufficient credits"
      : (error?.message ?? "Failed to create job");
    const status = error?.message?.includes("insufficient credits") ? 402 : 500;
    return errorResponse(message, status, { detail: error?.message });
  }

  const record = data[0] as Record<string, unknown>;
  return jsonResponse({
    job_id: record.job_id,
    asset_id: record.asset_id,
    credit_cost: record.credit_cost,
    balance: record.balance
  });
});
