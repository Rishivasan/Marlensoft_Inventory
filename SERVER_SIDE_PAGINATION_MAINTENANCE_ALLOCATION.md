# Server-Side Pagination for Maintenance & Allocation Tables

## Overview
Implementing server-side pagination with sorting and search for Maintenance & Service Management and Usage & Allocation Management tables in the Product Detail screen.

## Backend Implementation ✅

### 1. Maintenance Controller - New Endpoint
**File**: `Backend/InventoryManagement/Controllers/MaintenanceController.cs`

Added new endpoint:
```csharp
[HttpGet("paginated/{assetId}")]
public async Task<ActionResult> GetMaintenancePaginated(
    string assetId,
    [FromQuery] int pageNumber = 1,
    [FromQuery] int pageSize = 5,
    [FromQuery] string? searchText = null,
    [FromQuery] string? sortColumn = null,
    [FromQuery] string? sortDirection = null)
```

**Features**:
- Pagination with OFFSET/FETCH
- Search across: ServiceProviderCompany, ServiceEngineerName, ServiceType, MaintenanceStatus, ResponsibleTeam
- Sorting on: ServiceDate, ServiceProviderCompany, ServiceEngineerName, ServiceType, ResponsibleTeam, NextServiceDue, Cost, MaintenanceStatus
- Returns: `{ totalCount, pageNumber, pageSize, totalPages, items }`

**API Endpoint**: `GET /api/maintenance/paginated/{assetId}?pageNumber=1&pageSize=5&searchText=&sortColumn=serviceDate&sortDirection=DESC`

### 2. Allocation Controller - New Endpoint
**File**: `Backend/InventoryManagement/Controllers/AllocationController.cs`

Added new endpoint:
```csharp
[HttpGet("paginated/{assetId}")]
public async Task<ActionResult> GetAllocationsPaginated(
    string assetId,
    [FromQuery] int pageNumber = 1,
    [FromQuery] int pageSize = 5,
    [FromQuery] string? searchText = null,
    [FromQuery] string? sortColumn = null,
    [FromQuery] string? sortDirection = null)
```

**Features**:
- Pagination with OFFSET/FETCH
- Search across: EmployeeId, EmployeeName, TeamName, Purpose, AvailabilityStatus
- Sorting on: IssuedDate, EmployeeId, EmployeeName, TeamName, Purpose, ExpectedReturnDate, ActualReturnDate, AvailabilityStatus
- Returns: `{ totalCount, pageNumber, pageSize, totalPages, items }`

**API Endpoint**: `GET /api/allocation/paginated/{assetId}?pageNumber=1&pageSize=5&searchText=&sortColumn=issuedDate&sortDirection=DESC`

## Frontend Implementation (Required)

### 1. API Service Methods
**File**: `Frontend/inventory/lib/services/api_service.dart`

Add new methods:
```dart
// Maintenance pagination
Future<Map<String, dynamic>> getMaintenancePaginated(
  String assetId, {
  int pageNumber = 1,
  int pageSize = 5,
  String? searchText,
  String? sortColumn,
  String? sortDirection,
}) async {
  try {
    final queryParams = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      if (searchText != null && searchText.isNotEmpty) 'searchText': searchText,
      if (sortColumn != null && sortColumn.isNotEmpty) 'sortColumn': sortColumn,
      if (sortDirection != null && sortDirection.isNotEmpty) 'sortDirection': sortDirection,
    };
    
    final uri = Uri.parse('$baseUrl/api/maintenance/paginated/$assetId')
        .replace(queryParameters: queryParams);
    
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load paginated maintenance');
    }
  } catch (e) {
    print('Error fetching paginated maintenance: $e');
    rethrow;
  }
}

// Allocation pagination
Future<Map<String, dynamic>> getAllocationsPaginated(
  String assetId, {
  int pageNumber = 1,
  int pageSize = 5,
  String? searchText,
  String? sortColumn,
  String? sortDirection,
}) async {
  try {
    final queryParams = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      if (searchText != null && searchText.isNotEmpty) 'searchText': searchText,
      if (sortColumn != null && sortColumn.isNotEmpty) 'sortColumn': sortColumn,
      if (sortDirection != null && sortDirection.isNotEmpty) 'sortDirection': sortDirection,
    };
    
    final uri = Uri.parse('$baseUrl/api/allocation/paginated/$assetId')
        .replace(queryParameters: queryParams);
    
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load paginated allocations');
    }
  } catch (e) {
    print('Error fetching paginated allocations: $e');
    rethrow;
  }
}
```

### 2. Product Detail Screen Updates
**File**: `Frontend/inventory/lib/screens/product_detail_screen.dart`

#### State Variables (Add these):
```dart
// Pagination state for maintenance
int _maintenanceCurrentPage = 1;
int _maintenancePageSize = 5;
int _maintenanceTotalCount = 0;
int _maintenanceTotalPages = 0;
bool _maintenancePaginationLoading = false;

// Pagination state for allocation
int _allocationCurrentPage = 1;
int _allocationPageSize = 5;
int _allocationTotalCount = 0;
int _allocationTotalPages = 0;
bool _allocationPaginationLoading = false;

// Sort state
String? _maintenanceSortColumn;
String? _maintenanceSortDirection;
String? _allocationSortColumn;
String? _allocationSortDirection;
```

#### Replace Load Methods:
```dart
Future<void> _loadMaintenanceDataPaginated({
  int? page,
  String? searchText,
  String? sortColumn,
  String? sortDirection,
}) async {
  if (!mounted) return;
  
  setState(() {
    _maintenancePaginationLoading = true;
  });

  try {
    final apiService = ApiService();
    final result = await apiService.getMaintenancePaginated(
      productData?.assetId ?? widget.id,
      pageNumber: page ?? _maintenanceCurrentPage,
      pageSize: _maintenancePageSize,
      searchText: searchText ?? _maintenanceSearchController.text,
      sortColumn: sortColumn ?? _maintenanceSortColumn,
      sortDirection: sortDirection ?? _maintenanceSortDirection,
    );

    if (!mounted) return;

    setState(() {
      maintenanceRecords = (result['items'] as List)
          .map((item) => MaintenanceModel.fromJson(item))
          .toList();
      filteredMaintenanceRecords = maintenanceRecords;
      _maintenanceTotalCount = result['totalCount'] ?? 0;
      _maintenanceTotalPages = result['totalPages'] ?? 0;
      _maintenanceCurrentPage = result['pageNumber'] ?? 1;
      _maintenancePaginationLoading = false;
      loadingMaintenance = false;
    });
  } catch (e) {
    print('Error loading paginated maintenance: $e');
    if (!mounted) return;
    setState(() {
      _maintenancePaginationLoading = false;
      loadingMaintenance = false;
    });
  }
}

Future<void> _loadAllocationDataPaginated({
  int? page,
  String? searchText,
  String? sortColumn,
  String? sortDirection,
}) async {
  if (!mounted) return;
  
  setState(() {
    _allocationPaginationLoading = true;
  });

  try {
    final apiService = ApiService();
    final result = await apiService.getAllocationsPaginated(
      productData?.assetId ?? widget.id,
      pageNumber: page ?? _allocationCurrentPage,
      pageSize: _allocationPageSize,
      searchText: searchText ?? _allocationSearchController.text,
      sortColumn: sortColumn ?? _allocationSortColumn,
      sortDirection: sortDirection ?? _allocationSortDirection,
    );

    if (!mounted) return;

    setState(() {
      allocationRecords = (result['items'] as List)
          .map((item) => AllocationModel.fromJson(item))
          .toList();
      filteredAllocationRecords = allocationRecords;
      _allocationTotalCount = result['totalCount'] ?? 0;
      _allocationTotalPages = result['totalPages'] ?? 0;
      _allocationCurrentPage = result['pageNumber'] ?? 1;
      _allocationPaginationLoading = false;
      loadingAllocation = false;
    });
  } catch (e) {
    print('Error loading paginated allocations: $e');
    if (!mounted) return;
    setState(() {
      _allocationPaginationLoading = false;
      loadingAllocation = false;
    });
  }
}
```

#### Update Search Handlers:
```dart
void _onMaintenanceSearchChanged() {
  _maintenanceDebounceTimer?.cancel();
  _maintenanceDebounceTimer = Timer(const Duration(milliseconds: 500), () {
    _loadMaintenanceDataPaginated(
      page: 1, // Reset to first page on search
      searchText: _maintenanceSearchController.text,
    );
  });
}

void _onAllocationSearchChanged() {
  _allocationDebounceTimer?.cancel();
  _allocationDebounceTimer = Timer(const Duration(milliseconds: 500), () {
    _loadAllocationDataPaginated(
      page: 1, // Reset to first page on search
      searchText: _allocationSearchController.text,
    );
  });
}
```

#### Update Table Builders:
Replace `_buildMaintenanceTable()` and `_buildAllocationTable()` to use server-side pagination with custom pagination controls.

### 3. Pagination Controls Widget
Create a simple pagination control widget at the bottom of each table:

```dart
Widget _buildPaginationControls({
  required int currentPage,
  required int totalPages,
  required int totalCount,
  required int pageSize,
  required Function(int) onPageChanged,
  required Function(int) onPageSizeChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Show entries dropdown
        Row(
          children: [
            const Text('Show ', style: TextStyle(fontSize: 12)),
            DropdownButton<int>(
              value: pageSize,
              items: [5, 10, 20, 50].map((size) {
                return DropdownMenuItem(value: size, child: Text('$size'));
              }).toList(),
              onChanged: (value) {
                if (value != null) onPageSizeChanged(value);
              },
            ),
            const Text(' entries', style: TextStyle(fontSize: 12)),
          ],
        ),
        
        // Page info
        Text(
          'Showing ${(currentPage - 1) * pageSize + 1} to ${(currentPage * pageSize > totalCount) ? totalCount : currentPage * pageSize} of $totalCount entries',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        
        // Page navigation
        Row(
          children: [
            IconButton(
              onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
              icon: const Icon(Icons.chevron_left, size: 20),
            ),
            ...List.generate(
              totalPages > 5 ? 5 : totalPages,
              (index) {
                int pageNum = currentPage <= 3
                    ? index + 1
                    : (currentPage >= totalPages - 2
                        ? totalPages - 4 + index
                        : currentPage - 2 + index);
                        
                if (pageNum < 1 || pageNum > totalPages) return const SizedBox.shrink();
                
                return TextButton(
                  onPressed: () => onPageChanged(pageNum),
                  style: TextButton.styleFrom(
                    backgroundColor: pageNum == currentPage
                        ? const Color(0xFF00599A)
                        : Colors.transparent,
                    foregroundColor: pageNum == currentPage
                        ? Colors.white
                        : const Color(0xFF374151),
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text('$pageNum', style: const TextStyle(fontSize: 12)),
                );
              },
            ),
            IconButton(
              onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
              icon: const Icon(Icons.chevron_right, size: 20),
            ),
          ],
        ),
      ],
    ),
  );
}
```

## Testing Steps

### 1. Test Backend Endpoints
```powershell
# Test Maintenance Pagination
Invoke-RestMethod -Uri "http://localhost:5000/api/maintenance/paginated/MMD3232?pageNumber=1&pageSize=5" -Method Get

# Test with search
Invoke-RestMethod -Uri "http://localhost:5000/api/maintenance/paginated/MMD3232?pageNumber=1&pageSize=5&searchText=calibration" -Method Get

# Test with sorting
Invoke-RestMethod -Uri "http://localhost:5000/api/maintenance/paginated/MMD3232?pageNumber=1&pageSize=5&sortColumn=serviceDate&sortDirection=DESC" -Method Get

# Test Allocation Pagination
Invoke-RestMethod -Uri "http://localhost:5000/api/allocation/paginated/MMD3232?pageNumber=1&pageSize=5" -Method Get
```

### 2. Test Frontend
1. Navigate to Product Detail screen
2. Switch to Maintenance & Service Management tab
3. Verify pagination controls appear
4. Test page navigation (previous, next, page numbers)
5. Test page size dropdown (5, 10, 20, 50)
6. Test search functionality
7. Test column sorting
8. Repeat for Usage & Allocation Management tab

## Benefits

1. **Performance**: Only loads required data per page
2. **Scalability**: Handles large datasets efficiently
3. **Consistency**: Same pattern as Master List pagination
4. **User Experience**: Fast response times, smooth interactions
5. **Search & Sort**: Server-side processing for better performance

## Column Mappings

### Maintenance Table
| Frontend Column | Backend Column | Sortable |
|----------------|----------------|----------|
| Service Date | ServiceDate | ✅ |
| Service provider name | ServiceProviderCompany | ✅ |
| Service engineer name | ServiceEngineerName | ✅ |
| Service Type | ServiceType | ✅ |
| Responsible Team | ResponsibleTeam | ✅ |
| Next Service Due | NextServiceDue | ✅ |
| Cost | Cost | ✅ |
| Status | MaintenanceStatus | ✅ |

### Allocation Table
| Frontend Column | Backend Column | Sortable |
|----------------|----------------|----------|
| Issue Date | IssuedDate | ✅ |
| Employee ID | EmployeeId | ✅ |
| Employee Name | EmployeeName | ✅ |
| Team Name | TeamName | ✅ |
| Purpose | Purpose | ✅ |
| Expected Return Date | ExpectedReturnDate | ✅ |
| Actual Return Date | ActualReturnDate | ✅ |
| Status | AvailabilityStatus | ✅ |

## Notes

- Default page size: 5 entries
- Default sort: ServiceDate DESC (Maintenance), IssuedDate DESC (Allocation)
- Search is case-insensitive and searches across multiple columns
- Pagination state is maintained per tab
- Search triggers automatic reset to page 1
