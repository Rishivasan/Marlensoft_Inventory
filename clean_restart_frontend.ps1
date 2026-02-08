# Clean Restart Frontend with Cache Clear
# This script does a complete clean restart of the Flutter app

Write-Host "=== Clean Frontend Restart ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Stop Flutter
Write-Host "Step 1: Stopping Flutter..." -ForegroundColor Yellow
Get-Process -Name "flutter" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "dart" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2
Write-Host "  ✓ Flutter stopped" -ForegroundColor Green
Write-Host ""

# Step 2: Navigate to frontend
Write-Host "Step 2: Navigating to frontend directory..." -ForegroundColor Yellow
Set-Location -Path "Frontend\inventory"
Write-Host "  ✓ In frontend directory" -ForegroundColor Green
Write-Host ""

# Step 3: Clean Flutter
Write-Host "Step 3: Cleaning Flutter build cache..." -ForegroundColor Yellow
flutter clean
Write-Host "  ✓ Cache cleaned" -ForegroundColor Green
Write-Host ""

# Step 4: Get dependencies
Write-Host "Step 4: Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host "  ✓ Dependencies updated" -ForegroundColor Green
Write-Host ""

# Step 5: Start Flutter
Write-Host "Step 5: Starting Flutter app..." -ForegroundColor Yellow
Write-Host "  App will open in Chrome" -ForegroundColor Cyan
Write-Host "  Make sure to clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor Yellow
Write-Host "  Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""
flutter run -d chrome
