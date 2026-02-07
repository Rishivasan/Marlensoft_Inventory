# Stop any running .NET processes
Write-Host "Stopping any running .NET processes..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*InventoryManagement*" -or $_.ProcessName -eq "dotnet"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Wait for processes to fully terminate
Start-Sleep -Seconds 3

# Clean build artifacts to release file locks
Write-Host "Cleaning build artifacts..." -ForegroundColor Yellow
Set-Location "Backend/InventoryManagement"
dotnet clean --verbosity quiet
Set-Location "../.."

# Wait a bit more
Start-Sleep -Seconds 2

# Now revert the commit that deleted files
Write-Host "Reverting the commit that deleted files..." -ForegroundColor Green
git reset --hard HEAD~1

Write-Host "`nDone! The deleted files have been restored." -ForegroundColor Green
Write-Host "You are now at commit 518ed20 with all files intact." -ForegroundColor Cyan

# Show current status
git log --oneline -3
