create table public.ai_job_events (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.ai_jobs (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  stage public.job_stage not null,
  status public.job_status not null,
  provider_task_id text,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index ai_job_events_job_id_idx on public.ai_job_events (job_id);
create index ai_job_events_user_id_idx on public.ai_job_events (user_id);

alter table public.ai_job_events enable row level security;

create policy "ai_job_events_select_owner"
  on public.ai_job_events
  for select
  using (user_id = auth.uid());

revoke all on public.ai_job_events from anon, authenticated;
