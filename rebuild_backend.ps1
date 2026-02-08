# Quick Backend Rebuild Script
# Stops the backend, rebuilds, and runs it

Write-Host "=== Backend Rebuild ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Stop any running instances
Write-Host "Step 1: Stopping running backend..." -ForegroundColor Yellow
Get-Process -Name "InventoryManagement" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  Stopping process ID: $($_.Id)" -ForegroundColor Gray
    Stop-Process -Id $_.Id -Force
}
Start-Sleep -Seconds 1
Write-Host "  ✓ Backend stopped" -ForegroundColor Green
Write-Host ""

# Step 2: Navigate to backend directory
Write-Host "Step 2: Navigating to backend directory..." -ForegroundColor Yellow
Set-Location -Path "Backend\InventoryManagement"
Write-Host "  ✓ In backend directory" -ForegroundColor Green
Write-Host ""

# Step 3: Build
Write-Host "Step 3: Building backend..." -ForegroundColor Yellow
dotnet build
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Build successful" -ForegroundColor Green
} else {
    Write-Host "  ✗ Build failed" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 4: Run
Write-Host "Step 4: Starting backend..." -ForegroundColor Yellow
Write-Host "  Backend will start on http://localhost:5069" -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""
dotnet run
