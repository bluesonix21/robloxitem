create type public.credit_reason as enum (
  'RESERVE',
  'REFUND',
  'ADJUSTMENT'
);

create table public.credit_accounts (
  user_id uuid primary key references auth.users (id) on delete cascade,
  balance integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger set_credit_accounts_updated_at
before update on public.credit_accounts
for each row
execute function public.set_updated_at();

create table public.credit_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  job_id uuid references public.ai_jobs (id) on delete set null,
  amount integer not null,
  reason public.credit_reason not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create unique index credit_ledger_job_reason_unique on public.credit_ledger (job_id, reason)
  where job_id is not null;
create index credit_ledger_user_idx on public.credit_ledger (user_id);

alter table public.credit_accounts enable row level security;
alter table public.credit_ledger enable row level security;

create policy "credit_accounts_select_owner"
  on public.credit_accounts
  for select
  using (user_id = auth.uid());

create policy "credit_ledger_select_owner"
  on public.credit_ledger
  for select
  using (user_id = auth.uid());

alter table public.ai_jobs add column if not exists credit_cost integer not null default 0;

create or replace function public.get_setting_int(setting_key text, fallback integer)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  _value text;
  _int integer;
begin
  select value into _value from public.app_settings where key = setting_key;
  if _value is null then
    return fallback;
  end if;

  begin
    _int := _value::integer;
  exception when others then
    return fallback;
  end;

  return _int;
end;
$$;

create or replace function public.compute_job_credit_cost(payload jsonb)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  preview_cost integer := public.get_setting_int('credit_cost_preview', 10);
  refine_cost integer := public.get_setting_int('credit_cost_refine', 15);
  remesh_cost integer := public.get_setting_int('credit_cost_remesh', 10);
  refine_enabled boolean := coalesce((payload->'refine'->>'enabled')::boolean, true);
  remesh_enabled boolean := coalesce((payload->'remesh'->>'enabled')::boolean, true);
  total integer;
begin
  total := preview_cost;
  if refine_enabled then
    total := total + refine_cost;
  end if;
  if remesh_enabled then
    total := total + remesh_cost;
  end if;
  return total;
end;
$$;

create or replace function public.create_ai_job_with_credits(
  request_payload jsonb,
  create_asset boolean default true,
  asset_title text default null,
  asset_description text default null,
  asset_id uuid default null
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

  insert into public.ai_jobs (user_id, asset_id, request_payload, credit_cost)
  values (_user_id, _asset_id, coalesce(request_payload, '{}'::jsonb), _cost)
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

grant execute on function public.create_ai_job_with_credits(jsonb, boolean, text, text, uuid) to authenticated;

create or replace function public.refund_job_credits(job_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  _user_id uuid;
  _cost integer;
  _exists boolean;
begin
  select user_id, credit_cost into _user_id, _cost from public.ai_jobs where id = job_id;
  if _user_id is null or _cost is null or _cost = 0 then
    return;
  end if;

  select exists(
    select 1 from public.credit_ledger where job_id = job_id and reason = 'REFUND'
  ) into _exists;

  if _exists then
    return;
  end if;

  insert into public.credit_accounts (user_id)
  values (_user_id)
  on conflict (user_id) do nothing;

  update public.credit_accounts
  set balance = balance + _cost
  where user_id = _user_id;

  insert into public.credit_ledger (user_id, job_id, amount, reason, metadata)
  values (_user_id, job_id, _cost, 'REFUND', jsonb_build_object('note', 'AI job refund'));
end;
$$;
