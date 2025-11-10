# 🚀 Pro-vertos Complete Demo Guide

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [DevOps Components Implemented](#devops-components-implemented)
3. [Setup & Installation](#setup--installation)
4. [Running the Project](#running-the-project)
5. [Demo Flow](#demo-flow)
6. [Verification & Testing](#verification--testing)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 Project Overview

**Pro-vertos** is a full-stack MERN event management application with complete DevOps automation.

### Application Features
- User authentication (Register/Login)
- Event creation and management
- Ticket booking system
- QR code generation for tickets
- Event browsing and search

### Tech Stack
- **Frontend**: React 18 + Vite + TailwindCSS
- **Backend**: Node.js + Express + MongoDB
- **Database**: MongoDB Atlas
- **Infrastructure**: AWS EC2 (3 instances)
- **IaC**: Terraform
- **Config Management**: Ansible
- **CI/CD**: GitHub Actions
- **Monitoring**: Nagios
- **Process Manager**: PM2
- **Web Server**: Nginx

---

## 🛠️ DevOps Components Implemented

### 1. **Infrastructure as Code (Terraform)** ✅
**Location**: `/infra/`

**What it does**:
- Provisions 3 EC2 instances (web, api, nagios)
- Creates security groups with required ports
- Configures networking and public IPs
- Uses Amazon Linux 2 AMIs

**Files**:
- `main.tf` - Resource definitions
- `variables.tf` - Input variables
- `outputs.tf` - Output values (IPs)
- `terraform.tfvars` - Configuration values

**Commands**:
```powershell
cd infra
terraform init          # Initialize
terraform plan          # Preview changes
terraform apply         # Create infrastructure
terraform output        # Show IPs
terraform destroy       # Cleanup
```

---

### 2. **Configuration Management (Ansible)** ✅
**Location**: `/ansible/`

**What it does**:
- Installs Node.js, Nginx, PM2
- Deploys frontend and backend code
- Configures services automatically
- Ensures idempotent deployments

**Roles**:
- **common**: Creates users, installs base packages
- **web**: Nginx setup, React deployment
- **api**: Node.js, PM2, API deployment
- **nagios**: Monitoring setup

**Playbooks**:
- `deploy.yml` - Deploy web + api
- `site.yml` - Full infrastructure setup

**Commands**:
```bash
ansible-playbook -i inventory.ini deploy.yml
```

---

### 3. **CI/CD Pipeline (GitHub Actions)** ✅
**Location**: `.github/workflows/deploy.yml`

**What it does**:
- Triggers on push to `main` branch
- Builds React frontend
- Installs API dependencies
- Runs Ansible deployment
- Performs health checks

**Pipeline Stages**:
1. **Checkout** - Get code from repo
2. **Setup Node** - Install Node.js 18
3. **Build Client** - Compile React app
4. **Build API** - Install dependencies
5. **Run Tests** - Execute test suite
6. **Install Ansible** - Setup automation
7. **Prepare Inventory** - Configure hosts
8. **Deploy** - Run Ansible playbooks
9. **Health Checks** - Verify deployment

**Secrets Required**:
- `EC2_WEB_IP`, `EC2_API_IP`, `EC2_NAGIOS_IP`
- `SSH_PRIVATE_KEY`
- `MONGODB_URI`

---

### 4. **Monitoring (Nagios)** ✅
**Location**: `/monitoring/`

**What it does**:
- Monitors web server HTTP status
- Checks API TCP connectivity
- Tracks CPU and load via NRPE
- Sends alerts on failures

**Configuration**:
- HTTP checks for frontend
- TCP checks for API (port 3001)
- NRPE for system metrics

---

### 5. **Automation Scripts** ✅
**Location**: `/scripts/`

**Available Scripts**:

| Script | Purpose | Usage |
|--------|---------|-------|
| `deploy.sh` | Full deployment | `./scripts/deploy.sh` |
| `status.sh` | Check service status | `./scripts/status.sh` |
| `start.sh` | Start services | `./scripts/start.sh` |
| `stop.sh` | Stop services | `./scripts/stop.sh` |
| `rollback.sh` | Revert to previous version | `./scripts/rollback.sh` |
| `check_health.sh` | Health check endpoints | `./scripts/check_health.sh` |

---

## 📦 Setup & Installation

### **Prerequisites**

1. **Install Terraform**
   ```powershell
   # Download from: https://www.terraform.io/downloads
   # Extract to C:\terraform
   # Add to PATH
   terraform --version
   ```

2. **Install AWS CLI**
   ```powershell
   # Download: https://awscli.amazonaws.com/AWSCLIV2.msi
   # Install and verify
   aws --version
   ```

3. **Install Git** (if not installed)
   ```powershell
   git --version
   ```

4. **Install Node.js 18+**
   ```powershell
   node --version
   npm --version
   ```

---

### **Step 1: Clone Repository**

```powershell
cd c:\Users\sushe\Desktop\Studysem\sem7\Devops\PROJECT\Project2
git clone <your-repo-url> Pro-vertos
cd Pro-vertos
```

---

### **Step 2: Configure AWS**

```powershell
# Configure AWS credentials
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Region: us-east-1
# - Output: json

# Verify
aws sts get-caller-identity
```

---

### **Step 3: Create SSH Key Pair**

**In AWS Console**:
1. EC2 → Key Pairs → Create key pair
2. Name: `provertos-key`
3. Type: RSA, Format: .pem
4. Download and save

**In PowerShell**:
```powershell
mkdir -Force "$env:USERPROFILE\.ssh"
Move-Item "$env:USERPROFILE\Downloads\provertos-key.pem" "$env:USERPROFILE\.ssh\provertos-key.pem"
```

---

### **Step 4: Provision Infrastructure**

```powershell
cd infra

# Initialize Terraform
terraform init

# Review plan
terraform plan

# Create infrastructure
terraform apply -auto-approve

# Get IPs (SAVE THESE!)
terraform output
```

**Expected Output**:
```
api_public_ip = "54.123.45.67"
nagios_public_ip = "54.123.45.68"
web_public_ip = "54.123.45.69"
```

---

### **Step 5: Set Up MongoDB Atlas**

1. **Create Account**: https://www.mongodb.com/cloud/atlas/register
2. **Create Cluster**: FREE tier (M0), AWS, us-east-1
3. **Create User**: `provertos_user` with password
4. **Network Access**: Allow 0.0.0.0/0
5. **Get Connection String**:
   ```
   mongodb+srv://provertos_user:PASSWORD@cluster.xxxxx.mongodb.net/provertos?retryWrites=true&w=majority
   ```

---

### **Step 6: Configure GitHub Secrets**

Go to: **GitHub Repo → Settings → Secrets → Actions → New secret**

Add these 5 secrets:

1. **EC2_WEB_IP**: `<web IP from terraform>`
2. **EC2_API_IP**: `<api IP from terraform>`
3. **EC2_NAGIOS_IP**: `<nagios IP from terraform>`
4. **SSH_PRIVATE_KEY**: `<content of provertos-key.pem>`
5. **MONGODB_URI**: `<MongoDB connection string>`

---

### **Step 7: Deploy Application**

```powershell
# Commit all changes
git add .
git commit -m "Initial deployment setup"
git push origin main
```

**GitHub Actions will automatically**:
- Build the application
- Deploy to EC2 instances
- Run health checks

**Watch deployment**: GitHub → Actions tab

---

## 🎮 Running the Project

### **Option 1: Automatic Deployment (Recommended)**

```powershell
# Make any code change
git add .
git commit -m "Update feature"
git push origin main
```
✅ GitHub Actions deploys automatically!

---

### **Option 2: Manual Deployment**

```powershell
# Set environment variables
$env:EC2_WEB_IP = "<your-web-ip>"
$env:EC2_API_IP = "<your-api-ip>"
$env:EC2_NAGIOS_IP = "<your-nagios-ip>"
$env:SSH_PRIVATE_KEY = Get-Content "$env:USERPROFILE\.ssh\provertos-key.pem" -Raw
$env:MONGODB_URI = "<your-mongodb-uri>"

# Run deployment script (requires Git Bash or WSL)
bash ./scripts/deploy.sh
```

---

### **Option 3: Local Development**

**Terminal 1 - Backend**:
```powershell
cd api
npm install
$env:MONGODB_URI = "<your-mongodb-uri>"
$env:PORT = "4000"
node index.js
```

**Terminal 2 - Frontend**:
```powershell
cd client
npm install
npm run dev
```

**Access**: http://localhost:5173

---

## 🎬 Demo Flow (10-15 Minutes)

### **Part 1: Infrastructure Provisioning (3 min)**

```powershell
cd infra
terraform init
terraform apply -auto-approve
terraform output
```

**Show**:
- Terraform creating 3 EC2 instances
- Security group configuration
- Public IPs assigned

---

### **Part 2: CI/CD Pipeline (4 min)**

1. **Show GitHub Actions Workflow**:
   - Open `.github/workflows/deploy.yml`
   - Explain stages: Build → Test → Deploy

2. **Trigger Deployment**:
   ```powershell
   # Make a small change
   echo "# Demo update" >> README.md
   git add .
   git commit -m "Trigger CI/CD demo"
   git push origin main
   ```

3. **Watch Pipeline**:
   - GitHub → Actions tab
   - Show real-time logs
   - Point out each stage

**Show**:
- Automated build process
- Ansible deployment
- Health checks passing

---

### **Part 3: Configuration Management (3 min)**

1. **Show Ansible Roles**:
   ```powershell
   tree ansible/roles
   ```

2. **Explain Playbooks**:
   - `deploy.yml` - Application deployment
   - Roles: common, web, api

3. **Show Idempotency**:
   ```bash
   # Run deployment twice - same result
   ansible-playbook -i inventory.ini deploy.yml
   ```

**Show**:
- Ansible role structure
- Idempotent deployments
- Configuration templates

---

### **Part 4: Application Demo (3 min)**

1. **Access Frontend**:
   ```
   http://<EC2_WEB_IP>/
   ```

2. **Demo Features**:
   - Register new user
   - Login
   - Create event
   - Book ticket
   - Generate QR code

3. **Check API**:
   ```
   http://<EC2_API_IP>:3001/healthz
   http://<EC2_API_IP>:3001/test
   ```

**Show**:
- Working application
- Frontend-backend communication
- Database integration

---

### **Part 5: Monitoring (2 min)**

1. **Access Nagios** (if configured):
   ```
   http://<EC2_NAGIOS_IP>/
   ```

2. **Show Checks**:
   - Web server HTTP status
   - API TCP connectivity
   - System metrics

3. **Trigger Alert**:
   ```bash
   ./scripts/stop.sh  # Stop API
   # Wait 1 minute
   # Show Nagios alert
   ./scripts/start.sh  # Start API
   # Alert clears
   ```

**Show**:
- Real-time monitoring
- Alert generation
- Service recovery

---

### **Part 6: Automation Scripts (2 min)**

```powershell
# Check status
./scripts/status.sh

# Stop services
./scripts/stop.sh

# Start services
./scripts/start.sh

# Health check
./scripts/check_health.sh

# Rollback (if needed)
./scripts/rollback.sh
```

**Show**:
- Service management
- Health monitoring
- Rollback capability

---

## ✅ Verification & Testing

### **1. Infrastructure Verification**

```powershell
# Check EC2 instances
aws ec2 describe-instances --filters "Name=tag:Name,Values=provertos-*" --query "Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress,Tags[?Key=='Name'].Value|[0]]" --output table

# Check security groups
aws ec2 describe-security-groups --filters "Name=group-name,Values=provertos-sg"
```

---

### **2. Application Health Checks**

```powershell
# Web server
curl http://<EC2_WEB_IP>/

# API health
curl http://<EC2_API_IP>:3001/healthz

# API test endpoint
curl http://<EC2_API_IP>:3001/test
```

**Expected Responses**:
- Web: HTML content
- Health: `{"status":"ok","timestamp":"...","service":"provertos-api"}`
- Test: `"test ok"`

---

### **3. Service Status Checks**

**SSH into instances**:
```powershell
ssh -i "$env:USERPROFILE\.ssh\provertos-key.pem" ec2-user@<EC2_WEB_IP>
```

**Check Nginx** (on web server):
```bash
sudo systemctl status nginx
curl localhost
```

**Check PM2** (on API server):
```bash
pm2 status
pm2 logs provertos-api
```

**Check Node.js**:
```bash
node --version
npm --version
```

---

### **4. Database Connectivity**

```bash
# On API server
cd /opt/provertos/api
node -e "const mongoose = require('mongoose'); mongoose.connect(process.env.MONGODB_URI).then(() => console.log('Connected!')).catch(err => console.error(err));"
```

---

### **5. CI/CD Pipeline Verification**

1. **Check GitHub Actions**:
   - Go to: GitHub → Actions
   - Verify latest run is ✅ green

2. **View Logs**:
   - Click on workflow run
   - Check each step passed

3. **Verify Deployment**:
   - Check "Deploy" step logs
   - Verify Ansible completed successfully

---

## 🎯 Key DevOps Concepts Demonstrated

### **1. Infrastructure as Code (IaC)**
- ✅ Terraform for infrastructure provisioning
- ✅ Version-controlled infrastructure
- ✅ Reproducible environments
- ✅ Declarative configuration

### **2. Configuration Management**
- ✅ Ansible for automated configuration
- ✅ Idempotent deployments
- ✅ Role-based organization
- ✅ Template-based configuration

### **3. Continuous Integration/Continuous Deployment (CI/CD)**
- ✅ Automated build pipeline
- ✅ Automated testing
- ✅ Automated deployment
- ✅ GitHub Actions workflow

### **4. Monitoring & Observability**
- ✅ Nagios for service monitoring
- ✅ Health check endpoints
- ✅ Alert generation
- ✅ Service status tracking

### **5. Automation**
- ✅ Deployment scripts
- ✅ Service management scripts
- ✅ Health check automation
- ✅ Rollback capability

### **6. Security Best Practices**
- ✅ SSH key-based authentication
- ✅ Secrets management (GitHub Secrets)
- ✅ Security groups for network isolation
- ✅ Environment variable configuration

### **7. Cloud Infrastructure**
- ✅ AWS EC2 instances
- ✅ MongoDB Atlas (DBaaS)
- ✅ Public/private networking
- ✅ Scalable architecture

---

## 📊 Architecture Diagram

```
┌─────────────┐
│  Developer  │
└──────┬──────┘
       │ git push
       ▼
┌─────────────────┐
│  GitHub Repo    │
└──────┬──────────┘
       │ webhook
       ▼
┌─────────────────┐
│ GitHub Actions  │
│  - Build        │
│  - Test         │
│  - Deploy       │
└──────┬──────────┘
       │ ansible
       ▼
┌─────────────────────────────────┐
│         AWS Cloud               │
│                                 │
│  ┌──────────┐  ┌──────────┐   │
│  │ EC2 Web  │  │ EC2 API  │   │
│  │ Nginx    │  │ Node+PM2 │   │
│  │ React    │  │ Express  │   │
│  └────┬─────┘  └────┬─────┘   │
│       │             │          │
│       └──────┬──────┘          │
│              │                 │
│       ┌──────▼──────┐          │
│       │ EC2 Nagios  │          │
│       │ Monitoring  │          │
│       └─────────────┘          │
└─────────────────────────────────┘
              │
              ▼
     ┌────────────────┐
     │ MongoDB Atlas  │
     │   (Cloud DB)   │
     └────────────────┘
```

---

## 🐛 Troubleshooting

### **Issue: Terraform fails**
```powershell
# Check AWS credentials
aws sts get-caller-identity

# Check region
aws configure get region

# Re-initialize
cd infra
terraform init -upgrade
```

---

### **Issue: Ansible deployment fails**
```bash
# Check SSH connectivity
ssh -i ~/.ssh/provertos-key.pem ec2-user@<EC2_IP>

# Check Ansible syntax
ansible-playbook --syntax-check deploy.yml

# Run with verbose output
ansible-playbook -i inventory.ini deploy.yml -vvv
```

---

### **Issue: Application not accessible**
```powershell
# Check security groups
aws ec2 describe-security-groups --group-names provertos-sg

# Check instance status
aws ec2 describe-instances --filters "Name=tag:Name,Values=provertos-web"

# Check service status (SSH into instance)
sudo systemctl status nginx
pm2 status
```

---

### **Issue: MongoDB connection fails**
```bash
# Test connection
node -e "require('mongoose').connect('YOUR_URI').then(() => console.log('OK'))"

# Check environment variable
echo $MONGODB_URI

# Verify Network Access in MongoDB Atlas
# Ensure 0.0.0.0/0 is allowed
```

---

### **Issue: GitHub Actions fails**
1. Check secrets are set correctly
2. Verify SSH key format (include BEGIN/END lines)
3. Check EC2 instances are running
4. Review workflow logs for specific error

---

## 💡 Best Practices Implemented

1. **Version Control**: All code in Git
2. **Secrets Management**: GitHub Secrets for sensitive data
3. **Idempotency**: Ansible ensures consistent state
4. **Health Checks**: Automated endpoint monitoring
5. **Rollback Capability**: Quick recovery from failures
6. **Documentation**: Comprehensive guides
7. **Automation**: Minimal manual intervention
8. **Monitoring**: Proactive issue detection
9. **Security**: SSH keys, security groups, secrets
10. **Scalability**: Cloud-based, easily scalable

---

## 📈 Metrics & KPIs

- **Deployment Time**: ~5 minutes (automated)
- **Infrastructure Provisioning**: ~3 minutes
- **Rollback Time**: ~2 minutes
- **Uptime Target**: 99.9%
- **Build Success Rate**: Target 95%+
- **Mean Time to Recovery (MTTR)**: <5 minutes

---

## 🎓 Learning Outcomes

By completing this project, you've demonstrated:

✅ Infrastructure as Code with Terraform  
✅ Configuration Management with Ansible  
✅ CI/CD Pipeline with GitHub Actions  
✅ Cloud Infrastructure on AWS  
✅ Containerization concepts (PM2)  
✅ Monitoring and Alerting  
✅ Security best practices  
✅ Automation scripting  
✅ Full-stack application deployment  
✅ DevOps workflow implementation  

---

## 🚀 Next Steps for Production

1. **Add HTTPS/TLS** - Let's Encrypt certificates
2. **Load Balancer** - AWS ALB for high availability
3. **Auto-scaling** - Scale based on demand
4. **Database Backups** - Automated MongoDB backups
5. **Logging** - Centralized logging (ELK Stack)
6. **Container Orchestration** - Docker + Kubernetes
7. **Blue-Green Deployment** - Zero-downtime deployments
8. **Performance Monitoring** - APM tools
9. **Cost Optimization** - Reserved instances, spot instances
10. **Disaster Recovery** - Multi-region setup

---

## 📞 Quick Command Reference

```powershell
# Infrastructure
terraform init && terraform apply -auto-approve
terraform output
terraform destroy -auto-approve

# Deployment
git add . && git commit -m "Deploy" && git push

# Service Management
./scripts/deploy.sh
./scripts/status.sh
./scripts/stop.sh
./scripts/start.sh
./scripts/rollback.sh

# Health Checks
curl http://<WEB_IP>/
curl http://<API_IP>:3001/healthz

# SSH Access
ssh -i ~/.ssh/provertos-key.pem ec2-user@<IP>

# Logs
pm2 logs provertos-api
sudo tail -f /var/log/nginx/error.log
```

---

**🎉 Congratulations! You've built a complete DevOps pipeline!**

**Project Status**: ✅ Production-Ready  
**DevOps Maturity**: Level 3 (Automated CI/CD)  
**Demo Time**: 10-15 minutes  
**Complexity**: Intermediate to Advanced  

---

*Last Updated: November 10, 2025*  
*Version: 1.0*  
*Author: Pro-vertos DevOps Team*
