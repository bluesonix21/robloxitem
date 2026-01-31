import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { createAdminClient } from "../_shared/supabase.ts";
import { getEnv } from "../_shared/env.ts";
import { createSignedUrl } from "../_shared/storage.ts";
import { getValidRobloxAccessToken } from "../_shared/roblox_oauth.ts";

function buildMultipart(fields: Record<string, string>, files: Record<string, { filename: string; contentType: string; data: Uint8Array }>) {
  const boundary = `----robloxitem-${crypto.randomUUID()}`;
  const chunks: Uint8Array[] = [];
  const encoder = new TextEncoder();

  for (const [key, value] of Object.entries(fields)) {
    chunks.push(encoder.encode(`--${boundary}\r\n`));
    chunks.push(encoder.encode(`Content-Disposition: form-data; name="${key}"\r\n\r\n`));
    chunks.push(encoder.encode(`${value}\r\n`));
  }

  for (const [key, file] of Object.entries(files)) {
    chunks.push(encoder.encode(`--${boundary}\r\n`));
    chunks.push(
      encoder.encode(
        `Content-Disposition: form-data; name="${key}"; filename="${file.filename}"\r\nContent-Type: ${file.contentType}\r\n\r\n`
      )
    );
    chunks.push(file.data);
    chunks.push(encoder.encode("\r\n"));
  }

  chunks.push(encoder.encode(`--${boundary}--\r\n`));
  return { boundary, body: new Blob(chunks) };
}

async function downloadFile(url: string): Promise<Uint8Array> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to download file: ${response.status}`);
  }
  return new Uint8Array(await response.arrayBuffer());
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
    .eq("key", "rate_roblox_publish_per_minute")
    .maybeSingle();

  const maxPerMinute = settings?.value ? Number(settings.value) : 2;
  const { data: rateAllowed, error: rateError } = await admin.rpc("check_rate_limit", {
    key: `roblox-publish:${auth.userId}`,
    window_seconds: 60,
    max_requests: Number.isFinite(maxPerMinute) && maxPerMinute > 0 ? maxPerMinute : 2
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

  const assetId = typeof body.asset_id === "string" ? body.asset_id : "";
  if (!assetId) {
    return errorResponse("asset_id is required", 400);
  }

  const { data: asset } = await admin
    .from("assets")
    .select("id, owner_id, mesh_url, mesh_storage_path, texture_url, pbr_metalness_url, pbr_roughness_url, pbr_normal_url")
    .eq("id", assetId)
    .maybeSingle();

  if (!asset) {
    return errorResponse("Asset not found", 404);
  }
  if (asset.owner_id !== auth.userId) {
    return errorResponse("Forbidden", 403);
  }
  let meshUrl = asset.mesh_url;
  if (asset.mesh_storage_path) {
    const signed = await createSignedUrl(admin, asset.mesh_storage_path);
    if (signed) {
      meshUrl = signed;
    }
  }
  if (!meshUrl) {
    return errorResponse("Asset missing mesh", 409);
  }

  const creatorUserId = typeof body.creator_user_id === "number"
    ? body.creator_user_id
    : (typeof body.creator_user_id === "string" ? Number(body.creator_user_id) : null);
  const creatorGroupId = typeof body.creator_group_id === "number"
    ? body.creator_group_id
    : (typeof body.creator_group_id === "string" ? Number(body.creator_group_id) : null);

  const publishPayload = {
    displayName: typeof body.name === "string" ? body.name : "RobloxItem",
    description: typeof body.description === "string" ? body.description : "",
    assetType: typeof body.asset_type === "string" ? body.asset_type : "Model",
    creatorUserId: Number.isFinite(creatorUserId ?? NaN) ? creatorUserId : null,
    creatorGroupId: Number.isFinite(creatorGroupId ?? NaN) ? creatorGroupId : null
  };

  if (!publishPayload.creatorUserId && !publishPayload.creatorGroupId) {
    return errorResponse("creator_user_id or creator_group_id is required", 400);
  }

  const { data: publishJob, error } = await admin
    .from("roblox_publish_jobs")
    .insert({
      user_id: auth.userId,
      asset_id: asset.id,
      request_payload: publishPayload
    })
    .select("id")
    .single();

  if (error || !publishJob) {
    return errorResponse("Failed to create publish job", 500, { detail: error?.message });
  }

  const oauthToken = await getValidRobloxAccessToken(admin, auth.userId);
  const robloxToken = oauthToken?.accessToken ?? getEnv("ROBLOX_OAUTH_TOKEN", false);
  if (!robloxToken) {
    return errorResponse("Missing Roblox OAuth token", 401);
  }
  const tokenType = oauthToken?.tokenType ?? "Bearer";
  const meshData = await downloadFile(meshUrl);
  const meshPath = new URL(meshUrl).pathname.toLowerCase();
  const isGlb = meshPath.endsWith(".glb");
  const isGltf = meshPath.endsWith(".gltf");
  const fileName = isGlb ? "asset.glb" : (isGltf ? "asset.gltf" : "asset.fbx");
  const fileContentType = isGlb
    ? "model/gltf-binary"
    : (isGltf ? "model/gltf+json" : "model/fbx");

  const requestBody = {
    assetType: publishPayload.assetType,
    displayName: publishPayload.displayName,
    description: publishPayload.description,
    creationContext: {
      creator: publishPayload.creatorUserId
        ? { userId: publishPayload.creatorUserId }
        : { groupId: publishPayload.creatorGroupId }
    }
  };

  const { boundary, body: multipartBody } = buildMultipart(
    {
      request: JSON.stringify(requestBody)
    },
    {
      fileContent: { filename: fileName, contentType: fileContentType, data: meshData }
    }
  );

  const robloxResponse = await fetch("https://apis.roblox.com/assets/v1/assets", {
    method: "POST",
    headers: {
      Authorization: `${tokenType} ${robloxToken}`,
      "Content-Type": `multipart/form-data; boundary=${boundary}`
    },
    body: multipartBody
  });

  const responseText = await robloxResponse.text();
  let responseJson: Record<string, unknown> = {};
  try {
    responseJson = responseText ? JSON.parse(responseText) : {};
  } catch (_err) {
    responseJson = { raw: responseText };
  }

  if (!robloxResponse.ok) {
    await admin
      .from("roblox_publish_jobs")
      .update({
        status: "FAILED",
        error_message: String(responseJson.message ?? "Roblox publish failed"),
        result_payload: responseJson
      })
      .eq("id", publishJob.id);

    return errorResponse("Roblox publish failed", robloxResponse.status, { detail: responseJson });
  }

  await admin
    .from("roblox_publish_jobs")
    .update({
      status: "QUEUED",
      result_payload: responseJson,
      operation_id: typeof responseJson.operationId === "string" ? responseJson.operationId : undefined,
      operation_path: typeof responseJson.path === "string" ? responseJson.path : undefined
    })
    .eq("id", publishJob.id);

  return jsonResponse({
    publish_job_id: publishJob.id,
    operation_id: typeof responseJson.operationId === "string" ? responseJson.operationId : null,
    operation_path: typeof responseJson.path === "string" ? responseJson.path : null,
    result: responseJson
  });
});
