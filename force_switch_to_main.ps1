# Stop any running .NET processes
Write-Host "Stopping any running .NET processes..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*InventoryManagement*" -or $_.ProcessName -eq "dotnet"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Wait for processes to fully terminate
Start-Sleep -Seconds 3

# Clean build artifacts
Write-Host "Cleaning build artifacts..." -ForegroundColor Yellow
Set-Location "Backend/InventoryManagement"
dotnet clean --verbosity quiet
Set-Location "../.."

Start-Sleep -Seconds 2

# The simplest solution: stash the build artifacts, switch, then drop the stash
Write-Host "Stashing build artifacts..." -ForegroundColor Yellow
git stash push -m "Build artifacts before switching to main"

# Now switch to main
Write-Host "Switching to main branch..." -ForegroundColor Green
git switch main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nSuccessfully switched to main branch!" -ForegroundColor Green
    
    # Drop the stash since we don't need those build files
    Write-Host "Dropping stashed build artifacts..." -ForegroundColor Yellow
    git stash drop
    
    Write-Host "`nAll done!" -ForegroundColor Green
    git log --oneline -3
} else {
    Write-Host "`nFailed to switch. Showing current status..." -ForegroundColor Red
    git status
}
