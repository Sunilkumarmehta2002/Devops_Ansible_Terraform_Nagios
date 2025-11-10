#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export ANSIBLE_PRIVATE_KEY_FILE=/tmp/provertos_key

if [ -z "${EC2_API_IP:-}" ] || [ -z "${EC2_WEB_IP:-}" ]; then
  echo "Please set EC2_API_IP, EC2_WEB_IP and SSH_PRIVATE_KEY environment variables"
  exit 1
fi

echo "$SSH_PRIVATE_KEY" > "$ANSIBLE_PRIVATE_KEY_FILE"
chmod 600 "$ANSIBLE_PRIVATE_KEY_FILE"

cat > "$ROOT_DIR/ansible/inventory.ini" <<INV
[web]
web ansible_host=${EC2_WEB_IP} ansible_user=ec2-user

[api]
api ansible_host=${EC2_API_IP} ansible_user=ec2-user
INV

echo "Rolling back API and web to previous commit (git reset --hard HEAD~1)"

# API rollback
ANSIBLE_PRIVATE_KEY_FILE="$ANSIBLE_PRIVATE_KEY_FILE" ansible -i "$ROOT_DIR/ansible/inventory.ini" api -m shell -a "cd /opt/provertos && git reset --hard HEAD~1 && cd api && npm ci && pm2 startOrReload ecosystem.config.js"

# Web rollback (rebuild client)
ANSIBLE_PRIVATE_KEY_FILE="$ANSIBLE_PRIVATE_KEY_FILE" ansible -i "$ROOT_DIR/ansible/inventory.ini" web -m shell -a "cd /opt/provertos && git reset --hard HEAD~1 && cd client && npm ci && npm run build && rsync -a --delete build/ /var/www/html/ && systemctl reload nginx || true"

rm -f "$ANSIBLE_PRIVATE_KEY_FILE"

echo "Rollback executed. Verify with ./scripts/status.sh"
