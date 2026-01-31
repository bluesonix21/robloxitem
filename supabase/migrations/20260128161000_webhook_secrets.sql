create table public.user_provider_secrets (
  user_id uuid not null references auth.users (id) on delete cascade,
  provider public.provider_type not null,
  webhook_secret text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, provider)
);

create trigger set_user_provider_secrets_updated_at
before update on public.user_provider_secrets
for each row
execute function public.set_updated_at();

alter table public.user_provider_secrets enable row level security;

create policy "user_provider_secrets_owner"
  on public.user_provider_secrets
  for select
  using (user_id = auth.uid());

create policy "user_provider_secrets_owner_insert"
  on public.user_provider_secrets
  for insert
  with check (user_id = auth.uid());

create policy "user_provider_secrets_owner_update"
  on public.user_provider_secrets
  for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
