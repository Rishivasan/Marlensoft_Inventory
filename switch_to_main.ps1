# Stop any running .NET processes
Write-Host "Stopping any running .NET processes..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*InventoryManagement*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Wait a moment for processes to fully terminate
Start-Sleep -Seconds 2

# Clean build artifacts
Write-Host "Cleaning build artifacts..." -ForegroundColor Yellow
Set-Location "Backend/InventoryManagement"
dotnet clean
Set-Location "../.."

# Now switch to main
Write-Host "Switching to main branch..." -ForegroundColor Green
git switch main

Write-Host "Done! You're now on the main branch." -ForegroundColor Green
