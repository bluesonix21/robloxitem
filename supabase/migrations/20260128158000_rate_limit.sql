create table public.rate_limit_buckets (
  key text not null,
  bucket bigint not null,
  count integer not null default 0,
  created_at timestamptz not null default now(),
  primary key (key, bucket)
);

revoke all on public.rate_limit_buckets from anon, authenticated;

create or replace function public.check_rate_limit(
  key text,
  window_seconds integer,
  max_requests integer
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  _bucket bigint;
  _count integer;
begin
  if window_seconds is null or window_seconds <= 0 then
    raise exception 'window_seconds must be > 0';
  end if;
  if max_requests is null or max_requests <= 0 then
    raise exception 'max_requests must be > 0';
  end if;

  _bucket := floor(extract(epoch from now()) / window_seconds);

  insert into public.rate_limit_buckets (key, bucket, count)
  values (key, _bucket, 1)
  on conflict (key, bucket)
  do update set count = public.rate_limit_buckets.count + 1
  returning count into _count;

  return _count <= max_requests;
end;
$$;

grant execute on function public.check_rate_limit(text, integer, integer) to authenticated;
