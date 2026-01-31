create table public.roblox_oauth_states (
  state text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  code_verifier text not null,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null
);

create index roblox_oauth_states_user_id_idx on public.roblox_oauth_states (user_id);

create table public.roblox_oauth_tokens (
  user_id uuid primary key references auth.users (id) on delete cascade,
  access_token text not null,
  refresh_token text,
  token_type text,
  scope text,
  expires_at timestamptz,
  roblox_user_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger set_roblox_oauth_tokens_updated_at
before update on public.roblox_oauth_tokens
for each row
execute function public.set_updated_at();

alter table public.roblox_oauth_states enable row level security;
alter table public.roblox_oauth_tokens enable row level security;

revoke all on public.roblox_oauth_states from anon, authenticated;
revoke all on public.roblox_oauth_tokens from anon, authenticated;
