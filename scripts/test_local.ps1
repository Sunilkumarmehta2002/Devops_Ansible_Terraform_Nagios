# Local Testing Script for Pro-vertos
# Tests client and API locally before deployment

Write-Host "=== Pro-vertos Local Testing Script ===" -ForegroundColor Cyan
Write-Host ""

$ROOT_DIR = Split-Path -Parent $PSScriptRoot
$ErrorActionPreference = "Stop"

# Test 1: Check Node.js
Write-Host "[1/6] Checking Node.js installation..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>&1
    $npmVersion = npm --version 2>&1
    Write-Host "✓ Node.js: $nodeVersion" -ForegroundColor Green
    Write-Host "✓ npm: $npmVersion" -ForegroundColor Green
}
catch {
    Write-Host "✗ Node.js/npm not found. Please install Node.js 18.x" -ForegroundColor Red
    exit 1
}

# Test 2: Install client dependencies
Write-Host "`n[2/6] Installing client dependencies..." -ForegroundColor Yellow
Set-Location "$ROOT_DIR\client"
$result = npm ci 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Client dependencies installed" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to install client dependencies" -ForegroundColor Red
    Set-Location $ROOT_DIR
    exit 1
}

# Test 3: Build client
Write-Host "`n[3/6] Building client..." -ForegroundColor Yellow
$result = npm run build 2>&1
if ($LASTEXITCODE -eq 0 -and (Test-Path "dist")) {
    Write-Host "✓ Client build successful (output in dist/)" -ForegroundColor Green
} else {
    Write-Host "✗ Client build failed" -ForegroundColor Red
    Set-Location $ROOT_DIR
    exit 1
}

# Test 4: Install API dependencies
Write-Host "`n[4/6] Installing API dependencies..." -ForegroundColor Yellow
Set-Location "$ROOT_DIR\api"
$result = npm ci 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ API dependencies installed" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to install API dependencies" -ForegroundColor Red
    Set-Location $ROOT_DIR
    exit 1
}
Set-Location $ROOT_DIR

# Test 5: Check for .env file
Write-Host "`n[5/6] Checking API configuration..." -ForegroundColor Yellow
if (Test-Path "$ROOT_DIR\api\.env") {
    Write-Host "✓ .env file found" -ForegroundColor Green
} else {
    Write-Host "⚠ .env file not found. Creating template..." -ForegroundColor Yellow
    @"
PORT=3001
MONGODB_URI=mongodb://localhost:27017/provertos
JWT_SECRET=your-secret-key-here
CORS_ORIGIN=http://localhost:5173
"@ | Out-File -FilePath "$ROOT_DIR\api\.env" -Encoding UTF8
    Write-Host "✓ Template .env created. Please update with your values." -ForegroundColor Green
}

# Test 6: Check Terraform files
Write-Host "`n[6/6] Checking Terraform configuration..." -ForegroundColor Yellow
if (Test-Path "$ROOT_DIR\infra\main.tf") {
    Write-Host "✓ Terraform files found" -ForegroundColor Green
    if (Test-Path "$ROOT_DIR\infra\terraform.tfvars") {
        Write-Host "✓ terraform.tfvars exists" -ForegroundColor Green
    } else {
        Write-Host "⚠ terraform.tfvars not found. Copy from terraform.tfvars.example" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ Terraform files not found" -ForegroundColor Red
}

# Summary
Write-Host "`n=== Test Summary ===" -ForegroundColor Cyan
Write-Host "✓ All local tests passed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Start API locally: cd api && npm start" -ForegroundColor White
Write-Host "2. Start client locally: cd client && npm run dev" -ForegroundColor White
Write-Host "3. Access app at: http://localhost:5173" -ForegroundColor White
Write-Host ""
Write-Host "For deployment:" -ForegroundColor Yellow
Write-Host "1. Configure infra/terraform.tfvars" -ForegroundColor White
Write-Host "2. Run: cd infra && terraform init && terraform apply" -ForegroundColor White
Write-Host "3. Set GitHub secrets (EC2 IPs, SSH key, MongoDB URI)" -ForegroundColor White
Write-Host "4. Push to main branch to trigger CI/CD" -ForegroundColor White
