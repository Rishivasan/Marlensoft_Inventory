# Restart Applications Script
# This script stops running instances and starts fresh ones

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Restarting Inventory Management Apps" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Stop Backend
Write-Host "Step 1: Stopping Backend..." -ForegroundColor Yellow
$backendProcess = Get-Process | Where-Object {$_.ProcessName -like "*InventoryManagement*"}
if ($backendProcess) {
    Write-Host "  Found backend process (PID: $($backendProcess.Id))" -ForegroundColor Gray
    Stop-Process -Id $backendProcess.Id -Force
    Start-Sleep -Seconds 2
    Write-Host "  ✓ Backend stopped" -ForegroundColor Green
} else {
    Write-Host "  No backend process found" -ForegroundColor Gray
}

# Step 2: Stop Frontend (Flutter)
Write-Host ""
Write-Host "Step 2: Stopping Frontend..." -ForegroundColor Yellow
$flutterProcess = Get-Process | Where-Object {$_.ProcessName -like "*flutter*" -or $_.ProcessName -like "*dart*"}
if ($flutterProcess) {
    Write-Host "  Found flutter process (PID: $($flutterProcess.Id))" -ForegroundColor Gray
    Stop-Process -Id $flutterProcess.Id -Force
    Start-Sleep -Seconds 2
    Write-Host "  ✓ Frontend stopped" -ForegroundColor Green
} else {
    Write-Host "  No flutter process found" -ForegroundColor Gray
}

# Step 3: Build Backend
Write-Host ""
Write-Host "Step 3: Building Backend..." -ForegroundColor Yellow
Set-Location "Backend\InventoryManagement"
$buildResult = dotnet build 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Backend build successful" -ForegroundColor Green
} else {
    Write-Host "  ✗ Backend build failed" -ForegroundColor Red
    Write-Host $buildResult
    Set-Location "..\..\"
    exit 1
}
Set-Location "..\..\"

# Step 4: Instructions to start applications
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Build Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To start the applications:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Start Backend:" -ForegroundColor White
Write-Host "   cd Backend\InventoryManagement" -ForegroundColor Gray
Write-Host "   dotnet run" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Start Frontend (in a new terminal):" -ForegroundColor White
Write-Host "   cd Frontend\inventory" -ForegroundColor Gray
Write-Host "   flutter run -d chrome" -ForegroundColor Gray
Write-Host ""
Write-Host "Or use the background process commands in Kiro!" -ForegroundColor Cyan
Write-Host ""
