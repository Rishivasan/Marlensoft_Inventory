# SERVER-SIDE PAGINATION - QUICK VIEW
## How It Works in Simple Terms

---

## 🎯 The Concept

**Instead of loading ALL 1,000 items at once, we load only 10 items at a time!**

```
❌ OLD WAY (Client-Side):
Database → Returns ALL 1,000 items → Frontend → Show 10, hide 990

✅ NEW WAY (Server-Side):
Database → Returns ONLY 10 items → Frontend → Show 10
```

---

## 📊 Visual Flow

```
┌─────────────────────────────────────────────────────────────┐
│  USER CLICKS "PAGE 2"                                        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  FRONTEND: PaginationProvider                                │
│  currentPage = 2                                             │
│  pageSize = 10                                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  HTTP REQUEST                                                │
│  GET /api/master-list/paginated?pageNumber=2&pageSize=10    │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  BACKEND: Controller receives request                        │
│  pageNumber = 2, pageSize = 10                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  DATABASE: SQL Query with OFFSET/FETCH                       │
│                                                              │
│  SELECT * FROM Items                                         │
│  ORDER BY CreatedDate DESC                                   │
│  OFFSET 10 ROWS        ← Skip first 10 (page 1)            │
│  FETCH NEXT 10 ROWS    ← Get next 10 (page 2)              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  DATABASE RETURNS: Items 11-20 + TotalCount (1000)          │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  BACKEND: Wraps in JSON                                      │
│  {                                                           │
│    "totalCount": 1000,                                       │
│    "pageNumber": 2,                                          │
│    "pageSize": 10,                                           │
│    "totalPages": 100,                                        │
│    "items": [item11, item12, ..., item20]                   │
│  }                                                           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  FRONTEND: Displays items 11-20                              │
│  Pagination Bar shows: "Page 2 of 100"                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔢 The Math

### Page 1 (Items 1-10):
```sql
OFFSET 0 ROWS      -- Skip 0 items
FETCH NEXT 10 ROWS -- Get items 1-10
```

### Page 2 (Items 11-20):
```sql
OFFSET 10 ROWS     -- Skip first 10 items
FETCH NEXT 10 ROWS -- Get items 11-20
```

### Page 3 (Items 21-30):
```sql
OFFSET 20 ROWS     -- Skip first 20 items
FETCH NEXT 10 ROWS -- Get items 21-30
```

**Formula**: `OFFSET = (PageNumber - 1) × PageSize`

---

## 💻 Code Breakdown

### 1️⃣ Frontend State (What page are we on?)

```dart
// PaginationProvider stores:
currentPage = 2      // We're on page 2
pageSize = 10        // Show 10 items per page
totalPages = 100     // Total 100 pages
searchText = ""      // No search filter
```

### 2️⃣ Frontend Makes API Call

```dart
// When page changes, call API:
final response = await dio.get(
  '/api/master-list/paginated',
  queryParameters: {
    'pageNumber': 2,
    'pageSize': 10,
  }
);
```

### 3️⃣ Backend Builds SQL Query

```csharp
// Repository builds query:
var query = @"
  SELECT *, COUNT(*) OVER() AS TotalCount
  FROM MasterRegister
  ORDER BY CreatedDate DESC
  OFFSET @Offset ROWS
  FETCH NEXT @PageSize ROWS ONLY
";

// Calculate offset:
int offset = (pageNumber - 1) * pageSize;  // (2-1) × 10 = 10

// Execute with parameters:
await connection.QueryAsync(query, new { 
  Offset = 10,      // Skip 10 rows
  PageSize = 10     // Get 10 rows
});
```

### 4️⃣ Database Returns Data

```
Row 1: Item11, TotalCount=1000
Row 2: Item12, TotalCount=1000
Row 3: Item13, TotalCount=1000
...
Row 10: Item20, TotalCount=1000
```

### 5️⃣ Backend Wraps Response

```csharp
return new PaginationDto {
  TotalCount = 1000,
  PageNumber = 2,
  PageSize = 10,
  TotalPages = 100,  // Calculated: ceiling(1000 / 10)
  Items = [item11, item12, ..., item20]
};
```

### 6️⃣ Frontend Displays

```dart
// UI shows:
Table: Items 11-20
Pagination Bar: "◀ 1 [2] 3 ... 100 ▶"
Info: "Page 2 of 100"
```

---

## 🎨 UI Components

### Pagination Bar
```
┌────────────────────────────────────────────────────────┐
│ Show [10▼] entries    ◀ 1 [2] 3 ... 100 ▶   Page 2 of 100 │
└────────────────────────────────────────────────────────┘
```

**Features**:
- **Page Size Selector**: Change items per page (10, 20, 30, 50)
- **Previous Button**: Go to page 1
- **Page Numbers**: Click to jump to specific page
- **Next Button**: Go to page 3
- **Page Info**: Shows current position

---

## 🔍 With Search

### User Searches for "Tool"

```
1. User types "Tool" → Frontend updates searchText = "Tool"
2. Frontend resets to page 1
3. API call: GET /api/master-list/paginated?pageNumber=1&pageSize=10&searchText=Tool
4. Backend adds WHERE clause:
   WHERE ItemName LIKE '%Tool%' OR ItemType LIKE '%Tool%'
5. Database returns: 25 matching items (only first 10)
6. Frontend shows: "Page 1 of 3" (25 items ÷ 10 per page = 3 pages)
```

---

## ⚡ Performance Comparison

### Client-Side Pagination (OLD):
```
Initial Load: 5 seconds (loading 1,000 items)
Memory: 100 MB
Network: 1 MB download
Page Change: Instant (data already loaded)
```

### Server-Side Pagination (NEW):
```
Initial Load: 0.3 seconds (loading 10 items)
Memory: 1 MB
Network: 10 KB download
Page Change: 0.3 seconds (fetch new page)
```

**Result**: 16x faster initial load! 🚀

---

## 🎯 Key Benefits

### 1. Fast Loading
- Only loads what user sees
- No waiting for thousands of items

### 2. Low Memory
- Frontend stores only 10 items
- Not 1,000 items

### 3. Scalable
- Works with 10 items or 10 million items
- Performance stays consistent

### 4. Search Integration
- Search works with pagination
- Only returns matching items

### 5. Flexible Page Sizes
- User can choose 10, 20, 30, or 50 items per page
- Adapts to user preference

---

## 🔄 Complete User Journey

### Scenario: User Browses Master List

```
Step 1: User opens Master List
   → Frontend: Load page 1 (items 1-10)
   → Shows: 10 items, "Page 1 of 100"

Step 2: User clicks "Next"
   → Frontend: currentPage = 2
   → API call: pageNumber=2
   → Database: OFFSET 10, FETCH 10
   → Shows: Items 11-20, "Page 2 of 100"

Step 3: User searches "Tool"
   → Frontend: searchText = "Tool", currentPage = 1
   → API call: pageNumber=1, searchText=Tool
   → Database: WHERE ... LIKE '%Tool%', OFFSET 0, FETCH 10
   → Shows: 10 matching tools, "Page 1 of 3"

Step 4: User changes page size to 20
   → Frontend: pageSize = 20, currentPage = 1
   → API call: pageNumber=1, pageSize=20
   → Database: OFFSET 0, FETCH 20
   → Shows: 20 items, "Page 1 of 50"
```

---

## 📝 Simple Analogy

**Think of it like a book:**

❌ **Client-Side**: 
- Download entire 1,000-page book
- Read only page 1
- 999 pages sitting unused in memory

✅ **Server-Side**:
- Download only page 1 (10 lines)
- Want page 2? Download page 2
- Only store current page in memory

---

## 🎓 Summary

**Server-Side Pagination = Smart Data Loading**

Instead of:
```
Load Everything → Show Some → Hide Rest
```

We do:
```
Load Only What's Needed → Show It → Load More When Needed
```

**Result**:
- ⚡ Faster
- 💾 Less memory
- 📶 Less bandwidth
- 😊 Better user experience

**The Magic SQL**:
```sql
OFFSET (PageNumber - 1) × PageSize ROWS
FETCH NEXT PageSize ROWS ONLY
```

This tells the database: "Skip X rows, give me Y rows" - and that's the secret! 🎉

