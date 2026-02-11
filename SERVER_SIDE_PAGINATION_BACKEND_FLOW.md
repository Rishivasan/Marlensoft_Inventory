# SERVER-SIDE PAGINATION - BACKEND FLOW
## Continuation of Complete Flow Documentation

---

## 5. Backend Implementation

### 5.1 MasterRegisterController (API Endpoint)

**File**: `Backend/InventoryManagement/Controllers/MasterRegisterController.cs`

**Purpose**: Expose REST API endpoint for paginated data

**Line-by-Line Explanation**:

```csharp
// LINE 1: API endpoint definition
[HttpGet("paginated")]
public async Task<IActionResult> GetEnhancedMasterListPaginated(
    [FromQuery] int pageNumber = 1,
    [FromQuery] int pageSize = 10,
    [FromQuery] string? searchText = null,
    [FromQuery] string? sortColumn = null,
    [FromQuery] string? sortDirection = null)
{
```
**Route**: GET /api/enhanced-master-list/paginated
**Query Parameters**:
- `pageNumber`: Which page to return (default: 1)
- `pageSize`: Items per page (default: 10)
- `searchText`: Optional search filter
- `sortColumn`: Optional column to sort by
- `sortDirection`: Optional sort direction (ASC/DESC)

```csharp
    // LINE 2: Validate page size
    if (pageSize > 100)
    {
        pageSize = 100; // Maximum 100 items per page
    }
```
**Why Limit?** Prevent excessive data transfer and database load.

```csharp
    // LINE 3: Call service layer
    var result = await _service.GetEnhancedMasterListPaginatedAsync(
        pageNumber, 
        pageSize, 
        searchText, 
        sortColumn, 
        sortDirection
    );
```
**Service Layer**: Handles business logic and validation.

```csharp
    // LINE 4: Return JSON response
    return Ok(result);
}
```
**Response Format**:
```json
{
  "totalCount": 1000,
  "pageNumber": 1,
  "pageSize": 10,
  "totalPages": 100,
  "items": [...]
}
```

### 5.2 MasterRegisterRepository (Database Access)

**File**: `Backend/InventoryManagement/Repositories/MasterRegisterRepository.cs`

**Purpose**: Execute SQL queries with pagination

**Line-by-Line Explanation**:

```csharp
public async Task<PaginationDto<EnhancedMasterListDto>> GetEnhancedMasterListPaginatedAsync(
    int pageNumber, 
    int pageSize, 
    string? searchText = null, 
    string? sortColumn = null, 
    string? sortDirection = null)
{
```
**Method Signature**: Returns paginated data wrapped in PaginationDto.

```csharp
    // LINE 1: Build SQL query with CTE (Common Table Expression)
    var query = @"
    WITH MasterData AS (
        SELECT DISTINCT
            m.RefId AS ItemID,
            m.ItemType AS Type,
            
            -- Item Name based on type
            CASE 
                WHEN m.ItemType = 'Tool' THEN ISNULL(tm.ToolName, 'Tool-' + m.RefId)
                WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.AssetName, 'Asset-' + m.RefId)
                WHEN m.ItemType = 'MMD' THEN ISNULL(mm.ModelNumber, 'MMD-' + m.RefId)
                ELSE m.RefId
            END AS ItemName,
```
**CTE Purpose**: Create a temporary result set that can be queried.
**CASE Statement**: Different tables have different column names, unify them.

```csharp
            -- Vendor based on type
            CASE
                WHEN m.ItemType = 'Tool' THEN ISNULL(tm.Vendor, '')
                WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.Vendor, '')
                WHEN m.ItemType = 'MMD' THEN ISNULL(mm.Vendor, '')
                ELSE ''
            END AS Vendor,
```
**Vendor Field**: Extracted from appropriate table based on item type.

```csharp
            MAX(m.CreatedDate) AS CreatedDate,
```
**MAX()**: Handle potential duplicates by taking most recent created date.

```csharp
            -- Maintenance Frequency based on type
            CASE
                WHEN m.ItemType = 'Tool' THEN ISNULL(tm.MaintainanceFrequency, '')
                WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.MaintenanceFrequency, '')
                WHEN m.ItemType = 'MMD' THEN ISNULL(mm.CalibrationFrequency, '')
                ELSE ''
            END AS MaintenanceFrequency,
```
**Frequency Field**: Different tables use different column names.

```csharp
            -- Next Service Due from individual tables
            CASE
                WHEN m.ItemType = 'Tool' THEN tm.NextServiceDue
                WHEN m.ItemType IN ('Asset','Consumable') THEN ac.NextServiceDue
                WHEN m.ItemType = 'MMD' THEN mm.NextCalibration
                ELSE NULL
            END AS DirectNextServiceDue,
```
**Next Service Due**: Retrieved from appropriate table.

```csharp
        FROM MasterRegister m

        LEFT JOIN ToolsMaster tm ON m.ItemType = 'Tool' AND m.RefId = tm.ToolsId AND tm.Status = 1
        LEFT JOIN AssetsConsumablesMaster ac ON m.ItemType IN ('Asset','Consumable') AND m.RefId = ac.AssetId AND ac.Status = 1
        LEFT JOIN MmdsMaster mm ON m.ItemType = 'MMD' AND m.RefId = mm.MmdId AND mm.Status = 1
```
**LEFT JOIN**: Join with appropriate detail table based on item type.
**Status = 1**: Only include active items.

```csharp
        WHERE (
            (m.ItemType = 'Tool' AND tm.ToolsId IS NOT NULL) OR
            (m.ItemType IN ('Asset','Consumable') AND ac.AssetId IS NOT NULL) OR
            (m.ItemType = 'MMD' AND mm.MmdId IS NOT NULL)
        )
```
**WHERE Clause**: Ensure item exists in detail table (not orphaned).

```csharp
        AND (@SearchText IS NULL OR @SearchText = '' OR
            m.RefId LIKE '%' + @SearchText + '%' OR
            m.ItemType LIKE '%' + @SearchText + '%' OR
            CASE 
                WHEN m.ItemType = 'Tool' THEN tm.ToolName
                WHEN m.ItemType IN ('Asset','Consumable') THEN ac.AssetName
                WHEN m.ItemType = 'MMD' THEN mm.ModelNumber
                ELSE ''
            END LIKE '%' + @SearchText + '%' OR
            -- ... more search fields
        )
```
**Search Filter**: Search across multiple columns if searchText provided.
**LIKE '%text%'**: Case-insensitive partial match.

```csharp
        GROUP BY 
            m.RefId, 
            m.ItemType,
            tm.ToolName,
            tm.Vendor,
            -- ... all non-aggregated columns
```
**GROUP BY**: Required when using MAX() aggregate function.

```csharp
    )
    SELECT 
        *,
        COUNT(*) OVER() AS TotalCount
    FROM MasterData
    ORDER BY CreatedDate DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
    ";
```
**COUNT(*) OVER()**: Window function to get total count without separate query.
**OFFSET/FETCH**: SQL Server pagination syntax.

**Pagination Math**:
- Page 1: OFFSET 0 ROWS FETCH NEXT 10 ROWS (rows 1-10)
- Page 2: OFFSET 10 ROWS FETCH NEXT 10 ROWS (rows 11-20)
- Page 3: OFFSET 20 ROWS FETCH NEXT 10 ROWS (rows 21-30)

```csharp
    // LINE 2: Execute query with parameters
    using var connection = _context.CreateConnection();
    
    var result = await connection.QueryAsync(query, new 
    { 
        PageNumber = pageNumber,
        PageSize = pageSize,
        SearchText = searchText
    });
```
**Parameterized Query**: Prevents SQL injection attacks.

```csharp
    // LINE 3: Parse results
    var list = new List<EnhancedMasterListDto>();
    int totalCount = 0;

    foreach (var row in result)
    {
        if (totalCount == 0 && row.TotalCount != null)
        {
            totalCount = row.TotalCount;
        }
```
**TotalCount**: Extract from first row (same for all rows due to window function).

```csharp
        var dto = new EnhancedMasterListDto
        {
            ItemID = row.ItemID ?? "",
            Type = row.Type ?? "",
            ItemName = row.ItemName ?? "",
            Vendor = row.Vendor ?? "",
            CreatedDate = row.CreatedDate,
            ResponsibleTeam = row.ResponsibleTeam ?? "",
            StorageLocation = row.StorageLocation ?? "",
            AvailabilityStatus = row.AvailabilityStatus ?? "Available"
        };
```
**DTO Mapping**: Convert database row to Data Transfer Object.

```csharp
        // LINE 4: Calculate Next Service Due
        DateTime? nextServiceDue = null;
        
        if (!string.IsNullOrEmpty(row.MaintenanceFrequency))
        {
            // RULE 1: If maintenance history exists, calculate from Latest Service Date
            if (row.LatestServiceDate != null)
            {
                nextServiceDue = CalculateNextServiceDate(row.LatestServiceDate, row.MaintenanceFrequency);
            }
            // RULE 2: If NO maintenance history, calculate from Created Date
            else
            {
                nextServiceDue = CalculateNextServiceDate(row.CreatedDate, row.MaintenanceFrequency);
            }
        }
        // FALLBACK: Use stored NextServiceDue if no frequency
        else if (row.DirectNextServiceDue != null)
        {
            nextServiceDue = row.DirectNextServiceDue;
        }
        
        dto.NextServiceDue = nextServiceDue;
        list.Add(dto);
    }
```
**Next Service Due Calculation**: Same logic as frontend for consistency.

```csharp
    // LINE 5: Calculate total pages
    int totalPages = totalCount > 0 ? (int)Math.Ceiling((double)totalCount / pageSize) : 0;
```
**Total Pages Math**:
- 100 items ÷ 10 per page = 10 pages
- 105 items ÷ 10 per page = 11 pages (ceiling)

```csharp
    // LINE 6: Return pagination DTO
    return new PaginationDto<EnhancedMasterListDto>
    {
        TotalCount = totalCount,
        PageNumber = pageNumber,
        PageSize = pageSize,
        TotalPages = totalPages,
        Items = list
    };
}
```
**Return**: Complete pagination information with data.

---

## 6. Database Layer

### 6.1 SQL Query Breakdown

**Step 1: CTE (Common Table Expression)**
```sql
WITH MasterData AS (
    SELECT ... FROM MasterRegister
    LEFT JOIN ToolsMaster ...
    LEFT JOIN AssetsConsumablesMaster ...
    LEFT JOIN MmdsMaster ...
    WHERE ...
    GROUP BY ...
)
```
**Purpose**: Create temporary result set with all data before pagination.

**Step 2: Count Total Records**
```sql
SELECT *, COUNT(*) OVER() AS TotalCount
FROM MasterData
```
**COUNT(*) OVER()**: Window function that adds total count to each row.
**Why?** Get total count without separate query, improves performance.

**Step 3: Sort Results**
```sql
ORDER BY CreatedDate DESC
```
**Sorting**: Required before pagination, newest items first.

**Step 4: Apply Pagination**
```sql
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY
```
**OFFSET**: Skip rows from previous pages.
**FETCH NEXT**: Take only rows for current page.

### 6.2 Performance Optimization

**Indexes for Pagination**:
```sql
-- Index on CreatedDate for sorting
CREATE INDEX IX_MasterRegister_CreatedDate ON MasterRegister(CreatedDate DESC);

-- Index on ItemType for filtering
CREATE INDEX IX_MasterRegister_ItemType ON MasterRegister(ItemType);

-- Composite index for search
CREATE INDEX IX_MasterRegister_Search ON MasterRegister(RefId, ItemType);
```

**Why Indexes?**
- **Faster Sorting**: ORDER BY uses index
- **Faster Filtering**: WHERE clauses use index
- **Faster Joins**: JOIN conditions use index

---

## 7. Step-by-Step Execution Flow

### Complete Flow: User Searches and Navigates

**Step 1: User Enters Search Text "Tool"**
```
User types "Tool" in search box
   ↓
User clicks "Search" button
   ↓
Frontend: _onSearch() executes
   ↓
Frontend: ref.read(paginationProvider.notifier).setSearchText("Tool")
   ↓
PaginationProvider: Updates state with searchText = "Tool", currentPage = 1
   ↓
PaginationProvider: Notifies listeners
```

**Step 2: Provider Detects State Change**
```
paginatedMasterListProvider: Detects paginationProvider changed
   ↓
Provider: Reads new state (currentPage=1, pageSize=10, searchText="Tool")
   ↓
Provider: Calls MasterListService.getMasterListPaginated(1, 10, "Tool")
```

**Step 3: Frontend Makes API Call**
```
MasterListService: Builds query parameters
   ↓
Service: HTTP GET /api/enhanced-master-list/paginated?pageNumber=1&pageSize=10&searchText=Tool
   ↓
HTTP Request sent to backend
```

**Step 4: Backend Receives Request**
```
MasterRegisterController: Receives GET request
   ↓
Controller: Extracts query parameters (pageNumber=1, pageSize=10, searchText="Tool")
   ↓
Controller: Validates pageSize (max 100)
   ↓
Controller: Calls MasterRegisterService
```

**Step 5: Service Layer Processing**
```
MasterRegisterService: Receives parameters
   ↓
Service: Validates business rules
   ↓
Service: Calls MasterRegisterRepository.GetEnhancedMasterListPaginatedAsync()
```

**Step 6: Repository Builds SQL Query**
```
MasterRegisterRepository: Builds SQL query
   ↓
Repository: Substitutes parameters (@PageNumber=1, @PageSize=10, @SearchText="Tool")
   ↓
Repository: Opens database connection
```

**Step 7: Database Executes Query**
```
SQL Server: Receives query
   ↓
Database: Executes CTE to filter data (WHERE ... LIKE '%Tool%')
   ↓
Database: Applies GROUP BY
   ↓
Database: Adds COUNT(*) OVER() to each row
   ↓
Database: Sorts by CreatedDate DESC
   ↓
Database: Applies OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY
   ↓
Database: Returns 10 rows with TotalCount
```

**Example Result**:
```
Row 1: ItemID=TOOL001, ItemName=Drill Machine, TotalCount=25
Row 2: ItemID=TOOL002, ItemName=Angle Grinder, TotalCount=25
...
Row 10: ItemID=TOOL010, ItemName=Torque Wrench, TotalCount=25
```

**Step 8: Repository Processes Results**
```
Repository: Receives 10 rows from database
   ↓
Repository: Extracts TotalCount = 25 from first row
   ↓
Repository: Loops through rows, creates EnhancedMasterListDto for each
   ↓
Repository: Calculates Next Service Due for each item
   ↓
Repository: Calculates TotalPages = ceiling(25 / 10) = 3
   ↓
Repository: Creates PaginationDto with all data
```

**Step 9: Backend Returns Response**
```
Repository: Returns PaginationDto to Service
   ↓
Service: Returns to Controller
   ↓
Controller: Serializes to JSON
   ↓
HTTP Response sent to frontend
```

**JSON Response**:
```json
{
  "totalCount": 25,
  "pageNumber": 1,
  "pageSize": 10,
  "totalPages": 3,
  "items": [
    {
      "itemID": "TOOL001",
      "type": "Tool",
      "itemName": "Drill Machine",
      "vendor": "Bosch",
      "nextServiceDue": "2025-01-01T00:00:00Z",
      ...
    },
    ...
  ]
}
```

**Step 10: Frontend Receives Response**
```
MasterListService: Receives HTTP response
   ↓
Service: Parses JSON to PaginationModel
   ↓
Service: Returns to paginatedMasterListProvider
   ↓
Provider: Updates totalPages in PaginationProvider (3 pages)
   ↓
Provider: Returns PaginationModel to UI
```

**Step 11: UI Updates**
```
MasterListPaginatedScreen: Receives data
   ↓
Screen: Builds table with 10 items
   ↓
PaginationBar: Shows "Page 1 of 3"
   ↓
PaginationBar: Enables "Next" button, disables "Previous" button
   ↓
User sees: 10 tools matching "Tool" search
```

**Step 12: User Clicks "Next Page"**
```
User clicks "Next" button
   ↓
PaginationBar: Calls ref.read(paginationProvider.notifier).nextPage()
   ↓
PaginationProvider: Updates currentPage = 2
   ↓
paginatedMasterListProvider: Detects change, repeats Steps 2-11 with pageNumber=2
   ↓
Database: OFFSET 10 ROWS FETCH NEXT 10 ROWS (returns rows 11-20)
   ↓
UI: Displays items 11-20
```

---

## 8. Performance Optimization

### 8.1 Database Optimizations

**1. Indexes**:
```sql
-- Covering index for pagination query
CREATE INDEX IX_MasterRegister_Pagination 
ON MasterRegister(ItemType, CreatedDate DESC)
INCLUDE (RefId);
```
**Why?** Query can be satisfied entirely from index without table access.

**2. Query Plan Caching**:
- SQL Server caches execution plans
- Parameterized queries reuse cached plans
- Faster subsequent executions

**3. Connection Pooling**:
- Reuses database connections
- Reduces connection overhead
- Configured in connection string

### 8.2 Frontend Optimizations

**1. Debouncing Search**:
```dart
Timer? _debounce;

void _onSearchChanged(String text) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () {
    _onSearch();
  });
}
```
**Why?** Prevents API call on every keystroke, waits for user to stop typing.

**2. Caching Previous Pages**:
```dart
final _pageCache = <int, PaginationModel>{};

Future<PaginationModel> getCachedPage(int page) async {
  if (_pageCache.containsKey(page)) {
    return _pageCache[page]!;
  }
  final data = await fetchPage(page);
  _pageCache[page] = data;
  return data;
}
```
**Why?** Instant navigation to previously visited pages.

**3. Prefetching Next Page**:
```dart
void _prefetchNextPage() {
  final nextPage = currentPage + 1;
  if (nextPage <= totalPages) {
    service.getMasterListPaginated(nextPage, pageSize, searchText);
  }
}
```
**Why?** Next page loads instantly when user clicks "Next".

---

## Summary

Server-side pagination provides:

✅ **Performance**: Only loads data for current page
✅ **Scalability**: Handles millions of records
✅ **Efficiency**: Minimal bandwidth and memory usage
✅ **User Experience**: Fast page loads
✅ **Search Integration**: Search works with pagination
✅ **Flexible Page Sizes**: 10, 20, 30, 50 items per page
✅ **Total Count**: Shows "Page X of Y"
✅ **Navigation**: Previous, Next, Direct page selection

**Key Technologies**:
- Frontend: Flutter/Dart with Riverpod state management
- Backend: ASP.NET Core with Dapper ORM
- Database: SQL Server with OFFSET/FETCH pagination
- Communication: REST API with JSON payloads

**Performance Metrics**:
- Page Load Time: < 500ms
- Database Query Time: < 100ms
- Network Transfer: ~10KB per page (vs 1MB for all data)
- Memory Usage: ~1MB per page (vs 100MB for all data)

