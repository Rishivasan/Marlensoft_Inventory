# Debug Steps for Maintenance Data Issue

## Problem
The maintenance table shows "No maintenance records found" even though there are records in the database with matching AssetId values.

## Debug Steps

### Step 1: Verify Backend is Running
1. Make sure your .NET backend is running:
   ```bash
   cd Backend/InventoryManagement
   dotnet run
   ```
2. You should see output like: `Now listening on: http://localhost:5069`

### Step 2: Test Maintenance API Endpoints
Open your browser or use a tool like Postman to test these URLs:

#### Test 1: Check if maintenance controller is working
```
GET http://localhost:5069/api/maintenance/test
```
**Expected**: Should return total count of maintenance records

#### Test 2: Test specific asset lookup
```
GET http://localhost:5069/api/maintenance/test/MMD001
```
**Expected**: Should return maintenance records for MMD001

#### Test 3: Test the actual endpoint used by the app
```
GET http://localhost:5069/api/maintenance/MMD001
```
**Expected**: Should return maintenance records for MMD001

### Step 3: Check Browser Console
1. Open your Flutter app in the browser
2. Press F12 to open Developer Tools
3. Go to Console tab
4. Click on an item (like MMD001) to open the product detail screen
5. Look for debug messages like:
   ```
   DEBUG: Loading product data for ID: MMD001
   DEBUG: Product data loaded successfully: [item name]
   DEBUG: Loading maintenance data for assetId: MMD001
   DEBUG: _loadMaintenanceData called with assetId: MMD001
   DEBUG: API - getMaintenanceByAssetId called with: MMD001
   DEBUG: API - Calling URL: http://localhost:5069/api/maintenance/MMD001
   DEBUG: API - Maintenance response status: [status code]
   DEBUG: API - Maintenance response body: [response]
   ```

### Step 4: Check Network Tab
1. In Developer Tools, go to Network tab
2. Click on an item to open product detail screen
3. Look for a request to `/api/maintenance/MMD001`
4. Check if the request is:
   - ✅ Being made
   - ✅ Getting a 200 response
   - ✅ Returning data

### Step 5: Verify Database Data
From your screenshot, I can see you have maintenance records:
- AssetId: MMD001, AST001, CON001
- These should match the Asset IDs shown in the product detail screen

## Common Issues and Solutions

### Issue 1: CORS Error
**Symptom**: Network requests are blocked
**Solution**: The backend already has CORS configured for port 3002

### Issue 2: Backend Not Running
**Symptom**: Connection refused errors
**Solution**: Start the backend with `dotnet run`

### Issue 3: Wrong Asset ID Format
**Symptom**: API returns empty array
**Solution**: Check if the Asset ID being passed matches exactly with database values

### Issue 4: Database Connection Issues
**Symptom**: 500 errors from API
**Solution**: Check database connection string in appsettings.json

## Expected Behavior
When you click on "Item MMD001" in the product list:
1. Product detail screen opens
2. Shows item details (name, asset ID, etc.)
3. Maintenance tab shows the 3 maintenance records from your database:
   - Venter Caliper (Calibration, Completed)
   - Dell Service (Preventive, Completed) 
   - M4 Paper (Stock replenishment, Completed)

## Next Steps
1. Follow the debug steps above
2. Share the console output and network requests
3. Test the API endpoints directly
4. Check if the backend is returning the expected data

The debug logging I added will help identify exactly where the issue is occurring.