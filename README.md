# Pro-vertos DevOps Demo

This repository contains a minimal, fast-to-provision DevOps stack for the Pro-vertos MERN app. It includes Terraform infra, Ansible automation, GitHub Actions CI/CD, Nagios monitoring examples, and helper scripts for deploy/start/stop/status/rollback.

Important: secrets and IPs must be provided either from Terraform outputs or via CI secrets. This setup is optimized for fast demo and idempotency.

Quick overview
- Frontend: React app in `/client` — built and deployed to Nginx on `web` host
- Backend: Node.js + Express in `/api` — run by PM2 on `api` host (port 3001)
- Infra: `/infra` Terraform to create 3 EC2s (web, api, nagios)
- Config mgmt: `/ansible` roles and playbooks to install and deploy
- CI/CD: `.github/workflows/deploy.yml` builds and runs `ansible/deploy.yml`
- Monitoring: `/monitoring` contains Nagios config examples

Prerequisites
- AWS account with API keys (if using Terraform)
- GitHub repository with Secrets configured:
  - `SSH_PRIVATE_KEY` — private key for the EC2 user (ec2-user)
  - `EC2_WEB_IP`, `EC2_API_IP`, `EC2_NAGIOS_IP` — public IPs (used by workflow)
  - `MONGODB_URI` — MongoDB Atlas connection string
  - (Optional for Terraform in workflow) `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

Fast demo path (no Terraform):
1. Provision three EC2 instances manually (Amazon Linux 2 / Ubuntu). Save their public IPs.
2. In GitHub > Settings > Secrets, add `EC2_WEB_IP`, `EC2_API_IP`, `EC2_NAGIOS_IP`, `SSH_PRIVATE_KEY`, `MONGODB_URI`.
3. Push a commit to `main` — GitHub Actions will build and deploy automatically.

Full automated path (with Terraform):
1. Edit `/infra/terraform.tfvars` (copy from example) and add `ssh_key_name` if you have an AWS key pair.
2. Run:

```powershell
cd infra
terraform init
terraform apply -auto-approve
```

3. After apply completes, run:

```powershell
terraform output -raw web_public_ip
terraform output -raw api_public_ip
terraform output -raw nagios_public_ip
```

4. Add those IPs to GitHub secrets (EC2_WEB_IP etc.) and `SSH_PRIVATE_KEY` (the PEM for the key pair).
5. Push to `main` to trigger CI/CD.

Using the scripts locally (example):

On your workstation or CI runner (bash/WSL):

```bash
export EC2_WEB_IP=1.2.3.4
export EC2_API_IP=1.2.3.5
export EC2_NAGIOS_IP=1.2.3.6
export SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"
export MONGODB_URI="your-mongo-uri"
./scripts/deploy.sh
./scripts/check_health.sh
./scripts/status.sh
./scripts/stop.sh
./scripts/start.sh
```

Notes and assumptions
- The Ansible roles clone the repository from GitHub at `https://github.com/your-org/Pro-vertos.git` — replace with your repo URL or ensure the EC2 hosts have access to GitHub.
- Nagios installation is simplified for demo and focuses on Debian/Ubuntu. For Amazon Linux / CentOS adapt tasks or set up via official docs.
- The Terraform defaults use Amazon Linux 2 AMIs and t3.micro instances for speed/cost

Security
- Store private keys in GitHub Secrets only. Avoid committing PEM files.

Next steps / improvements
- Add an Application Load Balancer and auto-scaling group for web/api
- Harden Nginx and enable TLS (Let's Encrypt)
- Move Nagios checks to use NRPE installed on agents
- Add unit/integration tests and pipeline gates
