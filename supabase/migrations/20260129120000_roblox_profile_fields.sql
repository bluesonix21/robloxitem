alter table public.roblox_oauth_tokens
  add column if not exists roblox_username text,
  add column if not exists roblox_avatar_url text;
