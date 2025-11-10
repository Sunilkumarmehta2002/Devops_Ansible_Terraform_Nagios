# Pro-vertos Scripts

This directory contains scripts for testing, deploying, and managing the Pro-vertos application.

## Local Testing (Windows)

### 1. Test Local Setup
Tests that all dependencies are installed and builds work correctly:

```powershell
.\scripts\test_local.ps1
```

This will:
- ✓ Check Node.js installation
- ✓ Install client dependencies
- ✓ Build client
- ✓ Install API dependencies
- ✓ Check configuration files
- ✓ Verify Terraform files

### 2. Start Locally
Start both client and API on your local machine:

```powershell
.\scripts\start_local.ps1
```

Access the application at:
- **Client**: http://localhost:5173
- **API**: http://localhost:3001

Press `Ctrl+C` to stop both servers.

### 3. Manual Start (Alternative)

**Terminal 1 - API:**
```powershell
cd api
npm start
```

**Terminal 2 - Client:**
```powershell
cd client
npm run dev
```

## Deployment Scripts (Linux/Bash)

### Deploy to Production
```bash
./scripts/deploy.sh
```

### Check Application Status
```bash
./scripts/status.sh
```

### Check Health
```bash
./scripts/check_health.sh
```

### Start Services
```bash
./scripts/start.sh
```

### Stop Services
```bash
./scripts/stop.sh
```

### Rollback Deployment
```bash
./scripts/rollback.sh
```

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/deploy.yml`) automatically:
1. Builds the client
2. Installs API dependencies
3. Deploys to EC2 instances using Ansible
4. Verifies deployment health

**Required GitHub Secrets:**
- `EC2_WEB_IP` - Web server IP
- `EC2_API_IP` - API server IP
- `EC2_NAGIOS_IP` - Nagios monitoring server IP
- `SSH_PRIVATE_KEY` - SSH key for EC2 access
- `MONGODB_URI` - MongoDB connection string

## Infrastructure Setup

### 1. Configure Terraform
```powershell
cd infra
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your AWS credentials
```

### 2. Deploy Infrastructure
```powershell
cd infra
terraform init
terraform plan
terraform apply
```

### 3. Note the Output IPs
Save the EC2 instance IPs from Terraform output for GitHub secrets.

## Troubleshooting

### Build Fails
```powershell
# Clean and reinstall dependencies
cd client
Remove-Item -Recurse -Force node_modules
npm install
npm run build
```

### API Won't Start
- Check `.env` file exists in `api/` directory
- Verify MongoDB connection string
- Check port 3001 is not in use

### Client Won't Start
- Check port 5173 is not in use
- Verify Vite configuration in `client/vite.config.js`

### Ansible Deployment Fails
- Verify SSH key has correct permissions (600)
- Check EC2 security groups allow SSH (port 22)
- Ensure EC2 instances are running
- Verify inventory.ini has correct IPs

## Environment Variables

### API (.env)
```env
PORT=3001
MONGODB_URI=mongodb://localhost:27017/provertos
JWT_SECRET=your-secret-key-here
CORS_ORIGIN=http://localhost:5173
```

### Terraform (terraform.tfvars)
```hcl
aws_region = "us-east-1"
key_name = "your-key-pair"
```
