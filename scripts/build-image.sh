#!/usr/bin/env bash
set -euo pipefail

APP_IMAGE="${APP_IMAGE:-local/app:${BUILD_NUMBER:-0}}"
PROXY_IMAGE="${PROXY_IMAGE:-local/proxy:${BUILD_NUMBER:-0}}"
APP_DOCKERFILE="${APP_DOCKERFILE:-docker/Dockerfile}"
PROXY_DOCKERFILE="${PROXY_DOCKERFILE:-docker/proxy.Dockerfile}"

if [[ ! -f "$APP_DOCKERFILE" ]]; then
  echo "Application Dockerfile not found: $APP_DOCKERFILE" >&2
  exit 1
fi

docker build -f "$APP_DOCKERFILE" -t "$APP_IMAGE" .

if [[ -f "$PROXY_DOCKERFILE" ]]; then
  docker build -f "$PROXY_DOCKERFILE" -t "$PROXY_IMAGE" .
else
  echo "No separate proxy Dockerfile found; proxy build skipped."
fi

echo "Built app image: $APP_IMAGE"
if [[ -f "$PROXY_DOCKERFILE" ]]; then
  echo "Built proxy image: $PROXY_IMAGE"
fi
