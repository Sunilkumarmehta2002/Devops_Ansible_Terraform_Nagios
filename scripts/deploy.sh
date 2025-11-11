#!/usr/bin/env bash
set -euo pipefail

# export EC2_WEB_IP=44.211.50.228 EC2_API_IP=44.193.199.94 EC2_NAGIOS_IP=3.236.127.159 SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" MONGODB_URI="mongodb+srv://Devops:Super%403000@cluster0.y2ac2hf.mongodb.net/provertos?retryWrites=true&w=majority"
# then: ./scripts/deploy.sh

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export ANSIBLE_PRIVATE_KEY_FILE=/tmp/provertos_key
# ANSIBLE_USER can be set to 'ubuntu' or 'ec2-user' depending on the AMI
ANSIBLE_USER="${ANSIBLE_USER:-ubuntu}"

if [ -z "${EC2_WEB_IP:-}" ] || [ -z "${EC2_API_IP:-}" ] || [ -z "${EC2_NAGIOS_IP:-}" ]; then
  echo "Please set EC2_WEB_IP, EC2_API_IP and EC2_NAGIOS_IP environment variables"
  exit 1
fi

echo "Writing SSH key to $ANSIBLE_PRIVATE_KEY_FILE"
if [ -n "${SSH_PRIVATE_KEY:-}" ]; then
  echo "$SSH_PRIVATE_KEY" > "$ANSIBLE_PRIVATE_KEY_FILE"
else
  # If SSH_PRIVATE_KEY not provided, try a default key file
  if [ -f "$HOME/.ssh/provertos-key.pem" ]; then
    echo "Using existing key $HOME/.ssh/provertos-key.pem"
    cat "$HOME/.ssh/provertos-key.pem" > "$ANSIBLE_PRIVATE_KEY_FILE"
  elif [ -f "$HOME/.ssh/id_rsa" ]; then
    echo "Using existing key $HOME/.ssh/id_rsa"
    cat "$HOME/.ssh/id_rsa" > "$ANSIBLE_PRIVATE_KEY_FILE"
  else
    echo "No SSH_PRIVATE_KEY env var and no key file found at ~/.ssh/provertos-key.pem or ~/.ssh/id_rsa"
    exit 1
  fi
fi
chmod 600 "$ANSIBLE_PRIVATE_KEY_FILE"

echo "Building client locally..."
if [ -d "$ROOT_DIR/client" ]; then
  (cd "$ROOT_DIR/client" && npm ci --silent && npm run build --silent) || echo "Local build failed; proceeding to remote build fallback"
else
  echo "No client directory found to build locally"
fi

cat > "$ROOT_DIR/ansible/inventory.ini" <<INV
[web]
web-server ansible_host=${EC2_WEB_IP} ansible_user=${ANSIBLE_USER}

[api]
api-server ansible_host=${EC2_API_IP} ansible_user=${ANSIBLE_USER}

[nagios]
nagios-server ansible_host=${EC2_NAGIOS_IP} ansible_user=${ANSIBLE_USER}

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

echo "Adding hosts to known_hosts (best-effort)"
ssh-keyscan -H "$EC2_WEB_IP" >> ~/.ssh/known_hosts 2>/dev/null || true
ssh-keyscan -H "$EC2_API_IP" >> ~/.ssh/known_hosts 2>/dev/null || true
ssh-keyscan -H "$EC2_NAGIOS_IP" >> ~/.ssh/known_hosts 2>/dev/null || true

echo "Running ansible deploy playbook..."
ANSIBLE_PRIVATE_KEY_FILE="$ANSIBLE_PRIVATE_KEY_FILE" ansible-playbook -i "$ROOT_DIR/ansible/inventory.ini" "$ROOT_DIR/ansible/deploy.yml" -u "$ANSIBLE_USER" --private-key "$ANSIBLE_PRIVATE_KEY_FILE" --ssh-extra-args='-o StrictHostKeyChecking=no'

echo "Cleaning up temporary key"
rm -f "$ANSIBLE_PRIVATE_KEY_FILE"

echo "Deploy completed."
