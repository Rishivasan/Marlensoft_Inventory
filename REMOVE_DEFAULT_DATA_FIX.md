# Remove Default Data from Maintenance & Allocation Tables

## Changes Made

Removed the default/dummy data that was being generated when no data was returned from the API for maintenance and allocation tables.

## File Modified

### `Frontend/inventory/lib/screens/product_detail_screen.dart`

#### Maintenance Table
**Before:**
- If API returned empty data, created 2 sample maintenance records
- Sample data included "ABC Calibration Lab" and "TechFix Pros"

**After:**
- Directly uses data from API
- If no data exists, table shows empty state
- No dummy data generation

#### Allocation Table
**Before:**
- If API returned empty data, created 1 sample allocation record
- Sample data included "John Smith" from "Production Team A"

**After:**
- Directly uses data from API
- If no data exists, table shows empty state
- No dummy data generation

## Code Changes

### Maintenance Data Loading
```dart
// OLD CODE (REMOVED):
List<MaintenanceModel> finalMaintenanceList = maintenance;
if (maintenance.isEmpty) {
  finalMaintenanceList = [/* sample data */];
}
setState(() {
  maintenanceRecords = finalMaintenanceList;
  filteredMaintenanceRecords = finalMaintenanceList;
});

// NEW CODE:
setState(() {
  maintenanceRecords = maintenance;
  filteredMaintenanceRecords = maintenance;
  loadingMaintenance = false;
});
```

### Allocation Data Loading
```dart
// OLD CODE (REMOVED):
List<AllocationModel> finalAllocationList = allocations;
if (allocations.isEmpty) {
  finalAllocationList = [/* sample data */];
}
setState(() {
  allocationRecords = finalAllocationList;
  filteredAllocationRecords = finalAllocationList;
});

// NEW CODE:
setState(() {
  allocationRecords = allocations;
  filteredAllocationRecords = allocations;
  loadingAllocation = false;
});
```

## Impact

- Tables now show only real data from the database
- Empty tables display properly when no records exist
- No confusion between real and dummy data
- Cleaner, more production-ready code

## Testing

1. Open any product detail page
2. Go to "Maintenance & service management" tab
3. Verify only real maintenance records are shown
4. If no records exist, table should be empty (no dummy data)
5. Go to "Usage & allocation management" tab
6. Verify only real allocation records are shown
7. If no records exist, table should be empty (no dummy data)
