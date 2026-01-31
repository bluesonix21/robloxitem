# RobloxItem Backend (Supabase + Meshy)

Backend for Roblox UGC generation using Meshy's async pipeline (preview -> refine -> remesh) with Supabase Postgres, Storage, and Edge Functions.

## Quickstart

1. **Start Supabase locally**
   ```bash
   supabase start
   ```

2. **Set environment variables** (copy `.env.example` to `.env` and fill)
   - `MESHY_API_KEY` (required)
   - `MESHY_INTERNAL_KEY` (shared secret for internal dispatch)
   - `MESHY_WEBHOOK_SECRET` (optional, for webhook verification)
   - `TRIPO_API_KEY` (required for Tripo)
   - `ASSET_FETCH_KEY` (server-to-server asset fetch)
   - `ROBLOX_OAUTH_TOKEN` (Open Cloud OAuth token for publishing)
   - `ROBLOX_OAUTH_CLIENT_ID`, `ROBLOX_OAUTH_CLIENT_SECRET`, `ROBLOX_OAUTH_REDIRECT_URI` (for per-user OAuth)
   - `ASSET_MAX_MB`, `ASSET_SIGNED_URL_TTL` (optional storage import settings)

3. **Configure app settings**
   ```sql
   insert into public.app_settings (key, value) values
     ('meshy_dispatch_url', 'http://localhost:54323/functions/v1/meshy-dispatch'),
     ('tripo_dispatch_url', 'http://localhost:54323/functions/v1/tripo-dispatch'),
     ('meshy_internal_key', 'YOUR_INTERNAL_SECRET')
  on conflict (key) do update set value = excluded.value;
   ```

4. **Create a Meshy webhook** (optional)
   - Point Meshy webhook to: `https://<PROJECT>.functions.supabase.co/meshy-webhook`
   - Use header: `x-meshy-webhook-secret: <MESHY_WEBHOOK_SECRET>`

## Data Model

### `assets`
Stores generated or edited assets.

- `mesh_url`, `texture_url`, `pbr_*` for final output
- `source_job_id` links the generating job
- `is_public` for template sharing

### `ai_jobs`
Tracks Meshy pipeline stages.

- `stage`: `PREVIEW` -> `REFINE` -> `REMESH`
- `status`: `QUEUED` -> `IN_PROGRESS` -> `SUCCEEDED/FAILED`
- `request_payload`: JSON from client (prompt, refine/remesh config)
- `result_payload`: Meshy task responses per stage

### `ai_job_events`
Audit log for stage transitions and outcomes.

- `stage`, `status`, `provider_task_id`, `payload`

## Pipeline (POST -> POLL -> GET)

1. **Create job** (client inserts row)
   ```sql
   insert into public.ai_jobs (user_id, request_payload)
   values (
     auth.uid(),
     '{
        "prompt": "cyberpunk katana",
        "art_style": "realistic",
        "refine": { "enable_pbr": true },
        "remesh": { "enabled": true, "target_polycount": 3500, "target_formats": ["fbx"] }
      }'
   )
   returning id;
   ```

   Or use the RPC helper:
   ```sql
   select * from public.create_ai_job(
     '{"prompt":"cyberpunk katana","art_style":"realistic","refine":{"enable_pbr":true},"remesh":{"enabled":true,"target_polycount":3500,"target_formats":["fbx"]}}',
     true,
     'Cyberpunk Katana',
     'UGC accessory'
   );
   ```

2. **Dispatch**
   - Automatic if `meshy_dispatch_url` is configured (pg_net trigger).
   - Or call manually:
     ```http
     POST /functions/v1/meshy-dispatch
     Headers:
       x-internal-key: <MESHY_INTERNAL_KEY>   # or Authorization: Bearer <user JWT>
     Body:
       { "job_id": "<uuid>" }
     ```

3. **Poll**
   ```http
   GET /functions/v1/meshy-poll?job_id=<uuid>
   Headers:
     Authorization: Bearer <user JWT>   # or x-internal-key for internal calls
   ```

4. **Completion**
   - `ai_jobs.status = SUCCEEDED`
   - `assets` updated with Meshy URLs (if `asset_id` provided)

Provider routing:
- `provider=MESHY` uses `meshy-dispatch`/`meshy-poll`.
- `provider=TRIPO` uses `tripo-dispatch`/`tripo-poll` and `convert_model` for FBX/face_limit.

## Edge Functions

- **`meshy-dispatch`**: Starts Meshy preview task.
- **`meshy-poll`**: Polls status and advances stages.
- **`meshy-webhook`**: Webhook entry to advance jobs automatically.
- **`tripo-dispatch`**: Starts Tripo preview task.
- **`tripo-poll`**: Polls Tripo status and advances stages.
- **`asset-fetch`**: Read-only asset API for Roblox server integration.
- **`job-create`**: Authenticated job creation helper.
- **`roblox-publish`**: Publish finalized assets to Roblox Open Cloud.
- **`roblox-publish-status`**: Poll Roblox Open Cloud publish operations.
- **`roblox-oauth-start`**: Start per-user Roblox OAuth2 flow.
- **`roblox-oauth-callback`**: OAuth2 callback endpoint.
- **`job-status`**: Fetch a job plus its events.
- **`job-cancel`**: Cancel a job and refund credits.
- **`credits`**: Fetch credit balance and ledger.
- **`webhook-secret`**: Create/rotate per-user Meshy webhook secret.

## RPC Helpers

- `public.create_ai_job(request_payload jsonb, create_asset boolean, asset_title text, asset_description text, provider public.provider_type)`
- `public.cancel_ai_job(job_id uuid)`
- `public.create_ai_job_with_credits(request_payload jsonb, create_asset boolean, asset_title text, asset_description text, asset_id uuid, provider public.provider_type)`
- `public.get_public_settings()`

## Credits

Credits are reserved at job creation and refunded on failure/cancel.

- Defaults: preview 10, refine 15, remesh 10 (total 35)
- Override via `app_settings` keys:
  - `credit_cost_preview`
  - `credit_cost_refine`
  - `credit_cost_remesh`

## Rate Limits

Defaults (override via `app_settings`):

- `rate_job_create_per_minute` (default 5)
- `rate_poll_per_minute` (default 30)
- `rate_roblox_publish_per_minute` (default 2)
Defaults are seeded on first migration via `20260128163500_settings_defaults.sql`.

## Roblox Publish

`roblox-publish` uses `ROBLOX_OAUTH_TOKEN` (Open Cloud OAuth token) to upload assets to Roblox.
Store the token securely and rotate as needed.

The Open Cloud assets API expects a multipart form with a JSON `request` part and a `fileContent` part for the mesh file.

For per-user publishing, run `roblox-oauth-start` to initiate OAuth and point the OAuth redirect URL to
`roblox-oauth-callback`. Tokens are stored in `roblox_oauth_tokens` and refreshed automatically.

## Webhook Secrets

Use `webhook-secret` to store a per-user Meshy webhook secret in `user_provider_secrets`.
`meshy-webhook` validates `x-meshy-webhook-secret` when present.

## Metrics

- Daily view: `public.ai_job_metrics_daily`

## Maintenance

Use these RPCs from a cron job:

- `public.cleanup_rate_limits(retention_minutes integer)`
- `public.cleanup_job_events(retention_days integer)`
- `public.cleanup_roblox_oauth_states(retention_minutes integer)`
### asset-fetch
```http
GET /functions/v1/asset-fetch?id=<asset_id>
Headers:
  x-asset-fetch-key: <ASSET_FETCH_KEY>   # optional, required if asset not public
```

### tripo-dispatch (internal)
```http
POST /functions/v1/tripo-dispatch
Headers:
  x-internal-key: <MESHY_INTERNAL_KEY>
Body:
  { "job_id": "<uuid>" }
```

### tripo-poll
```http
GET /functions/v1/tripo-poll?job_id=<uuid>
Headers:
  Authorization: Bearer <user JWT>   # or x-internal-key for internal calls
```

### job-create
```http
POST /functions/v1/job-create
Headers:
  Authorization: Bearer <user JWT>
Body:
  {
    "prompt": "cyberpunk katana",
    "art_style": "realistic",
    "provider": "MESHY",
    "refine": { "enable_pbr": true },
    "remesh": { "enabled": true, "target_polycount": 3500, "target_formats": ["fbx"] },
    "create_asset": true,
    "asset_title": "Cyberpunk Katana",
    "asset_description": "UGC accessory"
  }
```

Notes:
- Set `provider: "TRIPO"` or `requires_rig: true` to route to Tripo.
- Set `store_assets: false` to keep provider URLs without downloading into Storage.

### roblox-publish
```http
POST /functions/v1/roblox-publish
Headers:
  Authorization: Bearer <user JWT>
Body:
  {
    "asset_id": "<uuid>",
    "name": "Cyberpunk Katana",
    "description": "UGC accessory",
    "asset_type": "Model",
    "creator_user_id": "<roblox_user_id>",
    "creator_group_id": "<optional_group_id>"
  }
```

### roblox-publish-status
```http
GET /functions/v1/roblox-publish-status?publish_job_id=<uuid>
Headers:
  Authorization: Bearer <user JWT>
```

### job-status
```http
GET /functions/v1/job-status?job_id=<uuid>
Headers:
  Authorization: Bearer <user JWT>
```

### job-cancel
```http
POST /functions/v1/job-cancel
Headers:
  Authorization: Bearer <user JWT>
Body:
  { "job_id": "<uuid>" }
```

### credits
```http
GET /functions/v1/credits?limit=20
Headers:
  Authorization: Bearer <user JWT>
```

### webhook-secret
```http
POST /functions/v1/webhook-secret
Headers:
  Authorization: Bearer <user JWT>
Body:
  { "provider": "MESHY", "rotate": true }
```

### roblox-oauth-start
```http
POST /functions/v1/roblox-oauth-start
Headers:
  Authorization: Bearer <user JWT>
Body:
  { "scopes": ["asset:write"] }
```

### roblox-oauth-callback
```http
GET /functions/v1/roblox-oauth-callback?code=<code>&state=<state>
```

### public settings
```http
POST /rest/v1/rpc/get_public_settings
Headers:
  Authorization: Bearer <user JWT>
Body: {}
```

## Security

- RLS enabled on core tables and Storage.
- `app_settings` is locked down (no anon/auth access).
- Internal calls use `x-internal-key`.
- `asset-fetch` requires `x-asset-fetch-key` unless asset is public or user is owner.

## Storage Buckets

- `assets/<user_id>/...` (private per-user)
- `templates/<user_id>/...` (public read)

Meshy/Tripo outputs are downloaded into `assets/` when `store_assets` is true (default). `asset-fetch` returns signed URLs.

## Local Function URLs

- `http://localhost:54323/functions/v1/meshy-dispatch`
- `http://localhost:54323/functions/v1/meshy-poll`
- `http://localhost:54323/functions/v1/meshy-webhook`
- `http://localhost:54323/functions/v1/tripo-dispatch`
- `http://localhost:54323/functions/v1/tripo-poll`
- `http://localhost:54323/functions/v1/asset-fetch`
- `http://localhost:54323/functions/v1/roblox-publish`
- `http://localhost:54323/functions/v1/roblox-publish-status`
- `http://localhost:54323/functions/v1/roblox-oauth-start`
- `http://localhost:54323/functions/v1/roblox-oauth-callback`
- `http://localhost:54323/functions/v1/job-status`
- `http://localhost:54323/functions/v1/job-cancel`
- `http://localhost:54323/functions/v1/credits`
- `http://localhost:54323/functions/v1/webhook-secret`
