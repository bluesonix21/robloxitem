import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { createAdminClient } from "../_shared/supabase.ts";
import { buildAuthorizeUrl, generateCodeChallenge, generateCodeVerifier, generateState } from "../_shared/roblox_oauth.ts";

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

  const scopes = Array.isArray(body.scopes)
    ? body.scopes.filter((s) => typeof s === "string") as string[]
    : ["asset:write", "asset:read", "openid", "profile"];

  const state = generateState();
  const codeVerifier = generateCodeVerifier();
  const codeChallenge = await generateCodeChallenge(codeVerifier);
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString();

  const admin = createAdminClient();
  const { error } = await admin
    .from("roblox_oauth_states")
    .insert({
      state,
      user_id: auth.userId,
      code_verifier: codeVerifier,
      expires_at: expiresAt
    });

  if (error) {
    return errorResponse("Failed to create OAuth state", 500, { detail: error.message });
  }

  const authorizeUrl = await buildAuthorizeUrl({ state, codeChallenge, scopes }, admin);
  return jsonResponse({ authorize_url: authorizeUrl, state });
});
