#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${SUPABASE_URL:-}" ]]; then
  echo "Set SUPABASE_URL in your shell"
  exit 1
fi

FUNCTIONS_URL="${SUPABASE_URL}/functions/v1"

if [[ -z "${JOB_ID:-}" ]]; then
  echo "Set JOB_ID to an existing ai_jobs id"
  exit 1
fi

AUTH_HEADER=""
if [[ -n "${AUTH_TOKEN:-}" ]]; then
  AUTH_HEADER="Authorization: Bearer ${AUTH_TOKEN}"
elif [[ -n "${MESHY_INTERNAL_KEY:-}" ]]; then
  AUTH_HEADER="x-internal-key: ${MESHY_INTERNAL_KEY}"
else
  echo "Set AUTH_TOKEN (user JWT) or MESHY_INTERNAL_KEY for internal dispatch"
  exit 1
fi

curl -sS -X POST "${FUNCTIONS_URL}/meshy-dispatch" \
  -H "Content-Type: application/json" \
  -H "${AUTH_HEADER}" \
  -d "{\"job_id\":\"${JOB_ID}\"}" | jq .

curl -sS "${FUNCTIONS_URL}/meshy-poll?job_id=${JOB_ID}" \
  -H "${AUTH_HEADER}" | jq .
