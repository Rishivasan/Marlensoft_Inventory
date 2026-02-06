# Server-Side Pagination - Quick Start Guide

## 🚀 Quick Implementation (5 Minutes)

### Step 1: Test the Backend API

```powershell
# Run the test script
.\test_pagination_api.ps1
```

Expected output:
```
=== Testing Pagination API ===
Test 1: Get first page (10 items)
Total Count: 150
Page Number: 1
Page Size: 10
Total Pages: 15
Items Returned: 10
✓ Success
```

### Step 2: Use in Your Flutter Screen

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/providers/pagination_provider.dart';
import 'package:inventory/providers/master_list_provider.dart';
import 'package:inventory/widgets/pagination_bar.dart';

class YourScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedData = ref.watch(paginatedMasterListProvider);
    
    return Column(
      children: [
        // Your table/list widget
        Expanded(
          child: paginatedData.when(
            data: (paginationModel) => ListView.builder(
              itemCount: paginationModel.items.length,
              itemBuilder: (context, index) {
                final item = paginationModel.items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.assetId),
                );
              },
            ),
            loading: () => CircularProgressIndicator(),
            error: (e, s) => Text('Error: $e'),
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

### Step 3: Add Search (Optional)

```dart
// In your widget
TextField(
  onSubmitted: (value) {
    ref.read(paginationProvider.notifier).setSearchText(value);
    ref.invalidate(paginatedMasterListProvider);
  },
  decoration: InputDecoration(
    hintText: 'Search...',
    prefixIcon: Icon(Icons.search),
  ),
)
```

## 📋 Complete Example

See `Frontend/inventory/lib/screens/master_list_paginated.dart` for a full working example with:
- ✅ Search functionality
- ✅ Table display
- ✅ Status badges
- ✅ Navigation
- ✅ Error handling
- ✅ Empty states

## 🎨 UI Components

### Pagination Bar
```dart
PaginationBar(
  onPageChanged: () {
    // Refresh data when page changes
    ref.invalidate(paginatedMasterListProvider);
  },
)
```

Features:
- Page size selector (10, 20, 30, 50)
- Previous/Next buttons
- Page number buttons
- Current page indicator

### Pagination State
```dart
// Get current state
final paginationState = ref.watch(paginationProvider);
print('Current page: ${paginationState.currentPage}');
print('Page size: ${paginationState.pageSize}');
print('Total pages: ${paginationState.totalPages}');

// Change page
ref.read(paginationProvider.notifier).setPage(2);

// Change page size
ref.read(paginationProvider.notifier).setPageSize(20);

// Set search text
ref.read(paginationProvider.notifier).setSearchText('Tool');
```

## 🔧 API Endpoints

### Get Paginated Data
```
GET /api/enhanced-master-list/paginated
```

Query Parameters:
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 10, max: 100)
- `searchText` (string, optional)

Response:
```json
{
  "totalCount": 150,
  "pageNumber": 1,
  "pageSize": 10,
  "totalPages": 15,
  "items": [
    {
      "itemID": "TL123",
      "type": "Tool",
      "itemName": "Wrench",
      "vendor": "ACME",
      "storageLocation": "A1",
      "responsibleTeam": "Maintenance",
      "nextServiceDue": "2026-03-15",
      "availabilityStatus": "Available"
    }
  ]
}
```

## 🧪 Testing

### Backend Test
```powershell
# Test first page
Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list/paginated?pageNumber=1&pageSize=10"

# Test search
Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list/paginated?pageNumber=1&pageSize=10&searchText=Tool"
```

### Frontend Test
```dart
// In your test file
testWidgets('Pagination works', (tester) async {
  await tester.pumpWidget(YourApp());
  
  // Verify first page loads
  expect(find.text('Page 1 of 15'), findsOneWidget);
  
  // Click next page
  await tester.tap(find.byIcon(Icons.chevron_right));
  await tester.pumpAndSettle();
  
  // Verify page changed
  expect(find.text('Page 2 of 15'), findsOneWidget);
});
```

## 🎯 Common Use Cases

### 1. Simple Table with Pagination
```dart
Column(
  children: [
    Expanded(
      child: ref.watch(paginatedMasterListProvider).when(
        data: (data) => DataTable(
          columns: [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
          ],
          rows: data.items.map((item) => DataRow(
            cells: [
              DataCell(Text(item.assetId)),
              DataCell(Text(item.name)),
            ],
          )).toList(),
        ),
        loading: () => CircularProgressIndicator(),
        error: (e, s) => Text('Error: $e'),
      ),
    ),
    PaginationBar(onPageChanged: () {
      ref.invalidate(paginatedMasterListProvider);
    }),
  ],
)
```

### 2. With Search and Filters
```dart
Column(
  children: [
    // Search bar
    TextField(
      onSubmitted: (value) {
        ref.read(paginationProvider.notifier).setSearchText(value);
        ref.invalidate(paginatedMasterListProvider);
      },
    ),
    
    // Table
    Expanded(child: YourTable()),
    
    // Pagination
    PaginationBar(onPageChanged: () {
      ref.invalidate(paginatedMasterListProvider);
    }),
  ],
)
```

### 3. With Loading Overlay
```dart
Stack(
  children: [
    Column(
      children: [
        Expanded(child: YourTable()),
        PaginationBar(onPageChanged: () {
          ref.invalidate(paginatedMasterListProvider);
        }),
      ],
    ),
    if (ref.watch(paginatedMasterListProvider).isLoading)
      Container(
        color: Colors.black26,
        child: Center(child: CircularProgressIndicator()),
      ),
  ],
)
```

## 🐛 Troubleshooting

### Issue: Pagination bar not updating
**Solution**: Make sure to call `ref.invalidate(paginatedMasterListProvider)` in `onPageChanged`

### Issue: Search not working
**Solution**: Verify you're calling both:
```dart
ref.read(paginationProvider.notifier).setSearchText(value);
ref.invalidate(paginatedMasterListProvider);
```

### Issue: Total pages showing 0
**Solution**: Check that the backend is returning `totalCount` and `totalPages` in the response

### Issue: Data not refreshing
**Solution**: Use `ref.invalidate()` instead of `ref.refresh()` for immediate updates

## 📚 Next Steps

1. **Customize UI**: Modify `pagination_bar.dart` to match your design
2. **Add Sorting**: Implement column sorting with server-side support
3. **Add Filters**: Add dropdown filters for Type, Status, etc.
4. **Optimize Performance**: Add caching for frequently accessed pages
5. **Add Export**: Implement export functionality for current page or all data

## 🔗 Related Files

- Backend Controller: `Backend/InventoryManagement/Controllers/MasterRegisterController.cs`
- Backend Repository: `Backend/InventoryManagement/Repositories/MasterRegisterRepository.cs`
- Frontend Service: `Frontend/inventory/lib/services/master_list_service.dart`
- Frontend Provider: `Frontend/inventory/lib/providers/master_list_provider.dart`
- Pagination Widget: `Frontend/inventory/lib/widgets/pagination_bar.dart`
- Example Screen: `Frontend/inventory/lib/screens/master_list_paginated.dart`

## 💡 Tips

1. **Always reset to page 1** when changing search or filters
2. **Use `ref.invalidate()`** to trigger data refresh
3. **Handle empty states** gracefully
4. **Show loading indicators** during data fetch
5. **Implement error retry** for better UX
6. **Consider debouncing** search input for better performance
7. **Cache previous pages** for faster navigation (future enhancement)

That's it! You now have a fully functional server-side pagination system. 🎉
