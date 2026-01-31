alter table public.assets
  add constraint assets_source_job_id_fkey
  foreign key (source_job_id) references public.ai_jobs (id) on delete set null;
