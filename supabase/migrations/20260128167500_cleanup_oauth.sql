create or replace function public.cleanup_roblox_oauth_states(retention_minutes integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.roblox_oauth_states
  where created_at < now() - make_interval(mins => retention_minutes);
end;
$$;
