# Pro-vertos Local Development Setup

## Prerequisites Installation

1. Install Python 3.8+ from python.org
2. Install Node.js 18.x from nodejs.org
3. Install AWS CLI from aws.amazon.com/cli

## Environment Setup

1. Install Ansible (run in PowerShell as Administrator):
```powershell
python -m pip install --user ansible
# Add to PATH if needed:
$env:PATH += ";$env:APPDATA\Python\Python39\Scripts"
```

2. Generate SSH Key Pair:
```powershell
# Create .ssh directory if it doesn't exist
mkdir -Force "$env:USERPROFILE\.ssh"

# Generate new SSH key
ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\id_rsa" -N '""'

# Display public key (add this to AWS key pair)
Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub"
```

3. Set Environment Variables:
```powershell
# For PowerShell session:
$env:AWS_ACCESS_KEY_ID="your_access_key"
$env:AWS_SECRET_ACCESS_KEY="your_secret_key"
$env:AWS_DEFAULT_REGION="us-east-1"

# For permanent storage (optional):
[Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID", "your_access_key", "User")
[Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", "your_secret_key", "User")
[Environment]::SetEnvironmentVariable("AWS_DEFAULT_REGION", "us-east-1", "User")
```

## Infrastructure Deployment

1. Initialize and Apply Terraform:
```powershell
cd infra
terraform init
terraform apply
```

2. Save outputs as environment variables:
```powershell
$env:EC2_WEB_IP = terraform output -raw web_public_ip
$env:EC2_API_IP = terraform output -raw api_public_ip
$env:EC2_NAGIOS_IP = terraform output -raw nagios_public_ip
$env:SSH_PRIVATE_KEY = Get-Content "$env:USERPROFILE\.ssh\id_rsa"
$env:MONGODB_URI = "your_mongodb_atlas_uri"
```

## Application Deployment

1. Deploy the application:
```powershell
./scripts/deploy.sh
```

2. Verify deployment:
```powershell
./scripts/status.sh
```

## Troubleshooting

1. If Ansible command not found:
   ```powershell
   python -m pip install --upgrade pip
   python -m pip install --user ansible
   ```

2. If SSH fails:
   - Ensure the key pair is properly set up in AWS
   - Check security group allows port 22
   - Verify environment variables are set:
   ```powershell
   $env:EC2_WEB_IP
   $env:EC2_API_IP
   $env:EC2_NAGIOS_IP
   $env:SSH_PRIVATE_KEY
   ```

3. If deployment fails:
   - Check MongoDB URI is correct
   - Ensure Node.js is installed on target hosts
   - Verify network connectivity:
   ```powershell
   Test-NetConnection $env:EC2_WEB_IP -Port 22
   Test-NetConnection $env:EC2_API_IP -Port 22
   ```