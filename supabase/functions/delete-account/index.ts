import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { createAdminClient } from "../_shared/supabase.ts";

type StorageItem = {
  name: string;
  id?: string | null;
  metadata?: Record<string, unknown> | null;
};

async function listObjects(admin: ReturnType<typeof createAdminClient>, path: string): Promise<string[]> {
  const { data, error } = await admin.storage.from("assets").list(path, {
    limit: 1000,
    offset: 0
  });
  if (error || !data) {
    return [];
  }

  const files: string[] = [];
  for (const item of data as StorageItem[]) {
    const hasMetadata = item.metadata && Object.keys(item.metadata).length > 0;
    if (item.id || hasMetadata) {
      files.push(path ? `${path}/${item.name}` : item.name);
    } else {
      const nested = await listObjects(admin, path ? `${path}/${item.name}` : item.name);
      files.push(...nested);
    }
  }
  return files;
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

  try {
    const paths = await listObjects(admin, auth.userId);
    if (paths.length > 0) {
      await admin.storage.from("assets").remove(paths);
    }
  } catch (_err) {
    // Ignore storage cleanup errors; user deletion still proceeds.
  }

  const { error } = await admin.auth.admin.deleteUser(auth.userId);
  if (error) {
    return errorResponse("Failed to delete account", 500, { detail: error.message });
  }

  return jsonResponse({ success: true });
});
