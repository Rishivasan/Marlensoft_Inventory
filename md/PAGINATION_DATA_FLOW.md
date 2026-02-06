# Pagination Data Flow Diagram

## Complete Request-Response Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           FLUTTER FRONTEND                               │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐
│   User Interaction   │
│  - Click page number │
│  - Change page size  │
│  - Enter search text │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                      PaginationProvider (State)                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │  currentPage: 1                                                    │ │
│  │  pageSize: 10                                                      │ │
│  │  totalPages: 15                                                    │ │
│  │  searchText: "Tool"                                                │ │
│  └────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │ (watches state changes)
                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│              PaginatedMasterListProvider (AsyncNotifier)                 │
│  - Watches PaginationProvider                                            │
│  - Triggers on state change                                              │
│  - Calls MasterListService                                               │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                      MasterListService                                   │
│  getMasterListPaginated(pageNumber, pageSize, searchText)               │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         DioClient (HTTP)                                 │
│  GET /api/enhanced-master-list/paginated                                │
│  ?pageNumber=1&pageSize=10&searchText=Tool                              │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │
                           │ HTTP Request
                           ▼

═══════════════════════════════════════════════════════════════════════════
                          NETWORK BOUNDARY
═══════════════════════════════════════════════════════════════════════════

                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          C# .NET BACKEND                                 │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                    MasterRegisterController                              │
│  [HttpGet("enhanced-master-list/paginated")]                            │
│  - Validates parameters                                                  │
│  - Enforces limits (pageSize max 100)                                    │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                    MasterRegisterService                                 │
│  GetEnhancedMasterListPaginatedAsync()                                  │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                  MasterRegisterRepository                                │
│  GetEnhancedMasterListPaginatedAsync()                                  │
│  - Builds SQL query with pagination                                      │
│  - Applies search filters                                                │
│  - Joins with related tables                                             │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                      DapperContext                                       │
│  - Creates SQL connection                                                │
│  - Executes query                                                        │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                       SQL SERVER DATABASE                                │
│                                                                          │
│  WITH MasterData AS (                                                    │
│    SELECT ... FROM MasterRegister m                                      │
│    LEFT JOIN ToolsMaster tm ...                                          │
│    LEFT JOIN AssetsConsumablesMaster ac ...                              │
│    LEFT JOIN MmdsMaster mm ...                                           │
│    LEFT JOIN Maintenance maint ...                                       │
│    LEFT JOIN Allocation alloc ...                                        │
│    WHERE ... AND searchText filters                                      │
│  )                                                                       │
│  SELECT *, COUNT(*) OVER() AS TotalCount                                │
│  FROM MasterData                                                         │
│  ORDER BY CreatedDate DESC                                               │
│  OFFSET @Offset ROWS                                                     │
│  FETCH NEXT @PageSize ROWS ONLY                                          │
│                                                                          │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │ Returns rows + TotalCount
                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                  MasterRegisterRepository                                │
│  - Maps database rows to EnhancedMasterListDto                          │
│  - Calculates NextServiceDue dates                                       │
│  - Calculates TotalPages = Ceiling(TotalCount / PageSize)               │
│  - Returns PaginationDto<EnhancedMasterListDto>                         │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                    MasterRegisterController                              │
│  Returns JSON:                                                           │
│  {                                                                       │
│    "totalCount": 150,                                                    │
│    "pageNumber": 1,                                                      │
│    "pageSize": 10,                                                       │
│    "totalPages": 15,                                                     │
│    "items": [                                                            │
│      {                                                                   │
│        "itemID": "TL123",                                                │
│        "type": "Tool",                                                   │
│        "itemName": "Wrench",                                             │
│        "vendor": "ACME",                                                 │
│        "storageLocation": "A1",                                          │
│        "responsibleTeam": "Maintenance",                                 │
│        "nextServiceDue": "2026-03-15",                                   │
│        "availabilityStatus": "Available"                                 │
│      },                                                                  │
│      ...                                                                 │
│    ]                                                                     │
│  }                                                                       │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │ HTTP Response
                           ▼

═══════════════════════════════════════════════════════════════════════════
                          NETWORK BOUNDARY
═══════════════════════════════════════════════════════════════════════════

                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                      MasterListService                                   │
│  - Parses JSON response                                                  │
│  - Creates PaginationModel<MasterListModel>                             │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│              PaginatedMasterListProvider                                 │
│  - Updates state with new data                                           │
│  - Updates PaginationProvider.totalPages                                 │
│  - Notifies listeners                                                    │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         UI WIDGETS                                       │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                        Table Widget                                │ │
│  │  Displays items from paginationModel.items                         │ │
│  │  - Item ID, Type, Name, Vendor, Location, etc.                     │ │
│  │  - Status badges                                                   │ │
│  │  - Action buttons                                                  │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                     Pagination Bar                                 │ │
│  │  [Show [10▼] entries]  [◀ 1 2 3 ... 15 ▶]  [Page 1 of 15]        │ │
│  │  - Page size dropdown                                              │ │
│  │  - Previous/Next buttons                                           │ │
│  │  - Page number buttons                                             │ │
│  │  - Page info display                                               │ │
│  └────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────┘
```

## State Flow on User Actions

### 1. User Clicks "Next Page"

```
User clicks Next → PaginationProvider.nextPage()
                 → currentPage: 1 → 2
                 → PaginatedMasterListProvider watches change
                 → Triggers rebuild
                 → Calls API with pageNumber=2
                 → Updates UI with new data
```

### 2. User Changes Page Size

```
User selects 20 → PaginationProvider.setPageSize(20)
                → pageSize: 10 → 20
                → currentPage: reset to 1
                → PaginatedMasterListProvider watches change
                → Triggers rebuild
                → Calls API with pageNumber=1, pageSize=20
                → Updates UI with new data
```

### 3. User Searches

```
User types "Tool" → PaginationProvider.setSearchText("Tool")
                  → searchText: "" → "Tool"
                  → currentPage: reset to 1
                  → PaginatedMasterListProvider watches change
                  → Triggers rebuild
                  → Calls API with searchText="Tool"
                  → Updates UI with filtered data
```

## Data Transformation Flow

```
Database Row (SQL)
    ↓
EnhancedMasterListDto (C#)
    ↓
PaginationDto<EnhancedMasterListDto> (C#)
    ↓
JSON Response
    ↓
Map<String, dynamic> (Dart)
    ↓
MasterListModel (Dart)
    ↓
PaginationModel<MasterListModel> (Dart)
    ↓
UI Widget Display
```

## Performance Optimization Points

```
┌─────────────────────────────────────────────────────────────────┐
│                    OPTIMIZATION LAYERS                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. DATABASE LEVEL                                              │
│     - Indexed columns (ItemID, Type, CreatedDate)               │
│     - Efficient JOIN operations                                 │
│     - OFFSET/FETCH pagination (no full table scan)              │
│     - COUNT(*) OVER() for total count in single query           │
│                                                                 │
│  2. BACKEND LEVEL                                               │
│     - Dapper for fast object mapping                            │
│     - Connection pooling                                        │
│     - Async/await for non-blocking operations                   │
│     - Page size limits (max 100)                                │
│                                                                 │
│  3. NETWORK LEVEL                                               │
│     - Only transfer current page data                           │
│     - Compressed JSON response                                  │
│     - HTTP caching headers (future enhancement)                 │
│                                                                 │
│  4. FRONTEND LEVEL                                              │
│     - Riverpod state management (efficient rebuilds)            │
│     - Lazy loading (only current page)                          │
│     - Debounced search (future enhancement)                     │
│     - Cached previous pages (future enhancement)                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Error Handling Flow

```
Error Occurs
    ↓
┌─────────────────────────────────────────────────────────────────┐
│  WHERE?                                                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Database Error                                                 │
│    → Repository catches                                         │
│    → Logs error                                                 │
│    → Throws exception                                           │
│    → Controller returns 500                                     │
│    → Frontend shows error state                                 │
│                                                                 │
│  Network Error                                                  │
│    → DioClient catches                                          │
│    → Service throws exception                                   │
│    → Provider catches                                           │
│    → AsyncValue.error state                                     │
│    → UI shows error widget with retry button                    │
│                                                                 │
│  Validation Error                                               │
│    → Controller validates                                       │
│    → Returns 400 Bad Request                                    │
│    → Frontend shows validation message                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Caching Strategy (Future Enhancement)

```
┌─────────────────────────────────────────────────────────────────┐
│                      CACHING LAYERS                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Level 1: Frontend Memory Cache                                 │
│    - Cache last 3 pages                                         │
│    - Invalidate on search/filter change                         │
│    - TTL: 5 minutes                                             │
│                                                                 │
│  Level 2: Backend Memory Cache (Redis)                          │
│    - Cache total count per search query                         │
│    - Cache frequently accessed pages                            │
│    - TTL: 10 minutes                                            │
│                                                                 │
│  Level 3: Database Query Cache                                  │
│    - SQL Server query plan cache                                │
│    - Indexed views for common queries                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

This data flow ensures efficient, scalable pagination that can handle large datasets while providing a responsive user experience.
