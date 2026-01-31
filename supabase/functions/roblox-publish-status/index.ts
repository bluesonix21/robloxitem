import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { createAdminClient } from "../_shared/supabase.ts";
import { getEnv } from "../_shared/env.ts";
import { getValidRobloxAccessToken } from "../_shared/roblox_oauth.ts";

interface OperationResponse {
  done?: boolean;
  response?: Record<string, unknown>;
  error?: { message?: string } | Record<string, unknown>;
  [key: string]: unknown;
}

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

  const publishJobId = new URL(req.url).searchParams.get("publish_job_id");
  if (!publishJobId) {
    return errorResponse("publish_job_id is required", 400);
  }

  const admin = createAdminClient();
  const { data: publishJob } = await admin
    .from("roblox_publish_jobs")
    .select("id, user_id, status, operation_id, operation_path")
    .eq("id", publishJobId)
    .maybeSingle();

  if (!publishJob) {
    return errorResponse("Publish job not found", 404);
  }
  if (publishJob.user_id !== auth.userId) {
    return errorResponse("Forbidden", 403);
  }
  if (!publishJob.operation_id && !publishJob.operation_path) {
    return errorResponse("Operation id missing", 409);
  }

  const operationId = publishJob.operation_id ?? publishJob.operation_path?.split("/").pop() ?? "";
  if (!operationId) {
    return errorResponse("Operation id missing", 409);
  }

  const oauthToken = await getValidRobloxAccessToken(admin, auth.userId);
  const robloxToken = oauthToken?.accessToken ?? getEnv("ROBLOX_OAUTH_TOKEN", false);
  if (!robloxToken) {
    return errorResponse("Missing Roblox OAuth token", 401);
  }
  const tokenType = oauthToken?.tokenType ?? "Bearer";
  const operationResponse = await fetch(`https://apis.roblox.com/assets/v1/operations/${operationId}`, {
    headers: { Authorization: `${tokenType} ${robloxToken}` }
  });

  const responseText = await operationResponse.text();
  let responseJson: OperationResponse = {};
  try {
    responseJson = responseText ? JSON.parse(responseText) : {};
  } catch (_err) {
    responseJson = { error: { message: responseText } };
  }

  if (!operationResponse.ok) {
    await admin
      .from("roblox_publish_jobs")
      .update({
        status: "FAILED",
        error_message: String(responseJson.error?.message ?? "Roblox operation failed"),
        result_payload: responseJson
      })
      .eq("id", publishJob.id);

    return errorResponse("Roblox operation failed", operationResponse.status, { detail: responseJson });
  }

  if (responseJson.done) {
    if (responseJson.error) {
      await admin
        .from("roblox_publish_jobs")
        .update({
          status: "FAILED",
          error_message: String(responseJson.error?.message ?? "Roblox publish failed"),
          result_payload: responseJson
        })
        .eq("id", publishJob.id);

      return errorResponse("Roblox publish failed", 500, { detail: responseJson });
    }

    const robloxAssetId = typeof responseJson.response?.assetId === "number"
      ? responseJson.response?.assetId
      : (typeof responseJson.response?.assetId === "string" ? Number(responseJson.response?.assetId) : null);

    await admin
      .from("roblox_publish_jobs")
      .update({
        status: "PUBLISHED",
        roblox_asset_id: robloxAssetId ?? undefined,
        result_payload: responseJson
      })
      .eq("id", publishJob.id);

    return jsonResponse({
      publish_job_id: publishJob.id,
      status: "PUBLISHED",
      roblox_asset_id: robloxAssetId,
      result: responseJson
    });
  }

  return jsonResponse({
    publish_job_id: publishJob.id,
    status: publishJob.status,
    done: false,
    result: responseJson
  });
});
