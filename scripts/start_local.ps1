# Start Pro-vertos locally (client + API)
# This script starts both the React client and Node.js API

Write-Host "=== Starting Pro-vertos Locally ===" -ForegroundColor Cyan

$ROOT_DIR = Split-Path -Parent $PSScriptRoot

# Check if .env exists in API
if (-not (Test-Path "$ROOT_DIR\api\.env")) {
    Write-Host "⚠ Creating default .env file..." -ForegroundColor Yellow
    @"
PORT=3001
MONGODB_URI=mongodb://localhost:27017/provertos
JWT_SECRET=dev-secret-key-change-in-production
CORS_ORIGIN=http://localhost:5173
"@ | Out-File -FilePath "$ROOT_DIR\api\.env" -Encoding UTF8
}

# Start API in background
Write-Host "`nStarting API server on port 3001..." -ForegroundColor Yellow
$apiJob = Start-Job -ScriptBlock {
    param($apiPath)
    Set-Location $apiPath
    node index.js
} -ArgumentList "$ROOT_DIR\api"

Write-Host "✓ API started (Job ID: $($apiJob.Id))" -ForegroundColor Green

# Wait a moment for API to start
Start-Sleep -Seconds 2

# Start Client in background
Write-Host "`nStarting React client on port 5173..." -ForegroundColor Yellow
$clientJob = Start-Job -ScriptBlock {
    param($clientPath)
    Set-Location $clientPath
    npm run dev
} -ArgumentList "$ROOT_DIR\client"

Write-Host "✓ Client started (Job ID: $($clientJob.Id))" -ForegroundColor Green

Write-Host "`n=== Pro-vertos is running ===" -ForegroundColor Green
Write-Host "Client: http://localhost:5173" -ForegroundColor Cyan
Write-Host "API: http://localhost:3001" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop both servers" -ForegroundColor Yellow
Write-Host ""
Write-Host "To view logs:" -ForegroundColor White
Write-Host "  API logs: Receive-Job -Id $($apiJob.Id) -Keep" -ForegroundColor Gray
Write-Host "  Client logs: Receive-Job -Id $($clientJob.Id) -Keep" -ForegroundColor Gray
Write-Host ""
Write-Host "To stop servers:" -ForegroundColor White
Write-Host "  Stop-Job -Id $($apiJob.Id),$($clientJob.Id)" -ForegroundColor Gray
Write-Host "  Remove-Job -Id $($apiJob.Id),$($clientJob.Id)" -ForegroundColor Gray

# Keep script running and show logs
try {
    while ($true) {
        Start-Sleep -Seconds 5
        
        # Check if jobs are still running
        $apiStatus = Get-Job -Id $apiJob.Id
        $clientStatus = Get-Job -Id $clientJob.Id
        
        if ($apiStatus.State -eq "Failed") {
            Write-Host "`n✗ API job failed!" -ForegroundColor Red
            Receive-Job -Id $apiJob.Id
            break
        }
        
        if ($clientStatus.State -eq "Failed") {
            Write-Host "`n✗ Client job failed!" -ForegroundColor Red
            Receive-Job -Id $clientJob.Id
            break
        }
    }
} finally {
    Write-Host "`nStopping servers..." -ForegroundColor Yellow
    Stop-Job -Id $apiJob.Id,$clientJob.Id -ErrorAction SilentlyContinue
    Remove-Job -Id $apiJob.Id,$clientJob.Id -ErrorAction SilentlyContinue
    Write-Host "✓ Servers stopped" -ForegroundColor Green
}
