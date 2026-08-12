#!/usr/bin/env bash
set -euo pipefail

BUILD_NUMBER="${BUILD_NUMBER:-0}"
SHORT_SHA="${SHORT_SHA:-$(git rev-parse --short=7 HEAD 2>/dev/null || echo local)}"
COLOR="${COLOR:-green}"
VERSION="${BUILD_NUMBER}-${SHORT_SHA}"

sed -i.bak \
  -e "s|__VERSION__|${VERSION}|g" \
  -e "s|__GIT_COMMIT__|${SHORT_SHA}|g" \
  -e "s|__BUILD_NUMBER__|${BUILD_NUMBER}|g" \
  -e "s|__COLOR__|${COLOR}|g" \
  app/version.json

rm -f app/version.json.bak

echo "Prepared version metadata: ${VERSION} (${COLOR})"
