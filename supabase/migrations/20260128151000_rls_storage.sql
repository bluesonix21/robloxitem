-- RLS for core tables
alter table public.assets enable row level security;
alter table public.ai_jobs enable row level security;

-- assets policies
create policy "assets_select_public_or_owner"
  on public.assets
  for select
  using (
    is_public = true
    or owner_id = auth.uid()
  );

create policy "assets_insert_owner"
  on public.assets
  for insert
  with check (owner_id = auth.uid());

create policy "assets_update_owner"
  on public.assets
  for update
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

create policy "assets_delete_owner"
  on public.assets
  for delete
  using (owner_id = auth.uid());

-- ai_jobs policies
create policy "ai_jobs_select_owner"
  on public.ai_jobs
  for select
  using (user_id = auth.uid());

create policy "ai_jobs_insert_owner"
  on public.ai_jobs
  for insert
  with check (user_id = auth.uid());

create policy "ai_jobs_update_owner"
  on public.ai_jobs
  for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "ai_jobs_delete_owner"
  on public.ai_jobs
  for delete
  using (user_id = auth.uid());

-- Storage buckets
insert into storage.buckets (id, name, public)
values
  ('assets', 'assets', false),
  ('templates', 'templates', true)
on conflict (id) do nothing;

-- Storage object policies
alter table storage.objects enable row level security;

-- assets bucket: private per-user
create policy "assets_read_own"
  on storage.objects
  for select
  using (
    bucket_id = 'assets'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "assets_insert_own"
  on storage.objects
  for insert
  with check (
    bucket_id = 'assets'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "assets_update_own"
  on storage.objects
  for update
  using (
    bucket_id = 'assets'
    and auth.uid()::text = (storage.foldername(name))[1]
  )
  with check (
    bucket_id = 'assets'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "assets_delete_own"
  on storage.objects
  for delete
  using (
    bucket_id = 'assets'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- templates bucket: public read, controlled write
create policy "templates_read_public"
  on storage.objects
  for select
  using (bucket_id = 'templates');

create policy "templates_insert_own"
  on storage.objects
  for insert
  with check (
    bucket_id = 'templates'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "templates_update_own"
  on storage.objects
  for update
  using (
    bucket_id = 'templates'
    and auth.uid()::text = (storage.foldername(name))[1]
  )
  with check (
    bucket_id = 'templates'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "templates_delete_own"
  on storage.objects
  for delete
  using (
    bucket_id = 'templates'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
