# Master List Search - Quick Reference

## ✅ Status: COMPLETE & WORKING

## Searchable Columns (All 8)

| # | Column | Example Search | What It Finds |
|---|--------|----------------|---------------|
| 1 | **Item ID** | `TL001` | Items with ID containing "TL001" |
| 2 | **Type** | `Tool` | All Tools |
| 3 | **Item Name** | `Test` | Items with "Test" in name |
| 4 | **Vendor** | `ABC Corp` | Items from ABC Corp |
| 5 | **Responsible Team** | `Production` | Items assigned to Production team |
| 6 | **Location** | `Warehouse A` | Items stored in Warehouse A |
| 7 | **Next Service Due** | `2027` or `2027-02-08` | Items with service due in 2027 or specific date |
| 8 | **Status** | `Available` | All available items |

## Quick Examples

```
Search: "Tool"          → Finds all Tools
Search: "Consumable"    → Finds all Consumables  
Search: "Available"     → Finds all Available items
Search: "2332"          → Finds items with team "2332"
Search: "jamil"         → Finds items in location "jamil"
Search: "2027"          → Finds items with service due in 2027
Search: "2027-02-08"    → Finds items with service due on Feb 8, 2027
Search: "TL"            → Finds all items with "TL" in ID
```

## How It Works

- **Case-insensitive**: "tool" = "Tool" = "TOOL"
- **Partial matching**: Searches anywhere in the text
- **Multi-column**: Searches ALL 8 columns at once
- **Date format**: Uses ODBC canonical format (YYYY-MM-DD HH:MI:SS)
- **Fast**: Database-level search with pagination

## Testing

Run the complete test script:
```powershell
powershell -ExecutionPolicy Bypass -File .\test_search_complete.ps1
```

## Backend

- **Port**: 5069
- **Endpoint**: `/api/enhanced-master-list/paginated`
- **Method**: GET
- **Parameters**: `pageNumber`, `pageSize`, `searchText`

## Recent Changes

### Added:
- ✅ **Location (Storage Location)** - Search by where items are stored
- ✅ **Fixed Date Search** - Changed from format 23 to 120 for better date matching

### Date Format Change:
- **Before**: Format 23 (YYYY-MM-DD) - Limited date search
- **After**: Format 120 (YYYY-MM-DD HH:MI:SS) - Full datetime search with better matching

## Files Changed

1. `Backend/InventoryManagement/Repositories/MasterRegisterRepository.cs`
   - Added StorageLocation search condition
   - Changed CONVERT format from 23 to 120 for dates

## No Frontend Changes Needed

The frontend already sends search text to the backend. The backend now handles searching across all 8 columns automatically.

---

**Last Updated**: February 9, 2026  
**Status**: ✅ Working  
**Tested**: ✅ All 8 columns tested and working
