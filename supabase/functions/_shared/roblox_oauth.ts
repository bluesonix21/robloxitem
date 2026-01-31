import { SupabaseClient } from "@supabase/supabase-js";
import { createAdminClient } from "./supabase.ts";

const BASE_URL = "https://apis.roblox.com/oauth/v1";
const SETTINGS_KEYS = [
  "roblox_oauth_client_id",
  "roblox_oauth_client_secret",
  "roblox_oauth_redirect_uri",
  "roblox_oauth_return_url"
];

interface RobloxOAuthConfig {
  clientId: string;
  clientSecret: string;
  redirectUri: string;
  returnUrl?: string | null;
}

function base64UrlEncode(bytes: Uint8Array): string {
  return btoa(String.fromCharCode(...bytes))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");
}

export function generateState(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(16));
  return base64UrlEncode(bytes);
}

export async function generateCodeChallenge(verifier: string): Promise<string> {
  const data = new TextEncoder().encode(verifier);
  const digest = await crypto.subtle.digest("SHA-256", data);
  return base64UrlEncode(new Uint8Array(digest));
}

export function generateCodeVerifier(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(32));
  return base64UrlEncode(bytes);
}

async function fetchSettings(
  admin: SupabaseClient,
  keys: string[]
): Promise<Record<string, string>> {
  const { data } = await admin
    .from("app_settings")
    .select("key, value")
    .in("key", keys);

  const result: Record<string, string> = {};
  if (Array.isArray(data)) {
    for (const row of data) {
      if (row && typeof row.key === "string" && typeof row.value === "string") {
        result[row.key] = row.value;
      }
    }
  }
  return result;
}

async function resolveRobloxOAuthConfig(admin?: SupabaseClient): Promise<RobloxOAuthConfig> {
  const envClientId = Deno.env.get("ROBLOX_OAUTH_CLIENT_ID") ?? "";
  const envClientSecret = Deno.env.get("ROBLOX_OAUTH_CLIENT_SECRET") ?? "";
  const envRedirectUri = Deno.env.get("ROBLOX_OAUTH_REDIRECT_URI") ?? "";
  const envReturnUrl = Deno.env.get("ROBLOX_OAUTH_RETURN_URL") ?? "";

  const needsSettings = !envClientId || !envClientSecret || !envRedirectUri || !envReturnUrl;
  const settings = needsSettings
    ? await fetchSettings(admin ?? createAdminClient(), SETTINGS_KEYS)
    : {};

  const clientId = envClientId || settings.roblox_oauth_client_id || "";
  const clientSecret = envClientSecret || settings.roblox_oauth_client_secret || "";
  const redirectUri = envRedirectUri || settings.roblox_oauth_redirect_uri || "";
  const returnUrl = envReturnUrl || settings.roblox_oauth_return_url || null;

  if (!clientId) {
    throw new Error("Missing Roblox OAuth client ID");
  }
  if (!clientSecret) {
    throw new Error("Missing Roblox OAuth client secret");
  }
  if (!redirectUri) {
    throw new Error("Missing Roblox OAuth redirect URI");
  }

  return { clientId, clientSecret, redirectUri, returnUrl };
}

export async function buildAuthorizeUrl(params: {
  state: string;
  codeChallenge: string;
  scopes: string[];
}, admin?: SupabaseClient) {
  const config = await resolveRobloxOAuthConfig(admin);
  const url = new URL(`${BASE_URL}/authorize`);
  url.searchParams.set("client_id", config.clientId);
  url.searchParams.set("redirect_uri", config.redirectUri);
  url.searchParams.set("response_type", "code");
  url.searchParams.set("scope", params.scopes.join(" "));
  url.searchParams.set("state", params.state);
  url.searchParams.set("code_challenge", params.codeChallenge);
  url.searchParams.set("code_challenge_method", "S256");
  return url.toString();
}

function encodeForm(body: Record<string, string>) {
  const params = new URLSearchParams();
  for (const [key, value] of Object.entries(body)) {
    params.set(key, value);
  }
  return params.toString();
}

async function fetchToken(body: Record<string, string>) {
  const response = await fetch(`${BASE_URL}/token`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: encodeForm(body)
  });
  const text = await response.text();
  let json: Record<string, unknown> = {};
  try {
    json = text ? JSON.parse(text) : {};
  } catch (_err) {
    json = { raw: text };
  }
  if (!response.ok) {
    const message = typeof json.error_description === "string" ? json.error_description : "Roblox token request failed";
    throw new Error(message);
  }
  return json;
}

export async function exchangeCode(params: {
  code: string;
  codeVerifier: string;
}, admin?: SupabaseClient) {
  const config = await resolveRobloxOAuthConfig(admin);
  return fetchToken({
    grant_type: "authorization_code",
    code: params.code,
    client_id: config.clientId,
    client_secret: config.clientSecret,
    code_verifier: params.codeVerifier,
    redirect_uri: config.redirectUri
  });
}

export async function refreshAccessToken(refreshToken: string, admin?: SupabaseClient) {
  const config = await resolveRobloxOAuthConfig(admin);
  return fetchToken({
    grant_type: "refresh_token",
    refresh_token: refreshToken,
    client_id: config.clientId,
    client_secret: config.clientSecret
  });
}

export async function fetchRobloxUserInfo(accessToken: string): Promise<Record<string, unknown> | null> {
  const response = await fetch(`${BASE_URL}/userinfo`, {
    headers: { Authorization: `Bearer ${accessToken}` }
  });
  if (!response.ok) {
    return null;
  }
  const text = await response.text();
  try {
    return text ? JSON.parse(text) : {};
  } catch (_err) {
    return null;
  }
}

export async function getValidRobloxAccessToken(
  admin: SupabaseClient,
  userId: string
): Promise<{ accessToken: string; tokenType?: string } | null> {
  const { data: tokenRow } = await admin
    .from("roblox_oauth_tokens")
    .select("access_token, refresh_token, token_type, expires_at")
    .eq("user_id", userId)
    .maybeSingle();

  if (!tokenRow) {
    return null;
  }

  const expiresAt = tokenRow.expires_at ? new Date(tokenRow.expires_at).getTime() : null;
  const now = Date.now();
  if (!expiresAt || expiresAt - now > 60 * 1000) {
    return { accessToken: tokenRow.access_token, tokenType: tokenRow.token_type ?? "Bearer" };
  }

  if (!tokenRow.refresh_token) {
    return null;
  }

  const refreshed = await refreshAccessToken(tokenRow.refresh_token, admin);
  const accessToken = String(refreshed.access_token ?? "");
  if (!accessToken) {
    return null;
  }

  const expiresIn = Number(refreshed.expires_in ?? 0);
  const newExpiresAt = expiresIn > 0 ? new Date(Date.now() + expiresIn * 1000).toISOString() : null;

  await admin
    .from("roblox_oauth_tokens")
    .upsert({
      user_id: userId,
      access_token: accessToken,
      refresh_token: typeof refreshed.refresh_token === "string" ? refreshed.refresh_token : tokenRow.refresh_token,
      token_type: typeof refreshed.token_type === "string" ? refreshed.token_type : tokenRow.token_type,
      scope: typeof refreshed.scope === "string" ? refreshed.scope : null,
      expires_at: newExpiresAt
    });

  return { accessToken, tokenType: typeof refreshed.token_type === "string" ? refreshed.token_type : tokenRow.token_type ?? "Bearer" };
}

export async function getRobloxOAuthReturnUrl(admin?: SupabaseClient): Promise<string | null> {
  const config = await resolveRobloxOAuthConfig(admin);
  return config.returnUrl ?? null;
}
