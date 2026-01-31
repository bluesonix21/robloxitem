create extension if not exists "pg_net";

create table if not exists public.app_settings (
  key text primary key,
  value text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger set_app_settings_updated_at
before update on public.app_settings
for each row
execute function public.set_updated_at();

revoke all on public.app_settings from anon, authenticated;

create or replace function public.enqueue_meshy_job()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  _url text;
  _secret text;
begin
  if new.provider <> 'MESHY' or new.status <> 'QUEUED' or new.stage <> 'PREVIEW' then
    return new;
  end if;

  select value into _url from public.app_settings where key = 'meshy_dispatch_url';
  if _url is null then
    return new;
  end if;

  select value into _secret from public.app_settings where key = 'meshy_internal_key';

  perform net.http_post(
    url := _url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-internal-key', coalesce(_secret, '')
    ),
    body := jsonb_build_object('job_id', new.id)
  );

  return new;
end;
$$;

drop trigger if exists ai_jobs_enqueue on public.ai_jobs;
create trigger ai_jobs_enqueue
after insert on public.ai_jobs
for each row
execute function public.enqueue_meshy_job();
