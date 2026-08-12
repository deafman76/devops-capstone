#!/usr/bin/env bash
set -euo pipefail

APP_IMAGE="${APP_IMAGE:-local/app:${BUILD_NUMBER:-0}}"
CONTAINER_NAME="jenkins-test-${BUILD_NUMBER:-0}"
HOST_PORT="${HOST_PORT:-8081}"

cleanup() {
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker run -d --rm --name "$CONTAINER_NAME" -p "${HOST_PORT}:8080" "$APP_IMAGE"

for _ in $(seq 1 20); do
  if curl -fsS "http://127.0.0.1:${HOST_PORT}/health.html" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

curl -fsS "http://127.0.0.1:${HOST_PORT}/health.html" | grep -qi 'OK'
curl -fsS "http://127.0.0.1:${HOST_PORT}/version.json" | jq -e '.version and .gitCommit and .buildNumber and .color'

echo "Local image validation passed on ${APP_IMAGE}"
