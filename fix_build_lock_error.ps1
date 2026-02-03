# Fix .NET Build Lock Error
# This script helps resolve the MSB3027/MSB3021 build error when InventoryManagement.exe is locked

Write-Host "=== FIXING .NET BUILD LOCK ERROR ===" -ForegroundColor Red
Write-Host ""

Write-Host "Error Details:" -ForegroundColor Yellow
Write-Host "- MSB3027: Could not copy apphost.exe to InventoryManagement.exe"
Write-Host "- MSB3021: File is locked by InventoryManagement process (PID: 30392)"
Write-Host "- Root Cause: Application is still running and blocking the build"
Write-Host ""

Write-Host "=== SOLUTION STEPS ===" -ForegroundColor Green
Write-Host ""

Write-Host "Step 1: Stop the running InventoryManagement process" -ForegroundColor Cyan
Write-Host "Method A - Using Task Manager:"
Write-Host "  1. Press Ctrl+Shift+Esc to open Task Manager"
Write-Host "  2. Find 'InventoryManagement.exe' or 'InventoryManagement'"
Write-Host "  3. Right-click and select 'End Task'"
Write-Host ""

Write-Host "Method B - Using PowerShell (Recommended):" -ForegroundColor Green
Write-Host "  Run this command to stop the process:"
Write-Host "  Get-Process -Name 'InventoryManagement' -ErrorAction SilentlyContinue | Stop-Process -Force"
Write-Host ""

Write-Host "Method C - Using Command Prompt:"
Write-Host "  taskkill /F /IM InventoryManagement.exe"
Write-Host ""

Write-Host "Step 2: Clean and rebuild the project" -ForegroundColor Cyan
Write-Host "  1. dotnet clean"
Write-Host "  2. dotnet build"
Write-Host "  3. dotnet run"
Write-Host ""

Write-Host "Step 3: Alternative - Use different terminal" -ForegroundColor Cyan
Write-Host "  If the process is running in Visual Studio or another terminal:"
Write-Host "  1. Close Visual Studio or the terminal running the app"
Write-Host "  2. Open a new terminal/command prompt"
Write-Host "  3. Navigate to Backend/InventoryManagement"
Write-Host "  4. Run: dotnet build"
Write-Host ""

Write-Host "=== PREVENTION TIPS ===" -ForegroundColor Magenta
Write-Host "To avoid this error in the future:"
Write-Host "✓ Always stop the application (Ctrl+C) before rebuilding"
Write-Host "✓ Close Visual Studio debugger before manual builds"
Write-Host "✓ Use 'dotnet clean' before 'dotnet build' if issues persist"
Write-Host "✓ Check Task Manager for lingering processes"
Write-Host ""

Write-Host "=== AUTOMATED FIX ===" -ForegroundColor Green
Write-Host "Running automated process termination..."

try {
    $processes = Get-Process -Name 'InventoryManagement' -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Host "Found $($processes.Count) InventoryManagement process(es). Stopping..." -ForegroundColor Yellow
        $processes | Stop-Process -Force
        Write-Host "✓ Successfully stopped InventoryManagement processes" -ForegroundColor Green
        Start-Sleep -Seconds 2
        Write-Host "✓ Ready to rebuild the project" -ForegroundColor Green
    } else {
        Write-Host "✓ No InventoryManagement processes found running" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ Could not automatically stop processes. Please use Task Manager." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Navigate to Backend/InventoryManagement directory"
Write-Host "2. Run: dotnet clean"
Write-Host "3. Run: dotnet build"
Write-Host "4. If successful, run: dotnet run"
Write-Host ""
Write-Host "The build should now complete successfully!" -ForegroundColor Green