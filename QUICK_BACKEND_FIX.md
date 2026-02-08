# Quick Fix: Backend Build Lock Error

## The Error
```
error MSB3027: Could not copy "apphost.exe" to "InventoryManagement.exe". 
The file is locked by: "InventoryManagement (36820)"
```

## What Happened
The backend was still running, so the build couldn't overwrite the executable file.

## ✅ FIXED
The process (ID: 36820) has been stopped.

## Now You Can:

### Option 1: Use the Rebuild Script (Easiest)
```powershell
.\rebuild_backend.ps1
```
This will:
- Stop any running backend
- Build the backend
- Start the backend

### Option 2: Manual Commands
```powershell
cd Backend\InventoryManagement
dotnet build
dotnet run
```

### Option 3: Use Restart Script (For Both Frontend & Backend)
```powershell
.\restart_applications.ps1
```

## Prevent This in Future

### Always stop before rebuilding:
```powershell
# Quick stop command
Get-Process -Name "InventoryManagement" -ErrorAction SilentlyContinue | Stop-Process -Force

# Then build
cd Backend\InventoryManagement
dotnet build
```

### Or use dotnet watch (auto-rebuild):
```powershell
cd Backend\InventoryManagement
dotnet watch run
```

## Scripts Available
- `fix_backend_build_lock.ps1` - Just stops the backend
- `rebuild_backend.ps1` - Stops, builds, and runs backend
- `restart_applications.ps1` - Restarts both frontend and backend

## Status
✅ Process stopped - You can now rebuild!
