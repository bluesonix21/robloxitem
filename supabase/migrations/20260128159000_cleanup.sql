create or replace function public.cleanup_rate_limits(retention_minutes integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.rate_limit_buckets
  where created_at < now() - make_interval(mins => retention_minutes);
end;
$$;

create or replace function public.cleanup_job_events(retention_days integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.ai_job_events
  where created_at < now() - make_interval(days => retention_days);
end;
$$;
