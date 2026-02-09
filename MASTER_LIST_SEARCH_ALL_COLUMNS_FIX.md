# Master List Search - All Columns Fix

## Problem
The search functionality in the master list was only searching through:
- Item ID
- Item Name  
- Vendor

Users couldn't search by:
- Type (Tool, Asset, MMD, Consumable)
- Responsible Team
- Next Service Due
- Status (Available, Allocated, In Use)

## Solution
Updated the backend repository to include all columns in the search query.

## Changes Made

### Backend: `MasterRegisterRepository.cs`
Updated the `GetEnhancedMasterListPaginatedAsync` method to add search conditions for:

1. **Type** - Searches the `ItemType` column
2. **Responsible Team** - Searches the ResponsibleTeam field based on item type
3. **Status** - Searches the AvailabilityStatus field
4. **Next Service Due** - Searches both DirectNextServiceDue and MaintenanceNextServiceDue date fields

### Search Query Enhancement
```sql
AND (@SearchText IS NULL OR @SearchText = '' OR
    m.RefId LIKE '%' + @SearchText + '%' OR
    m.ItemType LIKE '%' + @SearchText + '%' OR
    -- Item Name based on type
    CASE 
        WHEN m.ItemType = 'Tool' THEN tm.ToolName
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.AssetName
        WHEN m.ItemType = 'MMD' THEN mm.ModelNumber
        ELSE ''
    END LIKE '%' + @SearchText + '%' OR
    -- Vendor based on type
    CASE
        WHEN m.ItemType = 'Tool' THEN tm.Vendor
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.Vendor
        WHEN m.ItemType = 'MMD' THEN mm.Vendor
        ELSE ''
    END LIKE '%' + @SearchText + '%' OR
    -- Responsible Team based on type
    CASE
        WHEN m.ItemType = 'Tool' THEN tm.ResponsibleTeam
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.ResponsibleTeam
        WHEN m.ItemType = 'MMD' THEN mm.ResponsibleTeam
        ELSE ''
    END LIKE '%' + @SearchText + '%' OR
    -- Availability Status
    CASE 
        WHEN alloc.AvailabilityStatus IS NOT NULL THEN alloc.AvailabilityStatus
        WHEN alloc.AssetId IS NOT NULL AND alloc.ActualReturnDate IS NULL THEN 'Allocated'
        ELSE 'Available'
    END LIKE '%' + @SearchText + '%' OR
    -- Next Service Due dates (converted to string for searching)
    CONVERT(VARCHAR, CASE
        WHEN m.ItemType = 'Tool' THEN tm.NextServiceDue
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.NextServiceDue
        WHEN m.ItemType = 'MMD' THEN mm.NextCalibration
        ELSE NULL
    END, 23) LIKE '%' + @SearchText + '%' OR
    CONVERT(VARCHAR, maint.NextServiceDue, 23) LIKE '%' + @SearchText + '%'
)
```

## Searchable Columns (Complete List)

Now users can search by:
1. ✅ **Item ID** - Asset/Tool/MMD identifier
2. ✅ **Type** - Tool, Asset, MMD, Consumable
3. ✅ **Item Name** - Name of the item
4. ✅ **Vendor** - Supplier/Vendor name
5. ✅ **Responsible Team** - Team responsible for the item
6. ✅ **Next Service Due** - Service due dates (searches date strings like "2025-03-15")
7. ✅ **Status** - Available, Allocated, In Use

## Testing

### How to Test
1. Backend should be running on port 5069
2. Run the test script:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\test_search_all_columns.ps1
   ```

### Test Results
All search tests passed successfully:
- ✅ Search by Type 'Tool': Found 15 items
- ✅ Search by Type 'Consumable': Found 2 items  
- ✅ Search by Responsible Team '2332': Found 1 item
- ✅ Search by Status 'Available': Found 31 items
- ✅ Search by Item Name 'Test': Found 9 items
- ✅ Search by Item ID 'TL': Found 13 items

### Manual Testing Examples
- Search "Tool" → Should find all items with Type = Tool
- Search "Consumable" → Should find all items with Type = Consumable
- Search "2332" → Should find all items with Responsible Team = 2332
- Search "Available" → Should find all items with Status = Available
- Search "Allocated" → Should find all items currently allocated
- Search "2025" → Should find all items with Next Service Due in 2025

## User Experience
Users can now type any value from any visible column in the master list, and the search will find matching items. This makes the search much more powerful and intuitive.

## Notes
- Search is case-insensitive
- Search uses partial matching (LIKE '%searchText%')
- Date searches work with any part of the date (year, month, or full date)
- All existing search functionality (Item ID, Name, Vendor) continues to work as before
