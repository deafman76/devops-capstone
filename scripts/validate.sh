#!/usr/bin/env bash
set -euo pipefail

for required in \
  app/index.html \
  app/health.html \
  app/version.json \
  docker/Dockerfile \
  docker/nginx-app.conf
 do
  if [[ ! -f "$required" ]]; then
    echo "Missing required file: $required" >&2
    exit 1
  fi
done

if ! grep -q '__VERSION__' app/version.json; then
  echo 'version.json is missing placeholder metadata markers' >&2
  exit 1
fi

echo 'Repository validation passed.'
