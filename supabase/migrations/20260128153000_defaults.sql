alter table public.assets alter column owner_id set default auth.uid();
alter table public.ai_jobs alter column user_id set default auth.uid();
