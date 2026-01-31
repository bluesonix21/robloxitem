revoke all on public.credit_accounts from anon, authenticated;
revoke all on public.credit_ledger from anon, authenticated;

create policy "credit_accounts_select_owner"
  on public.credit_accounts
  for select
  using (user_id = auth.uid());

create policy "credit_ledger_select_owner"
  on public.credit_ledger
  for select
  using (user_id = auth.uid());
