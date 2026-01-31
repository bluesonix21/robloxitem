create extension if not exists "pgcrypto";

create type public.provider_type as enum (
  'MESHY'
);

create type public.job_stage as enum (
  'PREVIEW',
  'REFINE',
  'REMESH'
);

create type public.job_status as enum (
  'QUEUED',
  'SUBMITTED',
  'IN_PROGRESS',
  'SUCCEEDED',
  'FAILED',
  'CANCELLED'
);

create table public.assets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  title text,
  description text,
  mesh_url text,
  texture_url text,
  pbr_metalness_url text,
  pbr_roughness_url text,
  pbr_normal_url text,
  poly_count integer,
  is_public boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,
  source_job_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint assets_poly_count_limit check (poly_count is null or poly_count <= 4000)
);

create table public.ai_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  asset_id uuid references public.assets (id) on delete set null,
  provider public.provider_type not null default 'MESHY',
  stage public.job_stage not null,
  status public.job_status not null default 'QUEUED',
  provider_task_id text,
  request_payload jsonb not null default '{}'::jsonb,
  result_payload jsonb not null default '{}'::jsonb,
  error_message text,
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index ai_jobs_user_id_idx on public.ai_jobs (user_id);
create index ai_jobs_asset_id_idx on public.ai_jobs (asset_id);
create index ai_jobs_status_stage_idx on public.ai_jobs (status, stage);
create unique index ai_jobs_provider_task_id_unique on public.ai_jobs (provider_task_id)
  where provider_task_id is not null;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_assets_updated_at
before update on public.assets
for each row
execute function public.set_updated_at();

create trigger set_ai_jobs_updated_at
before update on public.ai_jobs
for each row
execute function public.set_updated_at();
