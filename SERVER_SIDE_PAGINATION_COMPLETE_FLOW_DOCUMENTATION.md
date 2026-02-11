# SERVER-SIDE PAGINATION - COMPLETE FLOW DOCUMENTATION
## Line-by-Line Explanation of Implementation

---

## Table of Contents
1. [Overview](#overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Complete Data Flow](#complete-data-flow)
4. [Frontend Implementation](#frontend-implementation)
5. [Backend Implementation](#backend-implementation)
6. [Database Layer](#database-layer)
7. [Step-by-Step Execution Flow](#step-by-step-execution-flow)
8. [Performance Optimization](#performance-optimization)

---

## 1. Overview

### What is Server-Side Pagination?

Server-side pagination is a technique where the database returns only a subset of data (one page) instead of all records at once.

**Example**:
- Total Records: 1,000 items
- Page Size: 10 items per page
- Page 1: Returns items 1-10
- Page 2: Returns items 11-20
- Page 3: Returns items 21-30

### Why Server-Side Pagination?

**Problem with Client-Side Pagination**:
```
Database → Returns ALL 1,000 records → Frontend → Display 10 items
```
- Slow initial load
- High memory usage
- Wasted bandwidth
- Poor performance with large datasets

**Solution with Server-Side Pagination**:
```
Database → Returns ONLY 10 records → Frontend → Display 10 items
```
- Fast initial load
- Low memory usage
- Minimal bandwidth
- Excellent performance even with millions of records

### Benefits

✅ **Performance**: Only loads data for current page
✅ **Scalability**: Handles millions of records efficiently
✅ **Memory**: Low memory footprint
✅ **Bandwidth**: Minimal data transfer
✅ **User Experience**: Fast page loads and smooth navigation

---

## 2. Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                               │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Master List Screen                                           │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐             │  │
│  │  │ Search Box │  │ Page Size  │  │ Pagination │             │  │
│  │  │            │  │ Selector   │  │   Bar      │             │  │
│  │  └────────────┘  └────────────┘  └────────────┘             │  │
│  │  ┌──────────────────────────────────────────────────────┐   │  │
│  │  │  Table (Shows only current page items)               │   │  │
│  │  │  Item 1, Item 2, Item 3, ... Item 10                 │   │  │
│  │  └──────────────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────┬─────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      FRONTEND LAYER (Flutter/Dart)                   │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  PaginationProvider (State Management)                        │  │
│  │  - currentPage: 1                                             │  │
│  │  - pageSize: 10                                               │  │
│  │  - totalPages: 100                                            │  │
│  │  - searchText: ""                                             │  │
│  └────────────────────────┬─────────────────────────────────────┘  │
│                           │                                          │
│  ┌────────────────────────▼─────────────────────────────────────┐  │
│  │  paginatedMasterListProvider (Riverpod Provider)             │  │
│  │  - Watches PaginationProvider                                 │  │
│  │  - Triggers API call when state changes                       │  │
│  │  - Returns PaginationModel<MasterListModel>                   │  │
│  └────────────────────────┬─────────────────────────────────────┘  │
│                           │                                          │
│  ┌────────────────────────▼─────────────────────────────────────┐  │
│  │  MasterListService                                            │  │
│  │  - getMasterListPaginated(pageNumber, pageSize, searchText)  │  │
│  └────────────────────────┬─────────────────────────────────────┘  │
└───────────────────────────┼──────────────────────────────────────────┘
                            │ HTTP API Call
                            │ GET /api/enhanced-master-list/paginated
                            │ ?pageNumber=1&pageSize=10&searchText=Tool
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    BACKEND LAYER (ASP.NET Core/C#)                   │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  MasterRegisterController                                     │  │
│  │  - Receives query parameters                                  │  │
│  │  - Validates input                                            │  │
│  │  - Calls service layer                                        │  │
│  └────────────────────────┬─────────────────────────────────────┘  │
│                           │                                          │
│  ┌────────────────────────▼─────────────────────────────────────┐  │
│  │  MasterRegisterService                                        │  │
│  │  - Business logic validation                                  │  │
│  │  - Calls repository layer                                     │  │
│  └────────────────────────┬─────────────────────────────────────┘  │
│                           │                                          │
│  ┌────────────────────────▼─────────────────────────────────────┐  │
│  │  MasterRegisterRepository                                     │  │
│  │  - GetEnhancedMasterListPaginatedAsync()                      │  │
│  │  - Builds SQL query with OFFSET/FETCH                         │  │
│  │  - Executes query                                             │  │
│  │  - Returns PaginationDto<EnhancedMasterListDto>               │  │
│  └────────────────────────┬─────────────────────────────────────┘  │
└───────────────────────────┼──────────────────────────────────────────┘
                            │ SQL Query
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      DATABASE LAYER (SQL Server)                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  SQL Query with OFFSET/FETCH                                  │  │
│  │                                                                │  │
│  │  WITH MasterData AS (                                         │  │
│  │    SELECT ... FROM MasterRegister                             │  │
│  │    WHERE searchConditions                                     │  │
│  │  )                                                             │  │
│  │  SELECT *, COUNT(*) OVER() AS TotalCount                      │  │
│  │  FROM MasterData                                              │  │
│  │  ORDER BY CreatedDate DESC                                    │  │
│  │  OFFSET (@PageNumber - 1) * @PageSize ROWS                    │  │
│  │  FETCH NEXT @PageSize ROWS ONLY                               │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  Returns: 10 rows + TotalCount (e.g., 1000)                         │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Complete Data Flow

### User Navigates to Page 2

```
Step 1: User clicks "Page 2" button
   ↓
Step 2: Frontend updates PaginationProvider.currentPage = 2
   ↓
Step 3: paginatedMasterListProvider detects state change
   ↓
Step 4: Provider calls MasterListService.getMasterListPaginated(2, 10, "")
   ↓
Step 5: Service makes HTTP GET request:
        /api/enhanced-master-list/paginated?pageNumber=2&pageSize=10
   ↓
Step 6: Backend Controller receives request
   ↓
Step 7: Controller calls Service layer
   ↓
Step 8: Service calls Repository layer
   ↓
Step 9: Repository builds SQL query with OFFSET 10 FETCH NEXT 10
   ↓
Step 10: Database executes query, returns rows 11-20
   ↓
Step 11: Repository wraps data in PaginationDto
   ↓
Step 12: Backend returns JSON response
   ↓
Step 13: Frontend receives response, updates UI
   ↓
Step 14: Table displays items 11-20
```

---

## 4. Frontend Implementation

### 4.1 PaginationProvider (State Management)

**File**: `Frontend/inventory/lib/providers/pagination_provider.dart`

**Purpose**: Manage pagination state (current page, page size, search text)

**Line-by-Line Explanation**:

```dart
// LINE 1: Define pagination state class
class PaginationState {
  final int currentPage;      // Current page number (1-based)
  final int pageSize;         // Items per page (10, 20, 30, 50)
  final int totalPages;       // Total number of pages
  final String searchText;    // Search filter text

  PaginationState({
    this.currentPage = 1,     // Default to first page
    this.pageSize = 10,       // Default to 10 items per page
    this.totalPages = 0,      // Will be set after first API call
    this.searchText = '',     // No search by default
  });
}
```
**Why Immutable?** State objects should be immutable for predictable state management.

```dart
// LINE 2: Create state notifier for pagination
class PaginationNotifier extends StateNotifier<PaginationState> {
  PaginationNotifier() : super(PaginationState());
```
**StateNotifier**: Riverpod's way of managing mutable state.

```dart
  // LINE 3: Navigate to specific page
  void setPage(int page) {
    if (page >= 1 && page <= state.totalPages) {
      state = PaginationState(
        currentPage: page,
        pageSize: state.pageSize,
        totalPages: state.totalPages,
        searchText: state.searchText,
      );
    }
  }
```
**Validation**: Ensures page number is within valid range (1 to totalPages).

```dart
  // LINE 4: Go to next page
  void nextPage() {
    if (state.currentPage < state.totalPages) {
      setPage(state.currentPage + 1);
    }
  }
```
**Boundary Check**: Only increments if not on last page.

```dart
  // LINE 5: Go to previous page
  void previousPage() {
    if (state.currentPage > 1) {
      setPage(state.currentPage - 1);
    }
  }
```
**Boundary Check**: Only decrements if not on first page.

```dart
  // LINE 6: Change page size
  void setPageSize(int size) {
    state = PaginationState(
      currentPage: 1,           // Reset to first page
      pageSize: size,
      totalPages: state.totalPages,
      searchText: state.searchText,
    );
  }
```
**Why Reset to Page 1?** Changing page size invalidates current page position.

```dart
  // LINE 7: Update search text
  void setSearchText(String text) {
    state = PaginationState(
      currentPage: 1,           // Reset to first page
      pageSize: state.pageSize,
      totalPages: state.totalPages,
      searchText: text,
    );
  }
```
**Why Reset to Page 1?** Search results are different, start from beginning.

```dart
  // LINE 8: Set total pages (called after API response)
  void setTotalPages(int total) {
    state = PaginationState(
      currentPage: state.currentPage,
      pageSize: state.pageSize,
      totalPages: total,
      searchText: state.searchText,
    );
  }
```
**When Called**: After receiving API response with total count.

```dart
  // LINE 9: Reset to initial state
  void reset() {
    state = PaginationState();
  }
}
```
**Usage**: Reset pagination when leaving screen or clearing filters.

```dart
// LINE 10: Create provider
final paginationProvider = StateNotifierProvider<PaginationNotifier, PaginationState>((ref) {
  return PaginationNotifier();
});
```
**Provider**: Makes pagination state available throughout the app.

### 4.2 paginatedMasterListProvider (Data Provider)

**File**: `Frontend/inventory/lib/providers/master_list_provider.dart`

**Purpose**: Fetch paginated data from API when pagination state changes

**Line-by-Line Explanation**:

```dart
// LINE 1: Create provider that watches pagination state
final paginatedMasterListProvider = FutureProvider<PaginationModel<MasterListModel>>((ref) async {
```
**FutureProvider**: Automatically handles loading, data, and error states.

```dart
  // LINE 2: Watch pagination state
  final paginationState = ref.watch(paginationProvider);
```
**ref.watch()**: Provider rebuilds when paginationProvider changes.

```dart
  // LINE 3: Create service instance
  final service = MasterListService();
```
**Service**: Handles HTTP API calls.

```dart
  // LINE 4: Fetch paginated data
  final paginationModel = await service.getMasterListPaginated(
    pageNumber: paginationState.currentPage,
    pageSize: paginationState.pageSize,
    searchText: paginationState.searchText.isEmpty ? null : paginationState.searchText,
  );
```
**API Call**: Passes current pagination state to backend.

```dart
  // LINE 5: Update total pages in pagination provider
  ref.read(paginationProvider.notifier).setTotalPages(paginationModel.totalPages);
```
**Update State**: Backend tells us total pages, update provider.

```dart
  // LINE 6: Return data
  return paginationModel;
});
```
**Return**: Provider returns PaginationModel with items and metadata.

### 4.3 MasterListService (API Communication)

**File**: `Frontend/inventory/lib/services/master_list_service.dart`

**Purpose**: Make HTTP API calls to backend

**Line-by-Line Explanation**:

```dart
class MasterListService {
  final Dio _dio = DioClient.getDio();  // LINE 1: HTTP client
```
**Dio**: HTTP client for making REST API calls.

```dart
  // LINE 2: Get paginated master list
  Future<PaginationModel<MasterListModel>> getMasterListPaginated({
    required int pageNumber,
    required int pageSize,
    String? searchText,
  }) async {
```
**Parameters**: Page number, page size, optional search text.

```dart
    try {
      // LINE 3: Build query parameters
      final queryParams = {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (searchText != null && searchText.isNotEmpty) 'searchText': searchText,
      };
```
**Query Params**: Converted to URL query string: `?pageNumber=1&pageSize=10&searchText=Tool`

```dart
      // LINE 4: Make HTTP GET request
      final response = await _dio.get(
        '/api/enhanced-master-list/paginated',
        queryParameters: queryParams,
      );
```
**HTTP GET**: Sends request to backend API endpoint.

```dart
      // LINE 5: Parse response
      if (response.statusCode == 200) {
        final data = response.data;
```
**Success**: Status code 200 means request succeeded.

```dart
        // LINE 6: Extract pagination metadata
        final totalCount = data['totalCount'] as int;
        final pageNum = data['pageNumber'] as int;
        final pageSz = data['pageSize'] as int;
        final totalPages = data['totalPages'] as int;
```
**Metadata**: Backend returns pagination information.

```dart
        // LINE 7: Parse items array
        final itemsList = (data['items'] as List)
            .map((item) => MasterListModel.fromJson(item))
            .toList();
```
**Parsing**: Convert JSON array to list of MasterListModel objects.

```dart
        // LINE 8: Create and return pagination model
        return PaginationModel<MasterListModel>(
          totalCount: totalCount,
          pageNumber: pageNum,
          pageSize: pageSz,
          totalPages: totalPages,
          items: itemsList,
        );
      } else {
        throw Exception('Failed to load paginated data');
      }
    } catch (e) {
      throw Exception('Error fetching paginated master list: $e');
    }
  }
}
```
**Return**: Wrapped data with pagination metadata.

