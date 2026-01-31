create type public.publish_status as enum (
  'QUEUED',
  'PUBLISHED',
  'FAILED'
);

create table public.roblox_publish_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  asset_id uuid not null references public.assets (id) on delete cascade,
  status public.publish_status not null default 'QUEUED',
  roblox_asset_id bigint,
  error_message text,
  request_payload jsonb not null default '{}'::jsonb,
  result_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index roblox_publish_jobs_user_id_idx on public.roblox_publish_jobs (user_id);
create index roblox_publish_jobs_asset_id_idx on public.roblox_publish_jobs (asset_id);

alter table public.roblox_publish_jobs enable row level security;

create policy "roblox_publish_jobs_select_owner"
  on public.roblox_publish_jobs
  for select
  using (user_id = auth.uid());

create policy "roblox_publish_jobs_insert_owner"
  on public.roblox_publish_jobs
  for insert
  with check (user_id = auth.uid());

create policy "roblox_publish_jobs_update_owner"
  on public.roblox_publish_jobs
  for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create trigger set_roblox_publish_jobs_updated_at
before update on public.roblox_publish_jobs
for each row
execute function public.set_updated_at();
