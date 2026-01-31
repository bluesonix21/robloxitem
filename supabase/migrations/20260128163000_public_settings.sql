create or replace function public.get_public_settings()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  result jsonb := '{}'::jsonb;
  key text;
  val text;
  allowed_keys text[] := array[
    'credit_cost_preview',
    'credit_cost_refine',
    'credit_cost_remesh',
    'rate_job_create_per_minute',
    'rate_poll_per_minute'
  ];
begin
  for key, val in
    select k, v from (
      select key as k, value as v
      from public.app_settings
      where key = any(allowed_keys)
    ) s
  loop
    result := result || jsonb_build_object(key, val);
  end loop;

  return result;
end;
$$;

grant execute on function public.get_public_settings() to authenticated;
