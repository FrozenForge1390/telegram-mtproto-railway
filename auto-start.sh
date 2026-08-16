#!/bin/sh
set -eu

# Make a stable per-service secret when the deployer did not provide a valid one.
# Railway keeps RAILWAY_SERVICE_ID stable across restarts and redeployments.
if ! printf '%s' "${SECRET:-}" | grep -Eq '^[0-9a-f]{32}(,[0-9a-f]{32})*$'; then
  seed="${RAILWAY_SERVICE_ID:-${HOSTNAME:-telegram-mtproxy}}:mtproto-railway-v1"
  SECRET="$(printf '%s' "$seed" | sha256sum | cut -c1-32)"
  export SECRET
  echo "[auto-config] Generated stable per-service SECRET."
else
  echo "[auto-config] Using SECRET supplied through environment variables."
fi

WORKERS="${WORKERS:-2}"
export WORKERS

echo "[auto-config] WORKERS=$WORKERS"

if [ -n "${RAILWAY_TCP_PROXY_DOMAIN:-}" ] && [ -n "${RAILWAY_TCP_PROXY_PORT:-}" ]; then
  echo "[auto-config] Telegram link: https://t.me/proxy?server=${RAILWAY_TCP_PROXY_DOMAIN}&port=${RAILWAY_TCP_PROXY_PORT}&secret=${SECRET}"
  echo "[auto-config] tg link: tg://proxy?server=${RAILWAY_TCP_PROXY_DOMAIN}&port=${RAILWAY_TCP_PROXY_PORT}&secret=${SECRET}"
else
  echo "[auto-config] Create a Railway TCP Proxy for application port 443, then redeploy once to print the final Telegram link."
fi

exec /bin/bash /run.sh
