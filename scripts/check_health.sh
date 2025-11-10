#!/usr/bin/env bash
set -euo pipefail

if [ -z "${EC2_WEB_IP:-}" ] || [ -z "${EC2_API_IP:-}" ]; then
  echo "Please set EC2_WEB_IP and EC2_API_IP environment variables"
  exit 1
fi

echo "Checking web root: http://${EC2_WEB_IP}/"
curl -fsS --max-time 10 "http://${EC2_WEB_IP}/" && echo "OK" || echo "WEB FAIL"

echo "Checking API /healthz: http://${EC2_API_IP}:3001/healthz"
curl -fsS --max-time 10 "http://${EC2_API_IP}:3001/healthz" && echo "OK" || echo "API FAIL"
