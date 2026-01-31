create or replace function public.enqueue_ai_job()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  _url text;
  _secret text;
  _key text;
begin
  if new.status <> 'QUEUED' or new.stage <> 'PREVIEW' then
    return new;
  end if;

  if new.provider = 'TRIPO' then
    _key := 'tripo_dispatch_url';
  else
    _key := 'meshy_dispatch_url';
  end if;

  select value into _url from public.app_settings where key = _key;
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
execute function public.enqueue_ai_job();
