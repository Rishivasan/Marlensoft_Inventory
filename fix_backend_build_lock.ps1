# Fix Backend Build Lock Error
# This script stops the running backend process and allows rebuild

Write-Host "=== Fixing Backend Build Lock ===" -ForegroundColor Cyan
Write-Host ""

# Find and stop the InventoryManagement process
Write-Host "Looking for running InventoryManagement processes..." -ForegroundColor Yellow

$processes = Get-Process -Name "InventoryManagement" -ErrorAction SilentlyContinue

if ($processes) {
    Write-Host "Found $($processes.Count) running process(es)" -ForegroundColor Green
    
    foreach ($process in $processes) {
        Write-Host "  - Stopping process ID: $($process.Id)" -ForegroundColor Yellow
        Stop-Process -Id $process.Id -Force
        Start-Sleep -Milliseconds 500
    }
    
    Write-Host ""
    Write-Host "✓ All InventoryManagement processes stopped" -ForegroundColor Green
} else {
    Write-Host "No running InventoryManagement processes found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Process Cleanup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now rebuild the backend:" -ForegroundColor White
Write-Host "  cd Backend\InventoryManagement" -ForegroundColor Gray
Write-Host "  dotnet build" -ForegroundColor Gray
Write-Host ""
Write-Host "Or run the backend:" -ForegroundColor White
Write-Host "  dotnet run" -ForegroundColor Gray
Write-Host ""
