import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { authenticateRequest, allowAssetFetch } from "../_shared/auth.ts";
import { createAdminClient } from "../_shared/supabase.ts";
import { createSignedUrl } from "../_shared/storage.ts";

serve(async (req) => {
  const optionsResponse = handleOptions(req);
  if (optionsResponse) return optionsResponse;

  if (req.method !== "GET") {
    return errorResponse("Method not allowed", 405);
  }

  const assetId = new URL(req.url).searchParams.get("id");
  if (!assetId) {
    return errorResponse("id is required", 400);
  }

  const auth = await authenticateRequest(req);
  const internalAllowed = allowAssetFetch(req);

  const admin = createAdminClient();
  const { data: asset, error } = await admin
    .from("assets")
    .select("id, owner_id, mesh_url, texture_url, pbr_metalness_url, pbr_roughness_url, pbr_normal_url, mesh_storage_path, texture_storage_path, pbr_metalness_storage_path, pbr_roughness_storage_path, pbr_normal_storage_path, is_public, metadata")
    .eq("id", assetId)
    .maybeSingle();

  if (error || !asset) {
    return errorResponse("Asset not found", 404);
  }

  const isOwner = auth.userId && auth.userId === asset.owner_id;
  const allowed = asset.is_public || isOwner || internalAllowed || auth.isInternal;

  if (!allowed) {
    return errorResponse("Forbidden", 403);
  }

  const signedMesh = asset.mesh_storage_path ? await createSignedUrl(admin, asset.mesh_storage_path) : null;
  const signedTexture = asset.texture_storage_path ? await createSignedUrl(admin, asset.texture_storage_path) : null;
  const signedMetalness = asset.pbr_metalness_storage_path
    ? await createSignedUrl(admin, asset.pbr_metalness_storage_path)
    : null;
  const signedRoughness = asset.pbr_roughness_storage_path
    ? await createSignedUrl(admin, asset.pbr_roughness_storage_path)
    : null;
  const signedNormal = asset.pbr_normal_storage_path
    ? await createSignedUrl(admin, asset.pbr_normal_storage_path)
    : null;

  const meshUrl = signedMesh ?? asset.mesh_url;
  const textureUrl = signedTexture ?? asset.texture_url;
  const metalnessUrl = signedMetalness ?? asset.pbr_metalness_url;
  const roughnessUrl = signedRoughness ?? asset.pbr_roughness_url;
  const normalUrl = signedNormal ?? asset.pbr_normal_url;

  return jsonResponse({
    id: asset.id,
    mesh_url: meshUrl,
    texture_url: textureUrl,
    pbr_metalness_url: metalnessUrl,
    pbr_roughness_url: roughnessUrl,
    pbr_normal_url: normalUrl,
    metadata: asset.metadata
  });
});
