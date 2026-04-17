#!/usr/bin/env bash
#
# Supabase real-activity healthcheck
# Reads from public.activities to generate legitimate DB activity
#

set -euo pipefail

SUPABASE_URL="${SUPABASE_URL:-}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"

TABLE_NAME="activities"
COLUMN_NAME="id"

if [[ -z "$SUPABASE_URL" || -z "$SUPABASE_ANON_KEY" ]]; then
  echo "ERROR: SUPABASE_URL and SUPABASE_ANON_KEY must be set"
  exit 2
fi

URL="${SUPABASE_URL}/rest/v1/${TABLE_NAME}?select=${COLUMN_NAME}&limit=1"

call_query() {
  http_status=$(
    curl -sS -w "%{http_code}" \
      -o /tmp/healthcheck_response.txt \
      -X GET "$URL" \
      -H "Content-Type: application/json" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Authorization: Bearer $SUPABASE_ANON_KEY"
  ) || return 1

  body="$(cat /tmp/healthcheck_response.txt || true)"
  rm -f /tmp/healthcheck_response.txt

  echo "HTTP $http_status"

  if [[ "$http_status" =~ ^2 ]]; then
    return 0
  else
    echo "BODY: $body"
    return 1
  fi
}

# Run once, retry once
if call_query; then
  echo "Healthcheck succeeded (activities table read)."
  exit 0
else
  echo "Healthcheck failed, retrying in 10s..."
  sleep 10
  if call_query; then
    echo "Healthcheck succeeded on retry."
    exit 0
  else
    echo "Healthcheck failed after retry."
    exit 1
  fi
fi
