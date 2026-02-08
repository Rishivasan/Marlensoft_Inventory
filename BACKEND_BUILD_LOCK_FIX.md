# Backend Build Lock Error - Quick Fix

## Error Message
```
error MSB3027: Could not copy "apphost.exe" to "InventoryManagement.exe". 
The file is locked by: "InventoryManagement (36820)"
error MSB3021: Unable to copy file. The process cannot access the file because 
it is being used by another process.
```

## Problem
The backend application is still running and has locked the executable file. The build process cannot overwrite the file while it's in use.

## Quick Solutions

### Solution 1: Use PowerShell Script (Recommended)
Run the provided script to automatically stop the process:

```powershell
.\fix_backend_build_lock.ps1
```

Then rebuild:
```powershell
cd Backend\InventoryManagement
dotnet build
```

### Solution 2: Manual Process Kill
1. **Find the process ID** (shown in error: 36820)
2. **Stop the process:**
   ```powershell
   Stop-Process -Id 36820 -Force
   ```
3. **Or stop by name:**
   ```powershell
   Get-Process -Name "InventoryManagement" | Stop-Process -Force
   ```
4. **Rebuild:**
   ```powershell
   dotnet build
   ```

### Solution 3: Task Manager
1. Open Task Manager (Ctrl + Shift + Esc)
2. Find "InventoryManagement.exe" in Processes tab
3. Right-click → End Task
4. Rebuild the project

### Solution 4: Close Terminal/IDE
If the process was started from a terminal or IDE:
1. Close the terminal window running the backend
2. Or stop the debug session in your IDE
3. Rebuild the project

## Prevention

### Use the Restart Script
Instead of manually stopping and starting, use:
```powershell
.\restart_applications.ps1
```

This script properly stops both frontend and backend before restarting.

### Stop Before Building
Always stop the running application before rebuilding:

```powershell
# Stop the backend
Get-Process -Name "InventoryManagement" -ErrorAction SilentlyContinue | Stop-Process -Force

# Wait a moment
Start-Sleep -Seconds 1

# Build
dotnet build

# Run
dotnet run
```

### Use dotnet watch (Development)
For development, use `dotnet watch` which handles rebuilds automatically:

```powershell
cd Backend\InventoryManagement
dotnet watch run
```

This will:
- Automatically rebuild when files change
- Restart the application
- No manual stopping needed

## Common Scenarios

### Scenario 1: Backend Running in Background
**Symptom:** You don't see the backend running but get the error

**Solution:**
```powershell
# Find all instances
Get-Process -Name "InventoryManagement" -ErrorAction SilentlyContinue

# Stop all instances
Get-Process -Name "InventoryManagement" -ErrorAction SilentlyContinue | Stop-Process -Force
```

### Scenario 2: Multiple Instances Running
**Symptom:** Error persists after stopping one process

**Solution:**
```powershell
# Stop ALL instances
Get-Process -Name "InventoryManagement" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Stopping process ID: $($_.Id)"
    Stop-Process -Id $_.Id -Force
}
```

### Scenario 3: Port Already in Use
**Symptom:** After fixing build, get "port 5069 already in use"

**Solution:**
```powershell
# Find process using port 5069
netstat -ano | findstr :5069

# Stop the process (replace PID with actual process ID)
Stop-Process -Id <PID> -Force
```

## Troubleshooting

### Error Persists After Stopping Process
1. **Wait a few seconds** - Process may take time to fully release the file
2. **Check for multiple instances:**
   ```powershell
   Get-Process -Name "InventoryManagement"
   ```
3. **Restart your terminal/IDE**
4. **Restart your computer** (last resort)

### Cannot Stop Process
If you get "Access Denied":

1. **Run PowerShell as Administrator:**
   - Right-click PowerShell
   - Select "Run as Administrator"
   - Run the stop command again

2. **Use Task Manager with Admin rights:**
   - Run Task Manager as Administrator
   - End the process

### File Still Locked
If file remains locked after stopping process:

1. **Check for antivirus/security software** holding the file
2. **Use Process Explorer** (Microsoft Sysinternals) to find what's locking the file
3. **Restart the computer** to clear all locks

## Best Practices

### Development Workflow
1. **Use `dotnet watch run`** for automatic rebuilds during development
2. **Stop before manual builds** - Always stop the app before `dotnet build`
3. **Use the restart script** - Properly stops and starts both frontend and backend
4. **One instance only** - Don't run multiple backend instances

### Build Commands
```powershell
# Development (auto-rebuild on changes)
dotnet watch run

# Manual build and run
Get-Process -Name "InventoryManagement" -ErrorAction SilentlyContinue | Stop-Process -Force
dotnet build
dotnet run

# Clean build (if issues persist)
Get-Process -Name "InventoryManagement" -ErrorAction SilentlyContinue | Stop-Process -Force
dotnet clean
dotnet build
dotnet run
```

## Quick Reference

### Stop Backend
```powershell
Get-Process -Name "InventoryManagement" -ErrorAction SilentlyContinue | Stop-Process -Force
```

### Stop and Rebuild
```powershell
Get-Process -Name "InventoryManagement" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1
cd Backend\InventoryManagement
dotnet build
```

### Stop, Rebuild, and Run
```powershell
Get-Process -Name "InventoryManagement" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1
cd Backend\InventoryManagement
dotnet build
dotnet run
```

### Use Restart Script
```powershell
.\restart_applications.ps1
```

## Status
✅ **RESOLVED** - Use any of the solutions above to stop the running process and rebuild

## Related Files
- `fix_backend_build_lock.ps1` - Automated fix script
- `restart_applications.ps1` - Proper restart script for both frontend and backend
