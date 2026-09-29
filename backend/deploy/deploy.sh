#!/usr/bin/env bash
# Deploy the Fashion Store API to the VPS (ssh alias: panha).
#
#   ./deploy.sh          rsync code + deploy/.env, rebuild, verify
#   ./deploy.sh --env    env-only change: no rsync, no --build
#   ./deploy.sh --logs   tail the container logs
#
# Server side (first time only): see deploy/RUNBOOK.md
set -euo pipefail

HOST=panha
# Quoted on purpose: unquoted, bash would expand ~ against the LOCAL home dir
# and rsync would try to write to /Users/you/fashion-api on the server.
REMOTE='~/fashion-api'
API_HOST=https://fashionapp.api.hpn.world
CONTAINER=fashion-api

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$(dirname "$SCRIPT_DIR")"

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

sync_code() {
  log "Rsync backend -> ${HOST}:${REMOTE}"
  rsync -avz --delete \
    --exclude='.git' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.venv' \
    --exclude='.env' \
    --exclude='*.db' \
    --exclude='data/' \
    "$BACKEND_DIR/" "${HOST}:${REMOTE}/"

  # Two files must exist on the server before it can serve anything, and
  # --delete would remove them if the server had them and the Mac didn't.
  # They live in the repo, so it doesn't.
  ssh "$HOST" "mkdir -p ${REMOTE}/deploy/data"

  # .env is excluded above on purpose — the server owns the secrets.
  log "Rsync production .env (secrets) -> ${HOST}:${REMOTE}/deploy/.env"
  scp "$SCRIPT_DIR/.env" "${HOST}:${REMOTE}/deploy/.env"
}

rebuild() {
  log "Build + start container"
  ssh "$HOST" "cd ${REMOTE}/deploy && docker compose up -d --build"
}

recreate() {
  log "Recreate container (no rebuild — .env only)"
  ssh "$HOST" "cd ${REMOTE}/deploy && docker compose up -d --force-recreate"
}

verify() {
  log "Container status"
  ssh "$HOST" "docker ps --filter name=${CONTAINER} --format '{{.Names}}  {{.Status}}  {{.Ports}}'"

  log "Startup logs (tracebacks would show here)"
  ssh "$HOST" "docker logs --tail 30 ${CONTAINER}"

  log "Local health (server side)"
  ssh "$HOST" "curl -fsS http://127.0.0.1:8001/api/products | head -c 200; echo"

  log "Public health (${API_HOST})"
  curl -fsS "${API_HOST}/api/products" | head -c 200; echo
  curl -fsS -o /dev/null -w '  /docs -> HTTP %{http_code}\n' "${API_HOST}/docs"

  log "Security check — direct :8001 from the internet must NOT be reachable"
  curl -m 5 -sS -o /dev/null -w '  169.58.139.98:8001 -> %{http_code}\n' \
    http://169.58.139.98:8001/api/products || echo "  refused/timeout — good"
}

case "${1:-}" in
  --env)
    recreate
    verify
    ;;
  --logs)
    ssh "$HOST" "docker logs --tail 100 -f ${CONTAINER}"
    ;;
  "")
    sync_code
    rebuild
    verify
    ;;
  *)
    echo "usage: $0 [--env|--logs]" >&2
    exit 1
    ;;
esac

log "Done."
