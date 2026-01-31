# Roblox OAuth App Publish Checklist

Use this checklist in the Roblox Creator Dashboard before publishing your OAuth app.

## Required Fields
1) **Privacy Policy URL**
   - Host `docs/privacy-policy.md` on your site and link it here.
2) **Terms of Service URL**
   - Host `docs/terms-of-service.md` on your site and link it here.
3) **Description**
   - Suggested description:
     "Roblox UGC Creator lets users generate 3D assets with AI, preview them in Roblox, and publish via Open Cloud. It requires OAuth access to read and write assets on behalf of the user."
4) **Entry Link**
   - Use a landing page for the app (e.g., https://yourdomain.com/roblox-ugc-creator).
5) **Scopes**
   - `openid`, `profile`, `asset:read`, `asset:write`

## Notes
- While unpublished, Roblox only allows up to 10 users to authorize the app.
- Ensure the redirect URI is set to:
  `https://pewdlzrpziltvabaqytk.functions.supabase.co/roblox-oauth-callback`
- The return URL (deep link) is:
  `robloxugc://oauth`

Replace placeholder URLs before submission.
