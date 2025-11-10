# ⚡ Quick Start Guide - Pro-vertos

## 🎯 Your Current Status

✅ **Code Fixed**: All 5 critical issues resolved  
❌ **Not Deployed**: Need to set up infrastructure  
❌ **Tools Missing**: Terraform & AWS CLI not installed  

---

## 📋 Quick Checklist (45 minutes total)

### ☐ **Step 1: Commit Your Code** (2 min)
```powershell
cd c:\Users\sushe\Desktop\Studysem\sem7\Devops\PROJECT\Project2\Pro-vertos
git add .
git commit -m "Applied all critical fixes"
git push origin main
```

### ☐ **Step 2: Install Terraform** (5 min)
1. Download: https://www.terraform.io/downloads (Windows AMD64)
2. Extract to `C:\terraform`
3. Add to PATH:
   ```powershell
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\terraform", "Machine")
   ```
4. Restart PowerShell
5. Verify: `terraform --version`

### ☐ **Step 3: Install AWS CLI** (5 min)
1. Download: https://awscli.amazonaws.com/AWSCLIV2.msi
2. Install (accept defaults)
3. Restart PowerShell
4. Verify: `aws --version`

### ☐ **Step 4: Configure AWS** (5 min)
```powershell
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Region: us-east-1
# Output: json
```

### ☐ **Step 5: Create SSH Key in AWS** (3 min)
1. AWS Console → EC2 → Key Pairs
2. Create key pair: Name = `provertos-key`, Type = RSA, Format = .pem
3. Download and move:
   ```powershell
   mkdir -Force "$env:USERPROFILE\.ssh"
   Move-Item "$env:USERPROFILE\Downloads\provertos-key.pem" "$env:USERPROFILE\.ssh\provertos-key.pem"
   ```

### ☐ **Step 6: Provision Infrastructure** (5 min)
```powershell
cd infra
terraform init
terraform apply -auto-approve
terraform output  # SAVE THESE IPs!
```

### ☐ **Step 7: Set Up MongoDB** (10 min)
1. Sign up: https://www.mongodb.com/cloud/atlas/register
2. Create FREE cluster (M0, AWS, us-east-1)
3. Create user: `provertos_user` (save password)
4. Network Access: Allow 0.0.0.0/0
5. Get connection string (replace password, add `/provertos` at end)

### ☐ **Step 8: Add GitHub Secrets** (5 min)
GitHub → Settings → Secrets → Actions → Add:
- `EC2_WEB_IP` = (from terraform output)
- `EC2_API_IP` = (from terraform output)
- `EC2_NAGIOS_IP` = (from terraform output)
- `SSH_PRIVATE_KEY` = (content of provertos-key.pem)
- `MONGODB_URI` = (MongoDB connection string)

### ☐ **Step 9: Deploy** (5 min)
```powershell
git commit --allow-empty -m "Trigger deployment"
git push origin main
```
Watch: GitHub → Actions tab

---

## 🎬 Demo Script (10 minutes)

### **1. Show Infrastructure (2 min)**
```powershell
cd infra
terraform output
aws ec2 describe-instances --filters "Name=tag:Name,Values=provertos-*" --query "Reservations[].Instances[].[Tags[?Key=='Name'].Value|[0],State.Name,PublicIpAddress]" --output table
```
**Say**: "We use Terraform to provision 3 EC2 instances on AWS"

### **2. Show CI/CD Pipeline (2 min)**
- Open GitHub → Actions
- Show latest workflow run
- Explain stages: Build → Test → Deploy
**Say**: "GitHub Actions automatically builds and deploys on every push"

### **3. Show Ansible Configuration (2 min)**
```powershell
cat ansible/deploy.yml
tree ansible/roles
```
**Say**: "Ansible handles configuration management with idempotent roles"

### **4. Show Live Application (2 min)**
- Open: `http://<EC2_WEB_IP>/`
- Register user
- Create event
- Show API: `http://<EC2_API_IP>:3001/healthz`
**Say**: "Full-stack MERN app deployed automatically"

### **5. Show Automation (2 min)**
```powershell
./scripts/status.sh
./scripts/check_health.sh
```
**Say**: "We have scripts for deployment, monitoring, and rollback"

---

## 🔥 Emergency Commands

**If something breaks**:
```powershell
# Check what's running
terraform output
aws ec2 describe-instances --filters "Name=tag:Name,Values=provertos-*"

# Redeploy
git commit --allow-empty -m "Redeploy"
git push

# Destroy and start over
cd infra
terraform destroy -auto-approve
terraform apply -auto-approve
```

---

## 📊 What You've Built

| Component | Technology | Status |
|-----------|-----------|--------|
| Frontend | React + Vite | ✅ |
| Backend | Node.js + Express | ✅ |
| Database | MongoDB Atlas | ✅ |
| Infrastructure | Terraform + AWS | ✅ |
| Config Mgmt | Ansible | ✅ |
| CI/CD | GitHub Actions | ✅ |
| Monitoring | Nagios | ✅ |
| Automation | Bash Scripts | ✅ |

---

## 🎓 Key Points for Presentation

1. **IaC**: "Infrastructure defined as code, version controlled"
2. **Automation**: "One push deploys everything automatically"
3. **Idempotency**: "Run multiple times, same result"
4. **Monitoring**: "Nagios tracks health and sends alerts"
5. **Rollback**: "Quick recovery with rollback script"
6. **Security**: "SSH keys, secrets management, security groups"
7. **Scalability**: "Cloud-based, easy to scale horizontally"

---

## 📞 Need Help?

**Detailed guides available**:
- `COMPLETE_DEMO_GUIDE.md` - Full documentation
- `GITHUB_SECRETS_SETUP.md` - Step-by-step secrets setup
- `FIXES_APPLIED.md` - What was fixed
- `PROJECT_STATUS.md` - Project overview

**Quick tests**:
```powershell
# Test tools installed
terraform --version
aws --version
git --version

# Test AWS access
aws sts get-caller-identity

# Test infrastructure
cd infra
terraform output
```

---

## ⏱️ Time Breakdown

- Setup (first time): 45 minutes
- Deploy changes: 5 minutes
- Demo presentation: 10-15 minutes
- Q&A preparation: Review docs

---

**🚀 You're ready to go! Start with Step 1 and work through the checklist.**

**Questions? Check the detailed guides or run the test commands above.**
