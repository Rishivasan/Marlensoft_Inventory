# Server-Side Pagination Implementation

## Overview
This document describes the complete server-side pagination implementation for the Inventory Management System. The implementation follows the existing codebase patterns and provides efficient data loading with search capabilities.

## Architecture

### Backend (C# .NET)

#### 1. Pagination DTO
**File**: `Backend/InventoryManagement/Models/DTOs/PaginationDto.cs`

```csharp
public class PaginationDto<T>
{
    public int TotalCount { get; set; }
    public int PageNumber { get; set; }
    public int PageSize { get; set; }
    public int TotalPages { get; set; }
    public List<T> Items { get; set; } = new List<T>();
}
```

#### 2. Repository Layer
**File**: `Backend/InventoryManagement/Repositories/MasterRegisterRepository.cs`

**Method**: `GetEnhancedMasterListPaginatedAsync`

Features:
- SQL Server pagination using `OFFSET` and `FETCH NEXT`
- Search functionality across multiple fields (ItemID, Name, Vendor)
- Joins with ToolsMaster, AssetsConsumablesMaster, MmdsMaster
- Includes maintenance and allocation data
- Calculates next service due dates
- Returns total count for pagination calculation

#### 3. Service Layer
**File**: `Backend/InventoryManagement/Services/MasterRegisterService.cs`

**Method**: `GetEnhancedMasterListPaginatedAsync`

Passes through to repository with validation.

#### 4. Controller Layer
**File**: `Backend/InventoryManagement/Controllers/MasterRegisterController.cs`

**Endpoint**: `GET /api/enhanced-master-list/paginated`

Query Parameters:
- `pageNumber` (int, default: 1) - Current page number
- `pageSize` (int, default: 10) - Items per page (max: 100)
- `searchText` (string, optional) - Search filter

Response:
```json
{
  "totalCount": 150,
  "pageNumber": 1,
  "pageSize": 10,
  "totalPages": 15,
  "items": [...]
}
```

### Frontend (Flutter/Dart)

#### 1. Pagination Model
**File**: `Frontend/inventory/lib/model/pagination_model.dart`

Generic pagination model that wraps any data type with pagination metadata.

#### 2. Pagination State Provider
**File**: `Frontend/inventory/lib/providers/pagination_provider.dart`

**State Management**:
- Current page number
- Page size (10, 20, 30, 50)
- Total pages
- Search text

**Actions**:
- `setPage(int)` - Navigate to specific page
- `nextPage()` - Go to next page
- `previousPage()` - Go to previous page
- `setPageSize(int)` - Change items per page
- `setSearchText(String)` - Update search filter
- `reset()` - Reset to initial state

#### 3. Master List Service
**File**: `Frontend/inventory/lib/services/master_list_service.dart`

**Method**: `getMasterListPaginated`

Parameters:
- `pageNumber` (required)
- `pageSize` (required)
- `searchText` (optional)

Returns: `PaginationModel<MasterListModel>`

#### 4. Paginated Provider
**File**: `Frontend/inventory/lib/providers/master_list_provider.dart`

**Provider**: `paginatedMasterListProvider`

- Automatically watches pagination state
- Triggers API call when pagination state changes
- Updates total pages in pagination provider
- Handles loading and error states

#### 5. Pagination Bar Widget
**File**: `Frontend/inventory/lib/widgets/pagination_bar.dart`

**Features**:
- Page size selector (10, 20, 30, 50)
- Previous/Next buttons
- Page number buttons with ellipsis for large page counts
- Current page indicator
- "Page X of Y" display

**UI Design**:
```
[Show [10▼] entries]  [◀ 1 2 3 ... 15 ▶]  [Page 1 of 15]
```

#### 6. Example Screen
**File**: `Frontend/inventory/lib/screens/master_list_paginated.dart`

Complete example implementation showing:
- Header with search and actions
- Paginated table display
- Status badges
- Navigation to detail view
- Empty state handling
- Error handling with retry

## Usage

### Backend API Testing

Run the test script:
```powershell
.\test_pagination_api.ps1
```

Or test manually:
```powershell
# Get first page
Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list/paginated?pageNumber=1&pageSize=10"

# Get second page
Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list/paginated?pageNumber=2&pageSize=10"

# Search with pagination
Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list/paginated?pageNumber=1&pageSize=10&searchText=Tool"
```

### Frontend Integration

#### Option 1: Use the Example Screen
```dart
// Add to router
@RoutePage()
class MasterListPaginatedScreen extends ConsumerStatefulWidget {
  // ... implementation in master_list_paginated.dart
}
```

#### Option 2: Integrate into Existing Screen

```dart
import 'package:inventory/providers/pagination_provider.dart';
import 'package:inventory/providers/master_list_provider.dart';
import 'package:inventory/widgets/pagination_bar.dart';

class YourScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedData = ref.watch(paginatedMasterListProvider);
    
    return Column(
      children: [
        // Your header/search UI
        
        Expanded(
          child: paginatedData.when(
            data: (paginationModel) {
              return YourTableWidget(items: paginationModel.items);
            },
            loading: () => CircularProgressIndicator(),
            error: (e, s) => ErrorWidget(e),
          ),
        ),
        
        // Pagination bar
        PaginationBar(
          onPageChanged: () {
            ref.invalidate(paginatedMasterListProvider);
          },
        ),
      ],
    );
  }
}
```

#### Option 3: Custom Pagination Logic

```dart
// 1. Watch pagination state
final paginationState = ref.watch(paginationProvider);

// 2. Fetch data manually
final service = MasterListService();
final data = await service.getMasterListPaginated(
  pageNumber: paginationState.currentPage,
  pageSize: paginationState.pageSize,
  searchText: paginationState.searchText,
);

// 3. Update total pages
ref.read(paginationProvider.notifier).setTotalPages(data.totalPages);

// 4. Handle page changes
void onPageChange() {
  ref.read(paginationProvider.notifier).nextPage();
  // Refetch data
}
```

## Performance Considerations

### Backend
- **SQL Optimization**: Uses `OFFSET/FETCH` for efficient pagination
- **Indexed Columns**: Ensure ItemID, Type, and search fields are indexed
- **Connection Pooling**: Dapper automatically manages connections
- **Query Caching**: Consider caching total count for frequently accessed data

### Frontend
- **Lazy Loading**: Only loads current page data
- **State Management**: Riverpod efficiently manages state updates
- **Debouncing**: Consider adding debounce to search input
- **Caching**: Previous pages could be cached for faster navigation

## Customization

### Change Default Page Size
```dart
// In pagination_provider.dart
PaginationState({
  this.currentPage = 1,
  this.pageSize = 20, // Change default here
  this.totalPages = 0,
  this.searchText = '',
});
```

### Add More Page Size Options
```dart
// In pagination_bar.dart
items: [10, 20, 30, 50, 100].map((size) { // Add more options
  return DropdownMenuItem(value: size, child: Text('$size'));
}).toList(),
```

### Customize Search Fields
```dart
// In MasterRegisterRepository.cs
AND (@SearchText IS NULL OR @SearchText = '' OR
    m.RefId LIKE '%' + @SearchText + '%' OR
    // Add more fields here
    tm.ToolType LIKE '%' + @SearchText + '%' OR
    ac.Category LIKE '%' + @SearchText + '%'
)
```

## Migration from Client-Side to Server-Side

### Step 1: Update Imports
```dart
// Replace
import 'package:inventory/providers/master_list_provider.dart';

// With
import 'package:inventory/providers/master_list_provider.dart';
import 'package:inventory/providers/pagination_provider.dart';
import 'package:inventory/widgets/pagination_bar.dart';
```

### Step 2: Replace Provider
```dart
// Old (client-side)
final masterListAsync = ref.watch(masterListProvider);

// New (server-side)
final paginatedDataAsync = ref.watch(paginatedMasterListProvider);
```

### Step 3: Update Data Access
```dart
// Old
masterListAsync.when(
  data: (items) => YourWidget(items: items),
  ...
)

// New
paginatedDataAsync.when(
  data: (paginationModel) => YourWidget(items: paginationModel.items),
  ...
)
```

### Step 4: Add Pagination Bar
```dart
Column(
  children: [
    Expanded(child: YourTable()),
    PaginationBar(onPageChanged: () {
      ref.invalidate(paginatedMasterListProvider);
    }),
  ],
)
```

## Testing Checklist

### Backend
- [ ] API returns correct page data
- [ ] Total count is accurate
- [ ] Total pages calculation is correct
- [ ] Search filtering works
- [ ] Page size limits are enforced
- [ ] Invalid page numbers are handled
- [ ] Empty results are handled gracefully

### Frontend
- [ ] Pagination bar displays correctly
- [ ] Page navigation works (next/previous)
- [ ] Direct page selection works
- [ ] Page size change resets to page 1
- [ ] Search resets to page 1
- [ ] Loading states display properly
- [ ] Error states display properly
- [ ] Empty states display properly

## Troubleshooting

### Issue: Total count is incorrect
**Solution**: Check SQL query GROUP BY clause and ensure no duplicate rows

### Issue: Pagination bar not updating
**Solution**: Ensure `onPageChanged` callback invalidates the provider:
```dart
PaginationBar(onPageChanged: () {
  ref.invalidate(paginatedMasterListProvider);
})
```

### Issue: Search not working
**Solution**: Verify search text is being passed to API and SQL LIKE clauses are correct

### Issue: Performance is slow
**Solution**: 
1. Add database indexes on frequently searched columns
2. Reduce page size
3. Optimize SQL query joins
4. Consider caching total count

## Future Enhancements

1. **Advanced Filtering**: Add filters for Type, Status, Location, etc.
2. **Sorting**: Add column sorting with server-side support
3. **Export**: Export current page or all pages to Excel/CSV
4. **Bulk Actions**: Select multiple items across pages
5. **URL State**: Persist pagination state in URL for bookmarking
6. **Infinite Scroll**: Alternative to traditional pagination
7. **Virtual Scrolling**: For very large datasets
8. **Caching**: Cache previous pages for faster navigation

## Summary

This implementation provides:
- ✅ Efficient server-side pagination
- ✅ Search functionality
- ✅ Flexible page size options
- ✅ Clean separation of concerns
- ✅ Reusable components
- ✅ Type-safe implementation
- ✅ Error handling
- ✅ Loading states
- ✅ Responsive UI matching design requirements

The pagination system is production-ready and can handle large datasets efficiently while providing a smooth user experience.
