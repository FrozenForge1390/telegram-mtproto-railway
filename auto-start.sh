#!/bin/sh
set -eu

# Project-level default: deployment works with zero Railway variables.
# Anyone deploying this public repository receives this same project secret.
DEFAULT_SECRET="916d568abce960c5b03d8b77e103388b"

if printf '%s' "${SECRET:-}" | grep -Eq '^[0-9a-f]{32}(,[0-9a-f]{32})*$'; then
  echo "[auto-config] Using optional SECRET supplied through Railway variables."
else
  SECRET="$DEFAULT_SECRET"
  export SECRET
  echo "[auto-config] Using the built-in project SECRET; no Railway variable is required."
fi

WORKERS="${WORKERS:-2}"
export WORKERS

echo "[auto-config] SECRET=$SECRET"
echo "[auto-config] WORKERS=$WORKERS"

if [ -n "${RAILWAY_TCP_PROXY_DOMAIN:-}" ] && [ -n "${RAILWAY_TCP_PROXY_PORT:-}" ]; then
  echo "[auto-config] Telegram link: https://t.me/proxy?server=${RAILWAY_TCP_PROXY_DOMAIN}&port=${RAILWAY_TCP_PROXY_PORT}&secret=${SECRET}"
  echo "[auto-config] tg link: tg://proxy?server=${RAILWAY_TCP_PROXY_DOMAIN}&port=${RAILWAY_TCP_PROXY_PORT}&secret=${SECRET}"
else
  echo "[auto-config] Create one Railway TCP Proxy for application port 443."
fi

exec /bin/bash /run.sh
