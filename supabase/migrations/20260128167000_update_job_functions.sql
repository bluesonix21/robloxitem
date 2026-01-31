create or replace function public.create_ai_job(
  request_payload jsonb,
  create_asset boolean default true,
  asset_title text default null,
  asset_description text default null,
  provider public.provider_type default 'MESHY'
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

  insert into public.ai_jobs (user_id, asset_id, request_payload, provider)
  values (_user_id, _asset_id, coalesce(request_payload, '{}'::jsonb), provider)
  returning id into _job_id;

  job_id := _job_id;
  asset_id := _asset_id;
  return next;
end;
$$;

grant execute on function public.create_ai_job(jsonb, boolean, text, text, public.provider_type) to authenticated;

create or replace function public.create_ai_job_with_credits(
  request_payload jsonb,
  create_asset boolean default true,
  asset_title text default null,
  asset_description text default null,
  asset_id uuid default null,
  provider public.provider_type default 'MESHY'
)
returns table (job_id uuid, asset_id uuid, credit_cost integer, balance integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  _user_id uuid;
  _asset_id uuid;
  _job_id uuid;
  _balance integer;
  _cost integer;
  _owner uuid;
begin
  _user_id := auth.uid();
  if _user_id is null then
    raise exception 'authentication required';
  end if;

  _cost := public.compute_job_credit_cost(coalesce(request_payload, '{}'::jsonb));

  insert into public.credit_accounts (user_id)
  values (_user_id)
  on conflict (user_id) do nothing;

  select balance into _balance from public.credit_accounts where user_id = _user_id for update;
  if _balance < _cost then
    raise exception 'insufficient credits';
  end if;

  if asset_id is not null then
    select owner_id into _owner from public.assets where id = asset_id;
    if _owner is null then
      raise exception 'asset not found';
    end if;
    if _owner <> _user_id then
      raise exception 'forbidden';
    end if;
    _asset_id := asset_id;
  elsif create_asset then
    insert into public.assets (owner_id, title, description)
    values (_user_id, asset_title, asset_description)
    returning id into _asset_id;
  else
    _asset_id := null;
  end if;

  insert into public.ai_jobs (user_id, asset_id, request_payload, credit_cost, provider)
  values (_user_id, _asset_id, coalesce(request_payload, '{}'::jsonb), _cost, provider)
  returning id into _job_id;

  update public.credit_accounts
  set balance = balance - _cost
  where user_id = _user_id;

  insert into public.credit_ledger (user_id, job_id, amount, reason, metadata)
  values (_user_id, _job_id, -_cost, 'RESERVE', jsonb_build_object('note', 'AI job reserve'));

  select balance into _balance from public.credit_accounts where user_id = _user_id;

  job_id := _job_id;
  asset_id := _asset_id;
  credit_cost := _cost;
  balance := _balance;
  return next;
end;
$$;

grant execute on function public.create_ai_job_with_credits(jsonb, boolean, text, text, uuid, public.provider_type) to authenticated;
