# Pro-vertos Testing Guide

## ✅ Local Testing Complete!

All local tests have passed successfully. Here's what was verified:

### Test Results
- ✓ Node.js v20.15.1 installed
- ✓ npm v10.8.2 installed
- ✓ Client dependencies installed (500 packages)
- ✓ Client build successful (output in `client/dist/`)
- ✓ API dependencies installed (190 packages)
- ✓ Configuration files present

## 🚀 Quick Start - Local Development

### Option 1: Simple Test Script
```powershell
.\test.ps1
```

### Option 2: Manual Start

**Terminal 1 - Start API:**
```powershell
cd api
npm start
```

**Terminal 2 - Start Client:**
```powershell
cd client
npm run dev
```

**Access Application:**
- Client: http://localhost:5173
- API: http://localhost:3001

## 📋 Available Scripts

### Testing Scripts
- `test.ps1` - Quick test of build and dependencies
- `scripts/test_local.ps1` - Comprehensive local testing
- `scripts/start_local.ps1` - Start both client and API together

### Deployment Scripts (Linux/Bash)
- `scripts/deploy.sh` - Deploy to production
- `scripts/start.sh` - Start services on remote servers
- `scripts/stop.sh` - Stop services
- `scripts/status.sh` - Check service status
- `scripts/check_health.sh` - Health check endpoints
- `scripts/rollback.sh` - Rollback to previous version

## 🔧 Configuration

### API Environment (.env)
```env
PORT=3001
MONGODB_URI=mongodb://localhost:27017/provertos
JWT_SECRET=your-secret-key-here
CORS_ORIGIN=http://localhost:5173
```

### Client Configuration
The client is configured via `client/vite.config.js` and uses environment variables for API endpoint configuration.

## 🌐 CI/CD Pipeline

### GitHub Actions Workflow
The project uses GitHub Actions for automated deployment:

1. **Build Stage**
   - Install dependencies (`npm ci`)
   - Build client (`npm run build`)
   - Build API (install dependencies)

2. **Deploy Stage**
   - Setup Ansible
   - Generate inventory from secrets
   - Deploy to EC2 instances
   - Verify health endpoints

### Required GitHub Secrets
- `EC2_WEB_IP` - Web server IP address
- `EC2_API_IP` - API server IP address
- `EC2_NAGIOS_IP` - Nagios monitoring server IP
- `SSH_PRIVATE_KEY` - SSH private key for EC2 access
- `MONGODB_URI` - MongoDB connection string

## 🏗️ Infrastructure Setup

### 1. Configure Terraform
```powershell
cd infra
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your AWS credentials
```

### 2. Deploy Infrastructure
```powershell
terraform init
terraform plan
terraform apply
```

### 3. Note Output IPs
Save the EC2 instance IPs from Terraform output to configure GitHub secrets.

## 📊 Monitoring

### Nagios Setup
The project includes Nagios monitoring configuration in `ansible/roles/nagios/`.

Monitors:
- Web server HTTP endpoint
- API server TCP connection
- System resources

## 🐛 Troubleshooting

### Build Issues
```powershell
# Clean and rebuild client
cd client
Remove-Item -Recurse -Force node_modules, dist
npm install
npm run build
```

### API Won't Start
- Verify `.env` file exists in `api/` directory
- Check MongoDB is running and accessible
- Ensure port 3001 is not in use

### Client Won't Start
- Check port 5173 is not in use
- Verify API endpoint configuration
- Check browser console for errors

### Deployment Fails
- Verify all GitHub secrets are set correctly
- Check EC2 instances are running
- Verify security groups allow SSH (port 22)
- Check Ansible inventory has correct IPs

## 📦 Build Artifacts

### Client Build
- **Location**: `client/dist/`
- **Size**: ~391 KB (JS) + 55 KB (CSS)
- **Modules**: 563 transformed modules

### API
- **Entry**: `api/index.js`
- **Dependencies**: 190 packages
- **Runtime**: Node.js 18.x+

## 🔐 Security Notes

### Known Vulnerabilities
- Client: 19 vulnerabilities (1 low, 9 moderate, 6 high, 3 critical)
- API: 11 vulnerabilities (4 low, 2 moderate, 3 high, 2 critical)

**Action**: Run `npm audit fix` to address non-breaking issues.

### Production Recommendations
1. Update deprecated packages (uuid, request, har-validator)
2. Use strong JWT secrets
3. Enable HTTPS in production
4. Restrict CORS origins
5. Use environment-specific MongoDB credentials
6. Rotate SSH keys regularly
7. Enable AWS security groups properly

## 📝 Next Steps

1. ✅ Local testing complete
2. ⏭️ Configure AWS infrastructure (Terraform)
3. ⏭️ Set up GitHub secrets
4. ⏭️ Push to main branch to trigger CI/CD
5. ⏭️ Verify deployment on EC2 instances
6. ⏭️ Configure Nagios monitoring
7. ⏭️ Test production endpoints

## 📚 Additional Documentation

- `README.md` - Project overview
- `scripts/README.md` - Scripts documentation
- `Docs/COMPLETE_DEMO_GUIDE.md` - Complete demo guide
- `FIXES_APPLIED.md` - Applied fixes log

## 🎯 Success Criteria

- [x] Local build successful
- [x] All dependencies installed
- [x] Configuration files present
- [ ] Infrastructure deployed
- [ ] CI/CD pipeline passing
- [ ] Production deployment verified
- [ ] Monitoring active
