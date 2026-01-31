import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { createAdminClient } from "../_shared/supabase.ts";
import { exchangeCode, fetchRobloxUserInfo, getRobloxOAuthReturnUrl } from "../_shared/roblox_oauth.ts";

function redirectUrl(base: string, params: Record<string, string>) {
  const url = new URL(base);
  for (const [key, value] of Object.entries(params)) {
    url.searchParams.set(key, value);
  }
  return url.toString();
}

serve(async (req) => {
  const optionsResponse = handleOptions(req);
  if (optionsResponse) return optionsResponse;

  const url = new URL(req.url);
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");

  if (!code || !state) {
    return errorResponse("Missing code or state", 400);
  }

  const admin = createAdminClient();
  const { data: oauthState, error } = await admin
    .from("roblox_oauth_states")
    .select("state, user_id, code_verifier, expires_at")
    .eq("state", state)
    .maybeSingle();

  if (error || !oauthState) {
    return errorResponse("Invalid state", 400);
  }

  if (new Date(oauthState.expires_at).getTime() < Date.now()) {
    return errorResponse("State expired", 400);
  }

  try {
    const tokenData = await exchangeCode({ code, codeVerifier: oauthState.code_verifier }, admin);
    const accessToken = String(tokenData.access_token ?? "");
    if (!accessToken) {
      throw new Error("Missing access token");
    }

    const expiresIn = Number(tokenData.expires_in ?? 0);
    const expiresAt = expiresIn > 0 ? new Date(Date.now() + expiresIn * 1000).toISOString() : null;
    const userInfo = await fetchRobloxUserInfo(accessToken);
    const robloxUserId = typeof userInfo?.sub === "string" ? userInfo.sub : null;
    const robloxUsername = typeof userInfo?.preferred_username === "string"
      ? userInfo.preferred_username
      : (typeof userInfo?.name === "string" ? userInfo.name : null);
    const robloxAvatarUrl = typeof userInfo?.picture === "string" ? userInfo.picture : null;

    await admin
      .from("roblox_oauth_tokens")
      .upsert({
        user_id: oauthState.user_id,
        access_token: accessToken,
        refresh_token: typeof tokenData.refresh_token === "string" ? tokenData.refresh_token : null,
        token_type: typeof tokenData.token_type === "string" ? tokenData.token_type : null,
        scope: typeof tokenData.scope === "string" ? tokenData.scope : null,
        expires_at: expiresAt,
        roblox_user_id: robloxUserId,
        roblox_username: robloxUsername,
        roblox_avatar_url: robloxAvatarUrl
      });

    await admin.from("roblox_oauth_states").delete().eq("state", state);

    const returnUrl = await getRobloxOAuthReturnUrl(admin);
    if (returnUrl) {
      return Response.redirect(redirectUrl(returnUrl, { status: "success" }), 302);
    }

    return jsonResponse({ status: "success" });
  } catch (err) {
    const message = err instanceof Error ? err.message : "OAuth exchange failed";
    const returnUrl = await getRobloxOAuthReturnUrl(admin);
    if (returnUrl) {
      return Response.redirect(redirectUrl(returnUrl, { status: "error", message }), 302);
    }

    return errorResponse(message, 500);
  }
});
