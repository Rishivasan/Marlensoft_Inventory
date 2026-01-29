# Centralized Pagination Implementation

## Overview
Created a centralized pagination system that can be reused across multiple areas of the application. The pagination follows the exact pattern from your reference: **1, 2, 3, 4, ..., 10** (first 4 pages, then ellipsis, then last page).

## Components Created

### 1. PaginationControls Widget
**File:** `Frontend/inventory/lib/widgets/pagination_controls.dart`

**Features:**
- Standalone pagination controls that can be used anywhere
- Consistent "Show X entries" dropdown on the left
- Centered page numbers with proper logic: 1, 2, 3, 4, ..., last
- Clean styling matching your reference design
- Callback functions for page and rows-per-page changes

### 2. PaginationState Helper Class
**Features:**
- Manages pagination state (current page, rows per page, total items)
- Calculates total pages, first/last row indices
- Provides `getPageItems<T>()` method to extract current page data
- Immutable state with `copyWith()` method

### 3. Updated GenericPaginatedTable
**File:** `Frontend/inventory/lib/widgets/generic_paginated_table.dart`

**Changes:**
- Now uses centralized `PaginationControls`
- Simplified internal logic
- Better state management with `PaginationState`
- Consistent pagination behavior across all tables

### 4. SimplePagination Widget
**File:** `Frontend/inventory/lib/widgets/simple_pagination.dart`

**Purpose:**
- For paginating any list of data without a table structure
- Perfect for card layouts, list views, or custom content
- Uses the same pagination controls for consistency

## Pagination Logic

### Page Number Display Pattern
```
≤ 5 pages:    1 2 3 4 5
> 5 pages:    1 2 3 4 ... 10
```

**Rules:**
- If total pages ≤ 5: Show all page numbers
- If total pages > 5: Show pages 1, 2, 3, 4, then "...", then last page
- This matches your reference image exactly

### Visual Design
```
Show [7] entries              < 1 2 3 4 ... 10 >
```

**Styling:**
- Left: "Show X entries" with dropdown
- Center: Page navigation buttons
- Active page: Blue background (#3B82F6)
- Inactive pages: Transparent background
- No borders on page buttons
- Clean, modern appearance

## Usage Examples

### 1. Table with Pagination (GenericPaginatedTable)
```dart
GenericPaginatedTable<MyModel>(
  data: myDataList,
  rowsPerPage: 7,
  showCheckboxColumn: true,
  headers: [/* column headers */],
  rowBuilder: (item, isSelected, onChanged) => [/* row cells */],
)
```

### 2. Simple List with Pagination (SimplePagination)
```dart
SimplePagination(
  data: myDataList,
  initialRowsPerPage: 10,
  itemBuilder: (pageItems) {
    return ListView.builder(
      itemCount: pageItems.length,
      itemBuilder: (context, index) {
        return MyCustomWidget(data: pageItems[index]);
      },
    );
  },
)
```

### 3. Standalone Pagination Controls
```dart
PaginationControls(
  currentPage: currentPage,
  totalPages: totalPages,
  rowsPerPage: rowsPerPage,
  totalItems: totalItems,
  onPageChanged: (page) => setState(() => currentPage = page),
  onRowsPerPageChanged: (rows) => setState(() => rowsPerPage = rows),
)
```

## Implementation Areas

### ✅ Already Implemented
1. **Master List Screen** - Uses GenericPaginatedTable
2. **Maintenance Table** - Uses GenericPaginatedTable

### 🔄 Can Be Applied To
1. **Allocation Table** - Replace existing pagination
2. **Search Results** - Use SimplePagination
3. **Reports/Lists** - Use SimplePagination
4. **Any Data Grid** - Use GenericPaginatedTable
5. **Custom Lists** - Use PaginationControls directly

## Benefits

### 1. Consistency
- Same pagination behavior across all areas
- Uniform visual design
- Consistent user experience

### 2. Maintainability
- Single source of truth for pagination logic
- Easy to update styling globally
- Centralized bug fixes and improvements

### 3. Flexibility
- Can be used with tables, lists, cards, or any content
- Configurable rows per page options
- Customizable styling through parameters

### 4. Performance
- Efficient rendering (only current page items)
- Proper state management
- Memory-friendly for large datasets

## Migration Guide

### For Existing Tables
1. Replace custom pagination with `GenericPaginatedTable`
2. Update headers to use proper Widget format
3. Update row builders to return List<Widget>

### For New Implementations
1. Use `SimplePagination` for simple lists
2. Use `GenericPaginatedTable` for complex tables
3. Use `PaginationControls` for custom layouts

## Code Structure

```
widgets/
├── pagination_controls.dart      # Core pagination UI
├── generic_paginated_table.dart  # Table with pagination
└── simple_pagination.dart        # Simple list pagination
```

## Testing

All components have been tested with:
- ✅ No compilation errors
- ✅ Proper page calculation (1, 2, 3, 4, ..., last)
- ✅ Rows per page changes
- ✅ State management
- ✅ Visual consistency with reference design

The centralized pagination system is now ready for use across multiple areas of your application, providing consistent behavior and professional appearance!