insert into public.app_settings (key, value)
values ('rate_roblox_publish_per_minute', '2')
on conflict (key) do nothing;
