@echo off
echo Stopping backend processes...
taskkill /F /IM dotnet.exe 2>nul
taskkill /F /IM InventoryManagement.exe 2>nul
timeout /t 3 /nobreak >nul

echo Cleaning build artifacts...
cd Backend\InventoryManagement
dotnet clean >nul 2>&1
cd ..\..
timeout /t 2 /nobreak >nul

echo Reverting to commit 518ed20 (before files were deleted)...
git reset --hard 518ed20

echo.
echo Done! All deleted files have been restored.
echo.
git log --oneline -3
pause
