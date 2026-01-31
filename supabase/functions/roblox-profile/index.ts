import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "std/http";
import { handleOptions } from "../_shared/cors.ts";
import { jsonResponse, errorResponse } from "../_shared/responses.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { createAdminClient } from "../_shared/supabase.ts";
import { fetchRobloxUserInfo, getValidRobloxAccessToken } from "../_shared/roblox_oauth.ts";

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

  const admin = createAdminClient();
  const { data: tokenRow, error } = await admin
    .from("roblox_oauth_tokens")
    .select("roblox_user_id, roblox_username, roblox_avatar_url")
    .eq("user_id", auth.userId)
    .maybeSingle();

  if (error) {
    return errorResponse("Failed to fetch Roblox profile", 500, { detail: error.message });
  }

  if (!tokenRow) {
    return jsonResponse({ connected: false });
  }

  let robloxUserId = tokenRow.roblox_user_id;
  let robloxUsername = tokenRow.roblox_username;
  let robloxAvatarUrl = tokenRow.roblox_avatar_url;

  const token = await getValidRobloxAccessToken(admin, auth.userId);
  if (token?.accessToken) {
    try {
      const userInfo = await fetchRobloxUserInfo(token.accessToken);
      if (userInfo) {
        const nextUserId = typeof userInfo.sub === "string" ? userInfo.sub : null;
        const nextUsername = typeof userInfo.preferred_username === "string"
          ? userInfo.preferred_username
          : (typeof userInfo.name === "string" ? userInfo.name : null);
        const nextAvatar = typeof userInfo.picture === "string" ? userInfo.picture : null;

        robloxUserId = nextUserId ?? robloxUserId;
        robloxUsername = nextUsername ?? robloxUsername;
        robloxAvatarUrl = nextAvatar ?? robloxAvatarUrl;

        await admin
          .from("roblox_oauth_tokens")
          .update({
            roblox_user_id: robloxUserId,
            roblox_username: robloxUsername,
            roblox_avatar_url: robloxAvatarUrl
          })
          .eq("user_id", auth.userId);
      }
    } catch (_err) {
      // Keep cached data if userinfo fetch fails
    }
  }

  return jsonResponse({
    connected: true,
    roblox_user_id: robloxUserId,
    username: robloxUsername,
    avatar_url: robloxAvatarUrl
  });
});
