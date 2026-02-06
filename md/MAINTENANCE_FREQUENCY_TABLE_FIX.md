# Maintenance Frequency API Table Name Fix

## Issue
The `GetMaintenanceFrequency` endpoint in `NextServiceController.cs` was returning 500 errors because it was querying incorrect table names.

## Root Cause
The endpoint was using:
- `Tools` instead of `ToolsMaster`
- `Mmds` instead of `MmdsMaster`
- `AssetsConsumables` instead of `AssetsConsumablesMaster`

## Fix Applied
Updated `NextServiceController.cs` to use correct table names:

### GetMaintenanceFrequency Endpoint
```csharp
string query = assetType.ToLower() switch
{
    "tool" => "SELECT MaintainanceFrequency as MaintenanceFrequency FROM ToolsMaster WHERE ToolsId = @AssetId",
    "mmd" => "SELECT CalibrationFrequency as MaintenanceFrequency FROM MmdsMaster WHERE MmdId = @AssetId",
    "asset" => "SELECT MaintenanceFrequency FROM AssetsConsumablesMaster WHERE AssetId = @AssetId AND ItemTypeKey = 1",
    "consumable" => "SELECT MaintenanceFrequency FROM AssetsConsumablesMaster WHERE AssetId = @AssetId AND ItemTypeKey = 2",
    _ => throw new ArgumentException("Invalid asset type")
};
```

### UpdateNextServiceDate Endpoint
```csharp
string updateQuery = request.AssetType.ToLower() switch
{
    "tool" => "UPDATE ToolsMaster SET NextServiceDue = @NextServiceDate WHERE ToolsId = @AssetId",
    "mmd" => "UPDATE MmdsMaster SET NextCalibration = @NextServiceDate WHERE MmdId = @AssetId",
    "asset" => "UPDATE AssetsConsumablesMaster SET NextServiceDue = @NextServiceDate WHERE AssetId = @AssetId AND ItemTypeKey = 1",
    "consumable" => "UPDATE AssetsConsumablesMaster SET NextServiceDue = @NextServiceDate WHERE AssetId = @AssetId AND ItemTypeKey = 2",
    _ => throw new ArgumentException("Invalid asset type")
};
```

## Expected Behavior After Fix
1. When "Add new maintenance service" form opens, it should:
   - Auto-populate Service Date with current Next Service Due date
   - Fetch maintenance frequency from database successfully
   - Auto-calculate Next Service Due Date using Service Date + Maintenance Frequency
   
2. After form submission:
   - Next Service Due should update across all UI components via NextServiceProvider
   - Database should be updated with new Next Service Due date
   - Continuous loop: next service automatically sets up the next service date

## Testing
Backend restarted successfully on `http://localhost:5069`

Next steps:
1. Trigger Flutter app to make a new request to the fixed endpoint
2. Verify that maintenance frequency is fetched successfully
3. Verify that Next Service Due Date auto-calculates in the form
4. Test form submission and verify provider updates

## Files Modified
- `Backend/InventoryManagement/Controllers/NextServiceController.cs`
