#!/usr/bin/env bash
set -euo pipefail

echo "Smoke test placeholder. Validate public app via ALB once it is reachable."
if [[ -z "${ALB_URL:-}" || "${ALB_URL:-}" == *placeholder* ]]; then
  echo "ALB_URL is not configured; skipping public smoke test."
  exit 0
fi

curl -fsS "${ALB_URL}/health.html" >/dev/null
curl -fsS "${ALB_URL}/version.json" >/dev/null

echo "Public smoke test passed."
