# How to Test the Cache-Busting Fix

## Quick Start

### 1. Start the Backend
```powershell
cd Backend\InventoryManagement
dotnet run
```
Wait for: `Now listening on: http://localhost:5069`

### 2. Start the Frontend (in a new terminal)
```powershell
cd Frontend\inventory
flutter run -d chrome
```
Wait for the application to open in Chrome

### 3. Test Adding a New Item

#### Test Case: Add a Tool
1. Click the "Add new item" button (top right)
2. Select "Add tool" from the dropdown
3. Fill in the form:
   - Tool ID: `TEST_001`
   - Tool name: `Test Tool`
   - Tool type: Select any option
   - Associated product name: `Test Product`
   - Article code: `ART001`
   - Supplier name: `Test Supplier`
   - Storage location: `Warehouse A`
4. Click "Submit"

#### Expected Result ✅
- Success message appears: "Tool added successfully!"
- **The new tool appears IMMEDIATELY in the master list**
- No need to refresh the page
- No need to restart the applications

#### If It Doesn't Work ❌
- Check browser console (F12) for errors
- Verify backend is running on port 5069
- Clear browser cache (Ctrl+Shift+Delete)
- Restart browser completely

### 4. Verify Cache Headers (Optional)

1. Open Chrome DevTools (F12)
2. Go to "Network" tab
3. Add a new item
4. Look for the request to `/api/enhanced-master-list`
5. Check the headers:

**Request Headers should include:**
```
Cache-Control: no-cache, no-store, must-revalidate
Pragma: no-cache
Expires: 0
```

**Response Headers should include:**
```
Cache-Control: no-cache, no-store, must-revalidate
Pragma: no-cache
Expires: 0
```

## What Changed?

### Before the Fix
```
Add Item → Save to DB → Refresh List → Get Cached Data ❌
Result: Old list without new item
```

### After the Fix
```
Add Item → Save to DB → Refresh List → Get Fresh Data ✅
Result: New list with new item immediately
```

## Files Modified

1. **Frontend**: `Frontend/inventory/lib/core/api/dio_client.dart`
   - Added cache-busting headers to all HTTP requests

2. **Backend**: `Backend/InventoryManagement/Controllers/MasterRegisterController.cs`
   - Added cache-busting headers to GET endpoints

3. **Backend**: `Backend/InventoryManagement/Controllers/ItemDetailsV2Controller.cs`
   - Added cache-busting headers to GET endpoints

## Troubleshooting

### Problem: Build Error "File is locked"
**Solution**: Stop the running backend process
```powershell
# Find the process
Get-Process | Where-Object {$_.ProcessName -like "*InventoryManagement*"}

# Stop it (replace PID with actual process ID)
Stop-Process -Id <PID> -Force

# Then rebuild
cd Backend\InventoryManagement
dotnet build
```

### Problem: Port Already in Use
**Solution**: Kill the process using port 5069
```powershell
# Find process using port 5069
netstat -ano | findstr :5069

# Kill it (replace PID with actual process ID)
taskkill /PID <PID> /F
```

### Problem: Flutter Not Found
**Solution**: Ensure Flutter is in your PATH
```powershell
flutter doctor
```

## Success Criteria

✅ Backend builds without errors
✅ Frontend runs without errors
✅ New items appear immediately after adding
✅ No application restarts needed
✅ Cache headers present in network requests
✅ No console errors

## Next Steps

After confirming the fix works:
1. Test with different item types (MMD, Asset, Consumable)
2. Test with multiple items added sequentially
3. Test the paginated view
4. Test editing existing items
5. Monitor performance in production

## Need Help?

Refer to these documents:
- [IMMEDIATE_DATA_REFRESH_FIX.md](./IMMEDIATE_DATA_REFRESH_FIX.md) - Detailed explanation
- [HTTP_CACHING_FIX_DIAGRAM.md](./HTTP_CACHING_FIX_DIAGRAM.md) - Visual diagrams
- [CACHE_BUSTING_QUICK_REFERENCE.md](./CACHE_BUSTING_QUICK_REFERENCE.md) - Quick reference
