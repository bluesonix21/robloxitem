import { SupabaseClient } from "@supabase/supabase-js";
import { getEnv } from "./env.ts";

export interface StoredAssetPaths {
  mesh_storage_path?: string;
  texture_storage_path?: string;
  pbr_metalness_storage_path?: string;
  pbr_roughness_storage_path?: string;
  pbr_normal_storage_path?: string;
}

function inferContentType(url: string, fallback = "application/octet-stream"): string {
  const lower = url.toLowerCase();
  if (lower.endsWith(".png")) return "image/png";
  if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
  if (lower.endsWith(".webp")) return "image/webp";
  if (lower.endsWith(".glb")) return "model/gltf-binary";
  if (lower.endsWith(".gltf")) return "model/gltf+json";
  if (lower.endsWith(".fbx")) return "model/fbx";
  if (lower.endsWith(".obj")) return "text/plain";
  return fallback;
}

function fileExtension(url: string, fallback: string): string {
  const match = url.split("?")[0].match(/\.([a-zA-Z0-9]+)$/);
  if (!match) return fallback;
  return match[1].toLowerCase();
}

async function downloadUrl(url: string, maxBytes: number): Promise<Uint8Array> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to download asset: ${response.status}`);
  }
  const contentLength = response.headers.get("content-length");
  if (contentLength && Number(contentLength) > maxBytes) {
    throw new Error("Remote asset exceeds max size");
  }
  const buffer = new Uint8Array(await response.arrayBuffer());
  if (buffer.byteLength > maxBytes) {
    throw new Error("Remote asset exceeds max size");
  }
  return buffer;
}

async function uploadFile(
  admin: SupabaseClient,
  bucket: string,
  path: string,
  data: Uint8Array,
  contentType: string
) {
  const { error } = await admin.storage.from(bucket).upload(path, data, {
    contentType,
    upsert: true
  });
  if (error) {
    throw new Error(`Storage upload failed: ${error.message}`);
  }
}

export async function persistRemoteAssets(
  admin: SupabaseClient,
  userId: string,
  assetId: string,
  urls: {
    mesh_url?: string | null;
    texture_url?: string | null;
    pbr_metalness_url?: string | null;
    pbr_roughness_url?: string | null;
    pbr_normal_url?: string | null;
  }
): Promise<StoredAssetPaths> {
  const maxMb = Number(getEnv("ASSET_MAX_MB", false) || "50");
  const maxBytes = Math.max(1, maxMb) * 1024 * 1024;
  const prefix = `${userId}/${assetId}`;
  const stored: StoredAssetPaths = {};

  if (urls.mesh_url) {
    const ext = fileExtension(urls.mesh_url, "glb");
    const path = `${prefix}/mesh.${ext}`;
    const data = await downloadUrl(urls.mesh_url, maxBytes);
    await uploadFile(admin, "assets", path, data, inferContentType(urls.mesh_url));
    stored.mesh_storage_path = path;
  }
  if (urls.texture_url) {
    const ext = fileExtension(urls.texture_url, "png");
    const path = `${prefix}/albedo.${ext}`;
    const data = await downloadUrl(urls.texture_url, maxBytes);
    await uploadFile(admin, "assets", path, data, inferContentType(urls.texture_url, "image/png"));
    stored.texture_storage_path = path;
  }
  if (urls.pbr_metalness_url) {
    const ext = fileExtension(urls.pbr_metalness_url, "png");
    const path = `${prefix}/metalness.${ext}`;
    const data = await downloadUrl(urls.pbr_metalness_url, maxBytes);
    await uploadFile(admin, "assets", path, data, inferContentType(urls.pbr_metalness_url, "image/png"));
    stored.pbr_metalness_storage_path = path;
  }
  if (urls.pbr_roughness_url) {
    const ext = fileExtension(urls.pbr_roughness_url, "png");
    const path = `${prefix}/roughness.${ext}`;
    const data = await downloadUrl(urls.pbr_roughness_url, maxBytes);
    await uploadFile(admin, "assets", path, data, inferContentType(urls.pbr_roughness_url, "image/png"));
    stored.pbr_roughness_storage_path = path;
  }
  if (urls.pbr_normal_url) {
    const ext = fileExtension(urls.pbr_normal_url, "png");
    const path = `${prefix}/normal.${ext}`;
    const data = await downloadUrl(urls.pbr_normal_url, maxBytes);
    await uploadFile(admin, "assets", path, data, inferContentType(urls.pbr_normal_url, "image/png"));
    stored.pbr_normal_storage_path = path;
  }

  return stored;
}

export async function createSignedUrl(admin: SupabaseClient, path: string): Promise<string | null> {
  const ttl = Number(getEnv("ASSET_SIGNED_URL_TTL", false) || "3600");
  const { data, error } = await admin.storage.from("assets").createSignedUrl(path, ttl);
  if (error || !data?.signedUrl) {
    return null;
  }
  return data.signedUrl;
}
