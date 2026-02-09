# Master List, Maintenance & Allocation Sorting - Two State Fix

## Changes Made

Updated the sorting functionality in Master List, Maintenance Table, and Allocation Table to use only 2 states instead of 3:
- **Ascending** (up arrow ↑) - Blue color
- **Descending** (down arrow ↓) - Blue color

Removed the "none" state from the sorting cycle.

## Files Modified

### 1. `Frontend/inventory/lib/providers/sorting_provider.dart`
- Updated `sortBy()` method to toggle between ascending and descending only
- When clicking the same column: ascending ↔ descending
- When clicking a different column: starts with ascending
- Applies to all three providers: `sortProvider`, `maintenanceSortProvider`, `allocationSortProvider`

### 2. `Frontend/inventory/lib/widgets/sortable_header.dart`
- Simplified `_buildSortIcon()` to show only 2 states
- Gray arrow for inactive columns
- Blue up arrow for ascending
- Blue down arrow for descending
- Used by all three tables

### 3. `Frontend/inventory/lib/widgets/table_header_helper.dart`
- Updated `_buildSortIcon()` to match the 2-state logic
- Consistent behavior across all sortable headers

### 4. `Frontend/inventory/lib/screens/master_list.dart`
- Updated all `onTap` callbacks for each sortable column
- Removed 3-state logic (none → asc → desc)
- Implemented 2-state toggle (asc ↔ desc)
- Each column now properly sends sorting parameters to backend via `setSorting()`

### 5. `Frontend/inventory/lib/utils/sorting_utils.dart`
- Removed check for `SortDirection.none` in `sortList()` method
- Now only checks if `sortColumn == null`
- Applies to client-side sorting used by Maintenance and Allocation tables

## Behavior

**Before:**
- Click 1: Ascending (up arrow)
- Click 2: Descending (down arrow)
- Click 3: None (gray arrow)
- Click 4: Ascending (cycle repeats)

**After:**
- Click 1: Ascending (up arrow) - Blue
- Click 2: Descending (down arrow) - Blue
- Click 3: Ascending (up arrow) - Blue
- Continues toggling between ascending and descending

## Visual Indicators

- **Inactive column**: Gray down arrow
- **Active ascending**: Blue up arrow (↑)
- **Active descending**: Blue down arrow (↓)

## Implementation Details

### Master List (Server-Side Sorting)
- Uses `paginationProvider.setSorting()` to send sort parameters to backend
- Backend returns sorted data
- Invalidates `paginatedMasterListProvider` to trigger refresh

### Maintenance Table (Client-Side Sorting)
- Uses `SortingUtils.sortMaintenanceList()` for local sorting
- Sorts filtered data in memory
- Uses `maintenanceSortProvider` for state management

### Allocation Table (Client-Side Sorting)
- Uses `SortingUtils.sortAllocationList()` for local sorting
- Sorts filtered data in memory
- Uses `allocationSortProvider` for state management

## Testing

### Master List
1. Open Master List
2. Click any column header's sort arrow
3. Verify it shows blue up arrow (ascending) and data is sorted A→Z
4. Click again - should show blue down arrow (descending) and data is sorted Z→A
5. Click again - should toggle back to blue up arrow (ascending)

### Maintenance Table
1. Open any product detail page
2. Go to "Maintenance & service management" tab
3. Click any column header's sort arrow
4. Verify sorting works with 2-state toggle
5. Verify data order changes correctly

### Allocation Table
1. Open any product detail page
2. Go to "Usage & allocation management" tab
3. Click any column header's sort arrow
4. Verify sorting works with 2-state toggle
5. Verify data order changes correctly
