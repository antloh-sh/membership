#!/usr/bin/env bash
# Simple ping script for Supabase RPC healthcheck
# Expects SUPABASE_URL and SUPABASE_ANON_KEY to be set in the environment.
# Does not echo secrets to logs.

set -euo pipefail

SUPABASE_URL="${SUPABASE_URL:-}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"

if [[ -z "$SUPABASE_URL" || -z "$SUPABASE_ANON_KEY" ]]; then
  echo "ERROR: SUPABASE_URL and SUPABASE_ANON_KEY must be set"
  exit 2
fi

RPC_PATH="/rest/v1/rpc/healthcheck"
URL="${SUPABASE_URL%/}${RPC_PATH}"

# Function to call RPC and print status + body (without revealing keys)
call_rpc() {
  http_status=$(curl -sS -w "%{http_code}" -o /tmp/healthcheck_response.txt \
    -X POST "$URL" \
    -H "Content-Type: application/json" \
    -H "apikey: ${SUPABASE_ANON_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
    --data '{}') || curl_exit=$?
  body=$(cat /tmp/healthcheck_response.txt || true)
  echo "HTTP ${http_status}"
  redacted_body="${body//${SUPABASE_ANON_KEY}/REDACTED}"
  echo "BODY: ${redacted_body}"
  rm -f /tmp/healthcheck_response.txt
  # Treat any 2xx as success
  if [[ "${http_status}" =~ ^2[0-9]{2}$ ]]; then
    return 0
  else
    return 1
  fi
}

# Try once, retry after short backoff if non-2xx
if call_rpc; then
  echo "Healthcheck succeeded."
  exit 0
else
  echo "Healthcheck failed, retrying in 10s..."
  sleep 10
  if call_rpc; then
    echo "Healthcheck succeeded on retry."
    exit 0
  else
    echo "Healthcheck failed after retry."
    exit 1
  fi
fi
