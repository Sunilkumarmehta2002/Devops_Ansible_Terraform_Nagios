#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export ANSIBLE_PRIVATE_KEY_FILE=/tmp/provertos_key

if [ -z "${EC2_API_IP:-}" ]; then
  echo "Please set EC2_API_IP and SSH_PRIVATE_KEY environment variables"
  exit 1
fi

echo "$SSH_PRIVATE_KEY" > "$ANSIBLE_PRIVATE_KEY_FILE"
chmod 600 "$ANSIBLE_PRIVATE_KEY_FILE"

cat > "$ROOT_DIR/ansible/inventory.ini" <<INV
[api]
api ansible_host=${EC2_API_IP} ansible_user=ec2-user
INV

echo "Stopping API via PM2 on api host..."
ANSIBLE_PRIVATE_KEY_FILE="$ANSIBLE_PRIVATE_KEY_FILE" ansible -i "$ROOT_DIR/ansible/inventory.ini" api -m shell -a "export HOME=/home/provertos; pm2 stop all || true"

rm -f "$ANSIBLE_PRIVATE_KEY_FILE"

echo "Stop command issued."
