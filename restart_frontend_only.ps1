# Restart Frontend Only
# Quick script to restart just the Flutter frontend

Write-Host "=== Restarting Frontend ===" -ForegroundColor Cyan
Write-Host ""

# Stop Flutter processes
Write-Host "Stopping Flutter processes..." -ForegroundColor Yellow
Get-Process -Name "flutter" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "dart" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2
Write-Host "  ✓ Flutter stopped" -ForegroundColor Green
Write-Host ""

# Navigate to frontend directory
Write-Host "Navigating to frontend directory..." -ForegroundColor Yellow
Set-Location -Path "Frontend\inventory"
Write-Host "  ✓ In frontend directory" -ForegroundColor Green
Write-Host ""

# Start Flutter
Write-Host "Starting Flutter app..." -ForegroundColor Yellow
Write-Host "  App will open in Chrome" -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""
flutter run -d chrome
