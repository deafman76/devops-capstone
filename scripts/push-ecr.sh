#!/usr/bin/env bash
set -euo pipefail

echo "ECR push placeholder. Configure AWS credentials and repo URIs before enabling this stage."
if [[ -z "${AWS_REGION:-}" ]]; then
  echo "AWS_REGION is not set; using default eu-west-1"
  export AWS_REGION='eu-west-1'
fi

echo "AWS region: ${AWS_REGION}"
echo "App image: ${APP_IMAGE:-<not-set>}"
echo "Proxy image: ${PROXY_IMAGE:-<not-set>}"
