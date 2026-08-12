#!/usr/bin/env bash
set -euo pipefail

echo "Proxy switch placeholder. Only switch traffic after the GREEN health check succeeds."
if [[ -z "${PROXY_SERVICE:-}" ]]; then
  echo "Proxy service name is not set; no upstream change applied."
  exit 0
fi
