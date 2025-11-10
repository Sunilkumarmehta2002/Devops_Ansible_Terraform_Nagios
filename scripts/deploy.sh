#!/usr/bin/env bash
set -euo pipefail

# Usage: export EC2_WEB_IP=1.2.3.4 EC2_API_IP=1.2.3.5 EC2_NAGIOS_IP=1.2.3.6 SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" MONGODB_URI="<uri>"
# then: ./scripts/deploy.sh

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export ANSIBLE_PRIVATE_KEY_FILE=/tmp/provertos_key

if [ -z "${EC2_WEB_IP:-}" ] || [ -z "${EC2_API_IP:-}" ] || [ -z "${EC2_NAGIOS_IP:-}" ]; then
  echo "Please set EC2_WEB_IP, EC2_API_IP and EC2_NAGIOS_IP environment variables"
  exit 1
fi

echo "Writing SSH key to $ANSIBLE_PRIVATE_KEY_FILE"
echo "$SSH_PRIVATE_KEY" > "$ANSIBLE_PRIVATE_KEY_FILE"
chmod 600 "$ANSIBLE_PRIVATE_KEY_FILE"

echo "Building client locally..."
if [ -d "$ROOT_DIR/client" ]; then
  (cd "$ROOT_DIR/client" && npm ci --silent && npm run build --silent) || echo "Local build failed; proceeding to remote build fallback"
else
  echo "No client directory found to build locally"
fi

cat > "$ROOT_DIR/ansible/inventory.ini" <<INV
[web]
web ansible_host=${EC2_WEB_IP} ansible_user=ec2-user

[api]
api ansible_host=${EC2_API_IP} ansible_user=ec2-user

[nagios]
nagios ansible_host=${EC2_NAGIOS_IP} ansible_user=ec2-user

[all:vars]
ansible_python_interpreter=/usr/bin/python3
INV

mkdir -p "$ROOT_DIR/ansible/group_vars"
cat > "$ROOT_DIR/ansible/group_vars/all.yml" <<YML
ansible_become: true
node_version: "18.x"
app_user: provertos
deploy_dir: /opt/provertos
react_build_dir: /opt/provertos/client/build
api_port: 3001
mongodb_uri: "${MONGODB_URI:-}"
cors_origin: "http://${EC2_WEB_IP}"
YML

echo "Running ansible deploy playbook..."
ANSIBLE_PRIVATE_KEY_FILE="$ANSIBLE_PRIVATE_KEY_FILE" ansible-playbook -i "$ROOT_DIR/ansible/inventory.ini" "$ROOT_DIR/ansible/deploy.yml" --ssh-extra-args='-o StrictHostKeyChecking=no'

echo "Cleaning up temporary key"
rm -f "$ANSIBLE_PRIVATE_KEY_FILE"

echo "Deploy completed."
