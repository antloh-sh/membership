#!/usr/bin/env bash
## Supabase real-activity healthcheck
## Calls an RPC that queries members with birthdays this month

set -euo pipefail

# ====== REQUIRED ENV VARS ======
SUPABASE_URL="${SUPABASE_URL:-}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"

# ====== RPC ENDPOINT ======
RPC_NAME="members_with_birthday_this_month"
URL="$SUPABASE_URL/rest/v1/rpc/$RPC_NAME"

# ====== VALIDATION ======
if [[ -z "$SUPABASE_URL" || -z "$SUPABASE_ANON_KEY" ]]; then
  echo "ERROR: SUPABASE_URL and SUPABASE_ANON_KEY must be set"
  exit 2
fi

call_query() {
  echo "Calling RPC: $RPC_NAME"

  http_status=$(
    curl -sS -w "%{http_code}" \
      -o /tmp/healthcheck_response.json \
      -X POST "$URL" \
      -H "Content-Type: application/json" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Authorization: Bearer $SUPABASE_ANON_KEY"
  )

  body="$(cat /tmp/healthcheck_response.json || true)"
  rm -f /tmp/healthcheck_response.json

  echo "HTTP status: $http_status"

  if [[ "$http_status" =~ ^2 ]]; then
    echo "RPC call succeeded."

    # Optional visibility (safe even if jq isn't installed)
    if command -v jq >/dev/null 2>&1; then
      echo "Rows returned: $(echo "$body" | jq length)"
    else
      echo "Response received (jq not installed)."
    fi

    return 0
  else
    echo "RPC call failed. Response body:"
    echo "$body"
    return 1
  fi
}

# ====== EXECUTION (RUN ONCE, RETRY ONCE) ======
if call_query; then
  echo "Healthcheck succeeded."
  exit 0
else
  echo "Healthcheck failed, retrying in 10 seconds..."
  sleep 10

  if call_query; then
    echo "Healthcheck succeeded on retry."
    exit 0
  else
    echo "Healthcheck failed after retry."
    exit 1
  fi
fi
