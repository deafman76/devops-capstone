#!/usr/bin/env bash
set -euo pipefail

echo "Health-check GREEN placeholder. Verify target via Cloud Map / ALB once environment is live."
if [[ -z "${APP_SERVICE_GREEN:-}" ]]; then
  echo "GREEN service name is not set; skipping direct health request."
  exit 0
fi
