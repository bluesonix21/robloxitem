alter table public.roblox_publish_jobs
  add column if not exists operation_id text,
  add column if not exists operation_path text;
