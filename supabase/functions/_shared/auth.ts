import { createAdminClient, createUserClient } from "./supabase.ts";
import { getEnv } from "./env.ts";

export interface AuthResult {
  userId: string | null;
  isInternal: boolean;
}

export async function authenticateRequest(req: Request): Promise<AuthResult> {
  const internalKey = Deno.env.get("MESHY_INTERNAL_KEY");
  const headerKey = req.headers.get("x-internal-key");
  if (headerKey) {
    if (internalKey && headerKey === internalKey) {
      return { userId: null, isInternal: true };
    }
    if (!internalKey) {
      const admin = createAdminClient();
      const { data, error } = await admin
        .from("app_settings")
        .select("value")
        .eq("key", "meshy_internal_key")
        .maybeSingle();

      if (!error && typeof data?.value === "string" && data.value === headerKey) {
        return { userId: null, isInternal: true };
      }
    }
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return { userId: null, isInternal: false };
  }

  const userClient = createUserClient(authHeader);
  const { data, error } = await userClient.auth.getUser();
  if (error || !data.user) {
    return { userId: null, isInternal: false };
  }

  return { userId: data.user.id, isInternal: false };
}

export function assertWebhookSecret(req: Request): boolean {
  const secret = Deno.env.get("MESHY_WEBHOOK_SECRET");
  if (!secret) {
    return true;
  }
  const header = req.headers.get("x-meshy-webhook-secret");
  return header === secret;
}

export function allowAssetFetch(req: Request): boolean {
  const secret = getEnv("ASSET_FETCH_KEY", false);
  if (!secret) {
    return false;
  }
  const header = req.headers.get("x-asset-fetch-key");
  return header === secret;
}
