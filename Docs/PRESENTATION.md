# Pro-vertos DevOps Demo — Presentation Flow

This file walks through a short demo showing Terraform, Ansible, CI/CD and Nagios.

Architecture (ASCII)

  Dev (push) -> GitHub -> Actions (build) -> Ansible (deploy) -> AWS EC2
                                                   ↘ Nagios (monitoring)

Components
- GitHub Actions: builds frontend and backend and triggers Ansible deploy using secrets for SSH.
- Terraform: creates three EC2 instances (web, api, nagios). Use default VPC and public subnets.
- Ansible: idempotent roles to install Node, Nginx, PM2, deploy code and configure Nagios.
- Nagios: simple HTTP/TCP/NRPE checks for the demo.

Demo steps (time boxed ~10-15 minutes)

1) Terraform apply (5 min)
   - Run `terraform init && terraform apply -auto-approve` in `/infra`
   - Show Terraform outputs: web_public_ip, api_public_ip, nagios_public_ip

2) First Ansible deploy (3 min)
   - Push secrets to GitHub (EC2_* and SSH key)
   - Trigger GitHub Actions by pushing a small change or manually run `./scripts/deploy.sh`
   - Show Nginx serving React at `http://<web_public_ip>/`
   - Show API at `http://<api_public_ip>:3001/healthz`

3) Make a small frontend edit (1-2 min)
   - Edit `client/src/pages/Header.jsx` (e.g. change title)
   - Commit & push to `main` → Actions will auto-build & deploy
   - Refresh the page to show changes live

4) Stop API to trigger alert (1 min)
   - Use `./scripts/stop.sh` or stop pm2 on the API host
   - Show Nagios UI (http://<nagios_public_ip>/) showing host/service down

5) Start API to clear alert (1 min)
   - Use `./scripts/start.sh` -> Nagios clears the alert

6) Rollback demo (2 min)
   - Use `./scripts/rollback.sh` to revert to last commit and rebuild
   - Verify website/API restored

Wrap up: discuss next steps — TLS, scaling, more checks, production hardening.
