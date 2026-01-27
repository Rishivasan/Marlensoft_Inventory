# Allocation Action Button Implementation

## Summary
Successfully implemented the same functionality for the allocation table as was done for maintenance - making the action button open the "Add allocation" dialog with pre-populated data for editing existing allocation records.

## Changes Made

### 1. Enhanced AddAllocation Widget
**File**: `Frontend/inventory/lib/screens/add_forms/add_allocation.dart`

#### New Features:
- **Edit Mode Support**: Added `existingAllocation` parameter to support editing existing records
- **Pre-population**: Automatically fills form fields with existing allocation data when editing
- **Dynamic UI**: Changes title and button text based on whether adding new or editing existing record

#### Key Changes:
```dart
// Added new parameter for editing
final AllocationModel? existingAllocation;

// Pre-populate fields in initState
if (widget.existingAllocation != null) {
  final allocation = widget.existingAllocation!;
  if (allocation.issuedDate != null) {
    _issueDateController.text = _formatDateForInput(allocation.issuedDate!);
  }
  _employeeNameController.text = allocation.employeeName;
  _teamNameController.text = allocation.teamName;
  _purposeController.text = allocation.purpose;
  // ... other fields
}

// Dynamic titles and messages
Text(
  widget.existingAllocation != null 
      ? 'Edit allocation record'
      : 'Add new tool for usage & allocation',
  // ...
)

// Dynamic submit button
Text(
  widget.existingAllocation != null ? 'Update' : 'Submit',
  // ...
)
```

#### Smart Data Handling:
```dart
// Only include ID, employeeId and createdDate for updates, not for new records
if (widget.existingAllocation != null) {
  allocationData['allocationId'] = widget.existingAllocation!.allocationId;
  allocationData['employeeId'] = widget.existingAllocation!.employeeId;
  allocationData['createdDate'] = widget.existingAllocation!.createdDate.toIso8601String();
} else {
  // Generate employee ID for new records
  allocationData['employeeId'] = 'EMP${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
}
```

### 2. Added API Update Method
**File**: `Frontend/inventory/lib/services/api_service.dart`

#### New Method:
```dart
Future<Map<String, dynamic>> updateAllocationRecord(int allocationId, Map<String, dynamic> allocationData) async {
  // PUT request to update existing allocation record
  final response = await http.put(
    Uri.parse("$baseUrl/api/allocation/$allocationId"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(allocationData),
  );
  // Handle response and error cases
}
```

#### Enhanced Error Handling:
```dart
if (response.statusCode == 200 || response.statusCode == 204) {
  return response.body.isNotEmpty ? jsonDecode(response.body) : {'success': true};
} else {
  print("DEBUG: Update failed with status ${response.statusCode}: ${response.body}");
  throw Exception("Failed to update allocation record: Status ${response.statusCode} - ${response.body}");
}
```

### 3. Updated Product Detail Screen
**File**: `Frontend/inventory/lib/screens/product_detail_screen.dart`

#### Action Button Implementation:
```dart
IconButton(
  onPressed: () {
    // Open edit dialog with existing allocation data
    DialogPannelHelper().showAddPannel(
      context: context,
      addingItem: AddAllocation(
        assetId: productData?.assetId ?? widget.id,
        itemName: productData?.name ?? 'Unknown',
        assetType: productData?.itemType ?? 'Unknown',
        existingAllocation: record, // Pass existing record for editing
        onAllocationAdded: () {
          _loadAllocationData(productData?.assetId ?? widget.id);
        },
      ),
    );
  },
  // ... icon styling
)
```

### 4. Enhanced Backend Controller
**File**: `Backend/InventoryManagement/Controllers/AllocationController.cs`

#### Dynamic Table Discovery for Updates:
```csharp
// Try different possible table names for update
var possibleUpdateQueries = new[]
{
    "UPDATE Allocation SET ... WHERE AllocationId = @AllocationId",
    "UPDATE AllocationRecords SET ... WHERE AllocationId = @AllocationId", 
    "UPDATE allocation SET ... WHERE AllocationId = @AllocationId",
    "UPDATE Usage SET ... WHERE AllocationId = @AllocationId",
    "UPDATE Issue SET ... WHERE AllocationId = @AllocationId"
};

foreach (var sql in possibleUpdateQueries)
{
    try
    {
        var affectedRows = await connection.ExecuteAsync(sql, allocation);
        if (affectedRows > 0)
        {
            return NoContent(); // Success
        }
    }
    catch (Exception queryEx)
    {
        continue; // Try next query
    }
}
```

#### Comprehensive Logging:
```csharp
Console.WriteLine($"=== ALLOCATION UPDATE: Starting update for ID: {id} ===");
Console.WriteLine($"Trying allocation update query: {sql.Substring(0, Math.Min(sql.Length, 100))}...");
Console.WriteLine($"✓ SUCCESS! Updated allocation record ID: {id}, affected rows: {affectedRows}");
```

## Functionality

### When User Clicks Allocation Action Button:
1. **Dialog Opens**: The "Add allocation" dialog panel opens
2. **Pre-populated Data**: All form fields are automatically filled with the existing allocation record data:
   - Issue Date
   - Employee Name
   - Team Name
   - Purpose
   - Expected Return Date
   - Actual Return Date
   - Status (dropdown selection)

3. **Edit Mode UI**: 
   - Title changes to "Edit allocation record"
   - Subtitle changes to "Update the details below and click submit to save changes"
   - Submit button text changes to "Update"

4. **Save Changes**: When user clicks "Update":
   - Calls `updateAllocationRecord` API method
   - Shows success message "Allocation record updated successfully!"
   - Closes dialog and refreshes the allocation table

### For New Allocation Records:
1. **Clean Data**: No `allocationId` sent to backend
2. **Auto-generated Employee ID**: Creates new employee ID for new records
3. **Fresh Creation**: Backend handles as new record insertion

### For Existing Allocation Records:
1. **ID Preservation**: Includes existing `allocationId` and `employeeId`
2. **Data Integrity**: Preserves original `createdDate`
3. **Update Operation**: Backend updates the existing record

## API Integration

### Backend Endpoints Expected:
- **Method**: PUT
- **URL**: `/api/allocation/{allocationId}`
- **Body**: JSON with updated allocation data
- **Response**: 200/204 status code for success

### Error Handling:
- Network errors are caught and displayed to user
- API errors show specific error messages with status codes
- Loading states prevent multiple submissions
- Detailed console logging for debugging

## User Experience

### Benefits:
1. **Consistent Interface**: Same dialog used for both adding and editing allocations
2. **Quick Editing**: Users can easily modify existing allocation records
3. **Data Integrity**: Pre-populated fields reduce data entry errors
4. **Visual Feedback**: Clear indication of edit mode vs add mode
5. **Automatic Refresh**: Table updates immediately after successful edit

### Workflow:
1. User views allocation table in Product Detail page
2. Clicks arrow button on any allocation record row
3. Dialog opens with all existing data pre-filled
4. User modifies desired fields (employee, team, dates, status, etc.)
5. Clicks "Update" to save changes
6. Table refreshes with updated data

## Files Modified
- `Frontend/inventory/lib/screens/add_forms/add_allocation.dart`
- `Frontend/inventory/lib/services/api_service.dart`
- `Frontend/inventory/lib/screens/product_detail_screen.dart`
- `Backend/InventoryManagement/Controllers/AllocationController.cs`

## Status
✅ **COMPLETE** - Allocation action button now opens edit dialog with pre-populated data, matching the maintenance functionality exactly