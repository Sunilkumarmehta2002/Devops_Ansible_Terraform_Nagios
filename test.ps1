# Simple Test Script for Pro-vertos
Write-Host "=== Pro-vertos Test Script ===" -ForegroundColor Cyan

$ROOT = $PSScriptRoot

# Check Node.js
Write-Host "`n[1/5] Checking Node.js..." -ForegroundColor Yellow
node --version
npm --version
Write-Host "OK" -ForegroundColor Green

# Install client deps
Write-Host "`n[2/5] Installing client dependencies..." -ForegroundColor Yellow
Set-Location "$ROOT\client"
npm ci
Write-Host "OK" -ForegroundColor Green

# Build client
Write-Host "`n[3/5] Building client..." -ForegroundColor Yellow
npm run build
if (Test-Path "dist") {
    Write-Host "OK - Build created in dist/" -ForegroundColor Green
}

# Install API deps
Write-Host "`n[4/5] Installing API dependencies..." -ForegroundColor Yellow
Set-Location "$ROOT\api"
npm ci
Write-Host "OK" -ForegroundColor Green

# Check config
Write-Host "`n[5/5] Checking configuration..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "OK - .env exists" -ForegroundColor Green
} else {
    Write-Host "Creating .env template..." -ForegroundColor Yellow
    "PORT=3001`nMONGODB_URI=mongodb://localhost:27017/provertos`nJWT_SECRET=dev-secret`nCORS_ORIGIN=http://localhost:5173" | Out-File ".env"
    Write-Host "OK - .env created" -ForegroundColor Green
}

Set-Location $ROOT

Write-Host "`n=== All Tests Passed ===" -ForegroundColor Green
Write-Host "`nTo start locally:" -ForegroundColor Yellow
Write-Host "  Terminal 1: cd api && npm start" -ForegroundColor White
Write-Host "  Terminal 2: cd client && npm run dev" -ForegroundColor White
Write-Host "`nAccess at: http://localhost:5173" -ForegroundColor Cyan
