# Roblox OAuth + Deep Link Setup

This project uses a two-step redirect flow:
1) Roblox redirects back to the Supabase Edge Function callback.
2) The Edge Function redirects to the app deep link (return URL).

## 1) Roblox OAuth App
- **Redirect URI** must be the Edge Function callback:
  - `https://pewdlzrpziltvabaqytk.functions.supabase.co/roblox-oauth-callback`
- **Scopes** recommended:
  - `openid`, `profile`, `asset:read`, `asset:write`

## 2) Supabase Edge Function Return URL
The Edge Function reads the return URL from `app_settings` (or env). Current default:
- `robloxugc://oauth`

## 3) App Schemes (Android/iOS)
The Flutter app already contains native folders under `flutter_app/`.
Ensure the schemes below exist.

### Android (flutter_app/android/app/src/main/AndroidManifest.xml)
Make sure the intent-filter contains:
```
<data android:scheme="robloxugc" android:host="oauth"/>
<data android:scheme="io.supabase.robloxugc" android:host="login-callback"/>
```

### iOS (flutter_app/ios/Runner/Info.plist)
Make sure the URL schemes include:
```
robloxugc
io.supabase.robloxugc
```

## 4) Publish Requirements (Roblox Dashboard)
To publish the OAuth app, Roblox requires:
- Privacy Policy URL
- Terms of Service URL
- Description
- Entry Link
- At least one scope

Use the templates in:
- `docs/privacy-policy.md`
- `docs/terms-of-service.md`
- `docs/roblox-app-publish-checklist.md`
