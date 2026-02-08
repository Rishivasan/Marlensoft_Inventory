# Server-Side Sorting Implementation for Master List

## Problem
The up/down arrow sorting icons in the table headers were not working. Sorting was only applied to the current page (client-side), not across the entire dataset.

## Solution
Implemented server-side sorting that works across the complete dataset, similar to how search works.

## Changes Made

### Frontend Changes

#### 1. **Pagination Provider** (`Frontend/inventory/lib/providers/pagination_provider.dart`)
Added sort parameters to the pagination state:

```dart
class PaginationState {
  final String? sortColumn;
  final String? sortDirection; // 'asc' or 'desc'
  // ... other fields
}

void setSorting(String? column, String? direction) {
  state = state.copyWith(
    sortColumn: column,
    sortDirection: direction,
    currentPage: 1, // Reset to first page when sorting changes
  );
}
```

#### 2. **Master List Provider** (`Frontend/inventory/lib/providers/master_list_provider.dart`)
Updated to pass sort parameters to the service:

```dart
Future<PaginationModel<MasterListModel>> loadPaginatedData({
  required int pageNumber,
  required int pageSize,
  String? searchText,
  String? sortColumn,      // NEW
  String? sortDirection,   // NEW
}) async {
  // Passes sort params to service
}
```

#### 3. **Master List Service** (`Frontend/inventory/lib/services/master_list_service.dart`)
Updated API call to include sort parameters:

```dart
Future<PaginationModel<MasterListModel>> getMasterListPaginated({
  required int pageNumber,
  required int pageSize,
  String? searchText,
  String? sortColumn,      // NEW
  String? sortDirection,   // NEW
}) async {
  final queryParams = {
    'pageNumber': pageNumber,
    'pageSize': pageSize,
    if (searchText != null && searchText.isNotEmpty) 'searchText': searchText,
    if (sortColumn != null && sortColumn.isNotEmpty) 'sortColumn': sortColumn,
    if (sortDirection != null && sortDirection.isNotEmpty) 'sortDirection': sortDirection,
  };
  // Makes API call with sort params
}
```

#### 4. **Master List Screen** (`Frontend/inventory/lib/screens/master_list.dart`)
Connected sortable headers to pagination provider:

```dart
SortableHeader(
  title: "Item ID",
  sortKey: "itemId",
  width: 150,
  sortProvider: sortProvider,
  onTap: () {
    final sortState = ref.read(sortProvider);
    final direction = sortState.sortColumn == "itemId" && 
                     sortState.direction == SortDirection.ascending ? 'desc' : 'asc';
    ref.read(paginationProvider.notifier).setSorting("itemId", direction);
    ref.invalidate(paginatedMasterListProvider);
  },
),
```

This pattern is applied to all sortable columns:
- Item ID
- Type
- Item Name
- Supplier
- Location
- Responsible Team
- Next Service Due
- Status

### Backend Changes

#### 1. **Repository** (`Backend/InventoryManagement/Repositories/MasterRegisterRepository.cs`)
Added dynamic ORDER BY clause:

```csharp
public async Task<PaginationDto<EnhancedMasterListDto>> GetEnhancedMasterListPaginatedAsync(
    int pageNumber, 
    int pageSize, 
    string? searchText = null, 
    string? sortColumn = null,      // NEW
    string? sortDirection = null)   // NEW
{
    // Build dynamic ORDER BY clause
    var orderByClause = "ORDER BY CreatedDate DESC"; // Default
    
    if (!string.IsNullOrEmpty(sortColumn))
    {
        var direction = sortDirection?.ToUpper() == "DESC" ? "DESC" : "ASC";
        
        // Map frontend column names to database column names
        var columnMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            { "itemId", "ItemID" },
            { "type", "Type" },
            { "itemName", "ItemName" },
            { "vendor", "Vendor" },
            { "storageLocation", "StorageLocation" },
            { "responsibleTeam", "ResponsibleTeam" },
            { "nextServiceDue", "COALESCE(MaintenanceNextServiceDue, DirectNextServiceDue)" },
            { "availabilityStatus", "AvailabilityStatus" }
        };
        
        if (columnMap.TryGetValue(sortColumn, out var dbColumn))
        {
            orderByClause = $"ORDER BY {dbColumn} {direction}";
        }
    }
    
    query = query.Replace("{ORDER_BY_CLAUSE}", orderByClause);
}
```

#### 2. **Service & Interface** 
Updated method signatures to include sort parameters:
- `IMasterRegisterRepository.cs`
- `MasterRegisterService.cs`
- `IMasterRegisterService.cs`

#### 3. **Controller** (`Backend/InventoryManagement/Controllers/MasterRegisterController.cs`)
Added sort parameters to the endpoint:

```csharp
[HttpGet("paginated")]
public async Task<IActionResult> GetEnhancedMasterListPaginated(
    [FromQuery] int pageNumber = 1,
    [FromQuery] int pageSize = 10,
    [FromQuery] string? searchText = null,
    [FromQuery] string? sortColumn = null,      // NEW
    [FromQuery] string? sortDirection = null)   // NEW
{
    var data = await _service.GetEnhancedMasterListPaginatedAsync(
        pageNumber, pageSize, searchText, sortColumn, sortDirection);
    return Ok(data);
}
```

## How It Works

```
User clicks sort arrow
    ↓
SortableHeader onTap triggered
    ↓
sortProvider updates (for UI state)
    ↓
paginationProvider.setSorting() called
    ↓
Pagination resets to page 1
    ↓
paginatedMasterListProvider invalidated
    ↓
paginatedMasterListProvider.build() called
    ↓
Reads sortColumn and sortDirection from paginationState
    ↓
Calls API with sort parameters
    ↓
Backend builds dynamic ORDER BY clause
    ↓
SQL query sorts entire dataset
    ↓
Returns sorted page of results
    ↓
Table updates with sorted data ✓
```

## Key Features

1. **Server-side sorting**: Sorts the entire dataset in the database, not just the current page
2. **Automatic page reset**: When sorting changes, automatically goes back to page 1
3. **Column mapping**: Frontend column names are mapped to database column names
4. **Default sorting**: Falls back to CreatedDate DESC if no sort is specified
5. **Cycle through states**: Click once for ascending, twice for descending, three times to clear sort
6. **Visual feedback**: Arrow icons show current sort direction with blue color

## Column Mappings

| Frontend Key | Database Column | Description |
|-------------|----------------|-------------|
| itemId | ItemID | Item identifier |
| type | Type | Item type (Tool/Asset/MMD/Consumable) |
| itemName | ItemName | Name of the item |
| vendor | Vendor | Supplier/Vendor name |
| storageLocation | StorageLocation | Where item is stored |
| responsibleTeam | ResponsibleTeam | Team responsible for item |
| nextServiceDue | COALESCE(MaintenanceNextServiceDue, DirectNextServiceDue) | Next service date (prioritizes maintenance table) |
| availabilityStatus | AvailabilityStatus | Available/Allocated status |

## Testing

1. Open the master list
2. Click any column header's sort arrow
3. First click: Ascending order (arrow up, blue)
4. Second click: Descending order (arrow down, blue)
5. Third click: Clear sort (arrow down, gray)
6. Verify sorting works across all pages, not just current page
7. Try sorting by different columns
8. Combine with search - sorting should work on filtered results

## Files Modified

### Frontend
- `Frontend/inventory/lib/providers/pagination_provider.dart`
- `Frontend/inventory/lib/providers/master_list_provider.dart`
- `Frontend/inventory/lib/services/master_list_service.dart`
- `Frontend/inventory/lib/screens/master_list.dart`

### Backend
- `Backend/InventoryManagement/Repositories/MasterRegisterRepository.cs`
- `Backend/InventoryManagement/Repositories/Interfaces/IMasterRegisterRepository.cs`
- `Backend/InventoryManagement/Services/MasterRegisterService.cs`
- `Backend/InventoryManagement/Services/Interfaces/IMasterRegisterService.cs`
- `Backend/InventoryManagement/Controllers/MasterRegisterController.cs`
