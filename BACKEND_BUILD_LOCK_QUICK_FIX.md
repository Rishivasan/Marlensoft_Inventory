# Backend Build Lock - Quick Fix ✅

## Problem

Build error when trying to rebuild the backend:
```
error MSB3027: Could not copy "apphost.exe" to "InventoryManagement.exe"
The file is locked by: "InventoryManagement (36468)"
```

## Cause

The backend process is still running and has locked the executable file, preventing the build from overwriting it.

## Solution

### Quick Fix (3 Steps)

1. **Stop the running backend process**
   ```powershell
   Get-Process -Name "InventoryManagement" -ErrorAction SilentlyContinue | Stop-Process -Force
   ```

2. **Rebuild the backend**
   ```powershell
   dotnet build Backend/InventoryManagement/InventoryManagement.csproj
   ```

3. **Start the backend again**
   ```powershell
   Start-Process -FilePath "dotnet" -ArgumentList "run --project Backend/InventoryManagement/InventoryManagement.csproj" -WorkingDirectory $PWD
   ```

### Alternative: Use the Script

If execution policy allows:
```powershell
.\fix_backend_build_lock.ps1
```

## Prevention

To avoid this issue in the future:

1. **Always stop the backend before rebuilding**
   - Use Task Manager to end "InventoryManagement.exe"
   - Or use PowerShell command above

2. **Use the restart script**
   - `restart_applications.ps1` handles stopping and starting properly

3. **Check running processes**
   ```powershell
   Get-Process -Name "InventoryManagement"
   ```

## Status

✅ **Fixed!**
- Backend process stopped
- Build completed successfully
- Backend restarted on port 5069

## Quick Commands

### Stop Backend
```powershell
Get-Process -Name "InventoryManagement" | Stop-Process -Force
```

### Build Backend
```powershell
dotnet build Backend/InventoryManagement/InventoryManagement.csproj
```

### Run Backend
```powershell
dotnet run --project Backend/InventoryManagement/InventoryManagement.csproj
```

### Check if Running
```powershell
Get-Process -Name "InventoryManagement"
```

---

**Date**: February 9, 2026  
**Status**: ✅ Resolved  
**Backend**: Running on port 5069
