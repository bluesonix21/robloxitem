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
  refine_enabled boolean := true;
  remesh_enabled boolean := true;
  refine_text text;
  remesh_text text;
  total integer;
begin
  if payload ? 'refine' and (payload->'refine' ? 'enabled') then
    refine_text := lower(coalesce(payload->'refine'->>'enabled', 'true'));
    if refine_text = 'false' then
      refine_enabled := false;
    else
      refine_enabled := true;
    end if;
  end if;

  if payload ? 'remesh' and (payload->'remesh' ? 'enabled') then
    remesh_text := lower(coalesce(payload->'remesh'->>'enabled', 'true'));
    if remesh_text = 'false' then
      remesh_enabled := false;
    else
      remesh_enabled := true;
    end if;
  end if;

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

create or replace function public.refund_job_credits(p_job_id uuid)
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
  select user_id, credit_cost into _user_id, _cost from public.ai_jobs where id = p_job_id;
  if _user_id is null or _cost is null or _cost = 0 then
    return;
  end if;

  select exists(
    select 1 from public.credit_ledger where job_id = p_job_id and reason = 'REFUND'
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
  values (_user_id, p_job_id, _cost, 'REFUND', jsonb_build_object('note', 'AI job refund'));
end;
$$;
