create or replace view public.ai_job_metrics_daily as
select
  date_trunc('day', created_at) as day,
  count(*) as total_jobs,
  count(*) filter (where status = 'SUCCEEDED') as succeeded_jobs,
  count(*) filter (where status = 'FAILED') as failed_jobs,
  sum(credit_cost) as total_credits
from public.ai_jobs
group by 1
order by 1 desc;

revoke all on public.ai_job_metrics_daily from anon, authenticated;
