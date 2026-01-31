import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { createUserClient } from "../_shared/supabase.ts";

function generateSecret(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(32));
  return Array.from(bytes).map((b) => b.toString(16).padStart(2, "0")).join("");
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

  let body: Record<string, unknown> = {};
  try {
    body = await req.json();
  } catch (_err) {
    return errorResponse("Invalid JSON body", 400);
  }

  const provider = typeof body.provider === "string" ? body.provider.toUpperCase() : "MESHY";
  if (provider !== "MESHY" && provider !== "TRIPO") {
    return errorResponse("Unsupported provider", 400);
  }

  const authHeader = req.headers.get("Authorization");
  const userClient = createUserClient(authHeader);

  const { data: existing } = await userClient
    .from("user_provider_secrets")
    .select("webhook_secret")
    .eq("provider", provider)
    .maybeSingle();

  if (existing?.webhook_secret && body.rotate !== true) {
    return jsonResponse({ webhook_secret: existing.webhook_secret, rotated: false });
  }

  const secret = generateSecret();

  const { error } = await userClient
    .from("user_provider_secrets")
    .upsert({
      user_id: auth.userId,
      provider,
      webhook_secret: secret
    });

  if (error) {
    return errorResponse("Failed to store secret", 500, { detail: error.message });
  }

  return jsonResponse({ webhook_secret: secret, rotated: true });
});
