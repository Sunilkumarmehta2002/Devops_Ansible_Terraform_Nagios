# GitHub Secrets Setup Guide

This guide shows you exactly how to get all the values needed for GitHub Secrets.

---

## 🎯 Required GitHub Secrets

You need to add these 5 secrets to your GitHub repository:

1. `EC2_WEB_IP` - Public IP of web server
2. `EC2_API_IP` - Public IP of API server
3. `EC2_NAGIOS_IP` - Public IP of Nagios server
4. `SSH_PRIVATE_KEY` - Private SSH key to access EC2 instances
5. `MONGODB_URI` - MongoDB Atlas connection string

---

## 📝 Step-by-Step Instructions

### **STEP 1: Install Required Tools**

#### 1.1 Install Terraform
```powershell
# Option A: Download manually
# Go to: https://www.terraform.io/downloads
# Download Windows AMD64 zip
# Extract to C:\terraform
# Add to PATH: $env:PATH += ";C:\terraform"

# Option B: Use Chocolatey (if installed)
choco install terraform

# Verify installation
terraform --version
```

#### 1.2 Install AWS CLI
```powershell
# Download from: https://aws.amazon.com/cli/
# Or use MSI installer

# Verify installation
aws --version
```

---

### **STEP 2: Set Up AWS Account**

#### 2.1 Get AWS Access Keys
1. Log in to AWS Console: https://console.aws.amazon.com/
2. Click your name (top right) → **Security credentials**
3. Scroll to **Access keys** → Click **Create access key**
4. Select **Command Line Interface (CLI)**
5. Check "I understand..." → Click **Next**
6. Add description: "Terraform Pro-vertos" → Click **Create access key**
7. **IMPORTANT**: Copy both:
   - Access key ID (e.g., `AKIAIOSFODNN7EXAMPLE`)
   - Secret access key (e.g., `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`)
8. Click **Download .csv file** (backup)

#### 2.2 Configure AWS CLI
```powershell
aws configure
```
Enter when prompted:
- **AWS Access Key ID**: `<paste your access key>`
- **AWS Secret Access Key**: `<paste your secret key>`
- **Default region name**: `us-east-1`
- **Default output format**: `json`

#### 2.3 Create SSH Key Pair in AWS
1. Go to AWS Console → **EC2** → **Key Pairs** (left sidebar)
2. Click **Create key pair**
3. Settings:
   - **Name**: `provertos-key`
   - **Key pair type**: RSA
   - **Private key file format**: `.pem`
4. Click **Create key pair**
5. File `provertos-key.pem` will download automatically
6. **IMPORTANT**: Move it to a safe location:
   ```powershell
   # Create .ssh directory if it doesn't exist
   mkdir -Force "$env:USERPROFILE\.ssh"
   
   # Move the downloaded key
   Move-Item "$env:USERPROFILE\Downloads\provertos-key.pem" "$env:USERPROFILE\.ssh\provertos-key.pem"
   
   # Set permissions (important for SSH)
   icacls "$env:USERPROFILE\.ssh\provertos-key.pem" /inheritance:r
   icacls "$env:USERPROFILE\.ssh\provertos-key.pem" /grant:r "$env:USERNAME:(R)"
   ```

---

### **STEP 3: Provision EC2 Instances with Terraform**

#### 3.1 Navigate to infra directory
```powershell
cd c:\Users\sushe\Desktop\Studysem\sem7\Devops\PROJECT\Project2\Pro-vertos\infra
```

#### 3.2 Initialize Terraform
```powershell
terraform init
```
Expected output: "Terraform has been successfully initialized!"

#### 3.3 Review what will be created
```powershell
terraform plan
```
Should show: 3 EC2 instances + 1 security group = 4 resources to create

#### 3.4 Create the infrastructure
```powershell
terraform apply -auto-approve
```
Wait 2-3 minutes. You'll see output like:
```
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

api_public_ip = "54.123.45.67"
nagios_public_ip = "54.123.45.68"
web_public_ip = "54.123.45.69"
```

#### 3.5 Get the IP addresses
```powershell
# Get Web IP
terraform output -raw web_public_ip

# Get API IP
terraform output -raw api_public_ip

# Get Nagios IP
terraform output -raw nagios_public_ip
```

**SAVE THESE IPs** - You'll need them for GitHub Secrets!

---

### **STEP 4: Get SSH Private Key Content**

```powershell
# Display the private key content
Get-Content "$env:USERPROFILE\.ssh\provertos-key.pem"
```

**Copy the ENTIRE output** including:
- `-----BEGIN RSA PRIVATE KEY-----`
- All the random characters in between
- `-----END RSA PRIVATE KEY-----`

Example:
```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAx7...
(many lines of random characters)
...xyz123==
-----END RSA PRIVATE KEY-----
```

---

### **STEP 5: Get MongoDB URI**

#### 5.1 Create MongoDB Atlas Account (Free Tier)
1. Go to: https://www.mongodb.com/cloud/atlas/register
2. Sign up with email or Google
3. Choose **FREE** tier (M0 Sandbox)

#### 5.2 Create a Cluster
1. After login, click **Build a Database**
2. Choose **FREE** (M0) tier
3. Select **AWS** as cloud provider
4. Choose region closest to your EC2 region (e.g., `us-east-1`)
5. Cluster name: `provertos-cluster`
6. Click **Create**

#### 5.3 Set Up Database Access
1. Click **Database Access** (left sidebar)
2. Click **Add New Database User**
3. Authentication Method: **Password**
4. Username: `provertos_user`
5. Password: Click **Autogenerate Secure Password** → **Copy** it
6. Database User Privileges: **Read and write to any database**
7. Click **Add User**

#### 5.4 Set Up Network Access
1. Click **Network Access** (left sidebar)
2. Click **Add IP Address**
3. Click **Allow Access from Anywhere** (for demo purposes)
   - CIDR: `0.0.0.0/0`
4. Click **Confirm**

#### 5.5 Get Connection String
1. Click **Database** (left sidebar)
2. Click **Connect** button on your cluster
3. Choose **Connect your application**
4. Driver: **Node.js**, Version: **4.1 or later**
5. Copy the connection string, it looks like:
   ```
   mongodb+srv://provertos_user:<password>@provertos-cluster.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```
6. **IMPORTANT**: Replace `<password>` with the password you copied earlier
7. Add database name at the end:
   ```
   mongodb+srv://provertos_user:YourPassword123@provertos-cluster.xxxxx.mongodb.net/provertos?retryWrites=true&w=majority
   ```

**SAVE THIS** - This is your `MONGODB_URI`!

---

### **STEP 6: Add Secrets to GitHub**

#### 6.1 Go to Your GitHub Repository
1. Open: https://github.com/YOUR_USERNAME/Pro-vertos
2. Click **Settings** tab (top right)
3. Click **Secrets and variables** → **Actions** (left sidebar)
4. Click **New repository secret** button

#### 6.2 Add Each Secret

**Secret 1: EC2_WEB_IP**
- Name: `EC2_WEB_IP`
- Secret: `<paste the web IP from terraform output>`
- Click **Add secret**

**Secret 2: EC2_API_IP**
- Name: `EC2_API_IP`
- Secret: `<paste the API IP from terraform output>`
- Click **Add secret**

**Secret 3: EC2_NAGIOS_IP**
- Name: `EC2_NAGIOS_IP`
- Secret: `<paste the Nagios IP from terraform output>`
- Click **Add secret**

**Secret 4: SSH_PRIVATE_KEY**
- Name: `SSH_PRIVATE_KEY`
- Secret: `<paste the ENTIRE content of provertos-key.pem>`
- Click **Add secret**

**Secret 5: MONGODB_URI**
- Name: `MONGODB_URI`
- Secret: `<paste your MongoDB connection string>`
- Click **Add secret**

#### 6.3 Verify All Secrets Are Added
You should see 5 secrets listed:
- ✅ EC2_WEB_IP
- ✅ EC2_API_IP
- ✅ EC2_NAGIOS_IP
- ✅ SSH_PRIVATE_KEY
- ✅ MONGODB_URI

---

## ✅ Verification Checklist

Before deploying, verify you have:

- [ ] Terraform installed and working
- [ ] AWS CLI configured with access keys
- [ ] SSH key pair created in AWS (`provertos-key`)
- [ ] Private key saved locally (`~/.ssh/provertos-key.pem`)
- [ ] EC2 instances created (3 instances running)
- [ ] All 3 public IPs obtained
- [ ] MongoDB Atlas cluster created
- [ ] MongoDB connection string obtained
- [ ] All 5 GitHub secrets added

---

## 🚀 Next Steps - Deploy!

Once all secrets are added:

### Option 1: Automatic Deployment (Recommended)
```bash
git add .
git commit -m "Setup complete - ready for deployment"
git push origin main
```
GitHub Actions will automatically deploy!

### Option 2: Manual Deployment
```powershell
# Set environment variables
$env:EC2_WEB_IP = "<your-web-ip>"
$env:EC2_API_IP = "<your-api-ip>"
$env:EC2_NAGIOS_IP = "<your-nagios-ip>"
$env:SSH_PRIVATE_KEY = Get-Content "$env:USERPROFILE\.ssh\provertos-key.pem" -Raw
$env:MONGODB_URI = "<your-mongodb-uri>"

# Run deploy script (requires WSL or Git Bash)
bash ./scripts/deploy.sh
```

---

## 🔍 Troubleshooting

### Issue: "Terraform not found"
**Solution**: Add Terraform to PATH or use full path

### Issue: "AWS authentication failed"
**Solution**: Run `aws configure` again with correct keys

### Issue: "Permission denied (publickey)"
**Solution**: Check SSH key permissions:
```powershell
icacls "$env:USERPROFILE\.ssh\provertos-key.pem"
```

### Issue: "MongoDB connection failed"
**Solution**: 
1. Check password is correct (no `<` `>` brackets)
2. Verify Network Access allows `0.0.0.0/0`
3. Check database user has correct permissions

---

## 💰 Cost Estimate

- **EC2 Instances**: 3 × t3.micro = ~$0.0104/hour × 3 = ~$0.03/hour (~$22/month if running 24/7)
- **MongoDB Atlas**: FREE tier (M0)
- **Data Transfer**: Minimal for demo

**Tip**: Stop EC2 instances when not in use to save costs:
```powershell
cd infra
terraform destroy -auto-approve
```

---

## 📞 Quick Reference

### Get EC2 IPs Again
```powershell
cd infra
terraform output
```

### View SSH Key
```powershell
Get-Content "$env:USERPROFILE\.ssh\provertos-key.pem"
```

### Test SSH Connection
```powershell
ssh -i "$env:USERPROFILE\.ssh\provertos-key.pem" ec2-user@<EC2_WEB_IP>
```

### View MongoDB URI
Check your saved notes or MongoDB Atlas dashboard → Connect

---

**You're all set! 🎉**
