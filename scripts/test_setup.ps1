# Test setup script for Pro-vertos deployment
# Run this in PowerShell to validate the environment

# Check Python
Write-Host "Checking Python installation..."
try {
    python --version
} catch {
    Write-Host "Python not found. Please install Python 3.8 or later"
    exit 1
}

# Check pip and install Ansible
Write-Host "Installing/upgrading pip and Ansible..."
python -m pip install --upgrade pip
pip install ansible

# Verify Ansible installation
Write-Host "Verifying Ansible installation..."
ansible --version

# Check if we have required environment variables
$requiredVars = @(
    "EC2_WEB_IP",
    "EC2_API_IP",
    "EC2_NAGIOS_IP",
    "SSH_PRIVATE_KEY",
    "MONGODB_URI"
)

foreach ($var in $requiredVars) {
    if (-not (Get-Item "env:$var" -ErrorAction SilentlyContinue)) {
        Write-Host "Missing required environment variable: $var"
    } else {
        Write-Host "$var is set"
    }
}

# Check if key files exist
$keyPath = "$env:USERPROFILE\.ssh\id_rsa"
if (-not (Test-Path $keyPath)) {
    Write-Host "SSH key not found at $keyPath"
    Write-Host "You may need to run: ssh-keygen -t rsa -b 4096"
}

# Check Node.js
Write-Host "Checking Node.js installation..."
try {
    node --version
    npm --version
} catch {
    Write-Host "Node.js/npm not found. Please install Node.js 18.x"
    exit 1
}

Write-Host "`nSetup validation complete. Next steps:"
Write-Host "1. Run 'terraform init && terraform apply' in the infra directory"
Write-Host "2. Set environment variables with the EC2 IPs and MongoDB URI"
Write-Host "3. Run ./scripts/deploy.sh to deploy the application"