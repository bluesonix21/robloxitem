insert into public.app_settings (key, value)
values
  ('credit_cost_preview', '10'),
  ('credit_cost_refine', '15'),
  ('credit_cost_remesh', '10'),
  ('rate_job_create_per_minute', '5'),
  ('rate_poll_per_minute', '30')
on conflict (key) do nothing;
