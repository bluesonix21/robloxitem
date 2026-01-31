create or replace function public.create_ai_job(
  request_payload jsonb,
  create_asset boolean default true,
  asset_title text default null,
  asset_description text default null
)
returns table (job_id uuid, asset_id uuid)
language plpgsql
security definer
set search_path = public
as $$
declare
  _user_id uuid;
  _asset_id uuid;
  _job_id uuid;
begin
  _user_id := auth.uid();
  if _user_id is null then
    raise exception 'authentication required';
  end if;

  if create_asset then
    insert into public.assets (owner_id, title, description)
    values (_user_id, asset_title, asset_description)
    returning id into _asset_id;
  else
    _asset_id := null;
  end if;

  insert into public.ai_jobs (user_id, asset_id, request_payload)
  values (_user_id, _asset_id, coalesce(request_payload, '{}'::jsonb))
  returning id into _job_id;

  job_id := _job_id;
  asset_id := _asset_id;
  return next;
end;
$$;

grant execute on function public.create_ai_job(jsonb, boolean, text, text) to authenticated;

create or replace function public.cancel_ai_job(job_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  _user_id uuid;
begin
  _user_id := auth.uid();
  if _user_id is null then
    raise exception 'authentication required';
  end if;

  update public.ai_jobs
  set status = 'CANCELLED', completed_at = now()
  where id = job_id and user_id = _user_id and status in ('QUEUED', 'IN_PROGRESS');

  perform public.refund_job_credits(job_id);
end;
$$;

grant execute on function public.cancel_ai_job(uuid) to authenticated;
