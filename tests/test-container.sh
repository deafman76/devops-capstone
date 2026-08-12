#!/bin/bash

set -e

BASE_URL="${1:-http://localhost:8080}"

echo "Testing application: $BASE_URL"

echo "1. Testing main page..."
curl -f "$BASE_URL/" > /dev/null
echo "PASS"

echo "2. Testing health endpoint..."
curl -f "$BASE_URL/health.html" > /dev/null
echo "PASS"

echo "3. Testing version endpoint..."
curl -f "$BASE_URL/version.json" > /dev/null
echo "PASS"

echo "All application tests passed."

