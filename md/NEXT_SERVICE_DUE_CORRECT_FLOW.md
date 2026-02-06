# Next Service Due - Correct Calculation Flow

## The Correct Flow

### Rule 1: Item WITH Maintenance History
```
IF maintenance service records exist:
    Calculate Next Service Due = Latest Service Date + Maintenance Frequency
```

### Rule 2: Item WITHOUT Maintenance History  
```
IF NO maintenance service records exist:
    Calculate Next Service Due = Created Date + Maintenance Frequency
```

---

## Example Scenarios

### Scenario 1: New Item (No Maintenance Yet)
```
Item: MMD232
Created Date: 2026-02-06
Maintenance Frequency: Monthly
Maintenance History: NONE

Calculation:
  ✓ No maintenance records found
  ✓ Use Created Date: 2026-02-06
  ✓ Calculate: 2026-02-06 + 1 month = 2026-03-06

Result: Next Service Due = 2026-03-06
```

---

### Scenario 2: Item with 1 Maintenance Service
```
Item: MMD232
Created Date: 2026-02-06
Maintenance Frequency: Monthly
Maintenance History:
  - Service Date: 2026-11-08

Calculation:
  ✓ Maintenance records found
  ✓ Latest Service Date: 2026-11-08
  ✓ Calculate: 2026-11-08 + 1 month = 2026-12-08

Result: Next Service Due = 2026-12-08
```

---

### Scenario 3: Item with Multiple Maintenance Services
```
Item: MMD232
Created Date: 2026-02-06
Maintenance Frequency: Monthly
Maintenance History:
  - Service Date: 2026-05-06
  - Service Date: 2026-05-08
  - Service Date: 2026-08-06
  - Service Date: 2026-08-08
  - Service Date: 2026-11-08 ← LATEST

Calculation:
  ✓ Maintenance records found
  ✓ Latest Service Date: 2026-11-08 (most recent)
  ✓ Calculate: 2026-11-08 + 1 month = 2026-12-08

Result: Next Service Due = 2026-12-08
```

---

## Implementation

### Backend Query Changes

#### 1. Fetch Latest Service Date
```sql
LEFT JOIN (
    SELECT 
        AssetId,
        NextServiceDue,
        ServiceDate,
        CreatedDate,
        ROW_NUMBER() OVER (PARTITION BY AssetId ORDER BY 
            ServiceDate DESC,      -- Order by Service Date first (most recent)
            CreatedDate DESC        -- Then by Created Date
        ) as rn
    FROM Maintenance 
    WHERE ServiceDate IS NOT NULL  -- Only records with actual service date
) maint ON m.RefId = maint.AssetId AND maint.rn = 1
```

**What This Does:**
- Gets the LATEST maintenance record based on ServiceDate
- Filters out records without ServiceDate
- Returns only the most recent service (rn = 1)

#### 2. Select Latest Service Date
```sql
-- Latest Service Date from Maintenance table (to calculate next service due)
maint.ServiceDate AS LatestServiceDate,
```

#### 3. Calculation Logic
```csharp
// Check if maintenance frequency exists
if (!string.IsNullOrEmpty(row.MaintenanceFrequency))
{
    // RULE 1: If maintenance history exists, calculate from Latest Service Date
    if (row.LatestServiceDate != null)
    {
        nextServiceDue = CalculateNextServiceDate(row.LatestServiceDate, row.MaintenanceFrequency);
        Console.WriteLine($"DEBUG: Calculated from Latest Service Date for {row.ItemID}: " +
                         $"ServiceDate={row.LatestServiceDate:yyyy-MM-dd}, " +
                         $"Frequency={row.MaintenanceFrequency}, " +
                         $"NextService={nextServiceDue:yyyy-MM-dd}");
    }
    // RULE 2: If NO maintenance history, calculate from Created Date
    else
    {
        nextServiceDue = CalculateNextServiceDate(row.CreatedDate, row.MaintenanceFrequency);
        Console.WriteLine($"DEBUG: Calculated from Created Date for {row.ItemID}: " +
                         $"Created={row.CreatedDate:yyyy-MM-dd}, " +
                         $"Frequency={row.MaintenanceFrequency}, " +
                         $"NextService={nextServiceDue:yyyy-MM-dd}");
    }
}
```

---

## Data Flow

### When Application Opens

```
User Opens Master List
    ↓
GET /api/ItemDetailsV2/enhanced-master-list
    ↓
Backend Query Executes
    ↓
For Each Item:
    ├─→ Fetch Latest Service Date from Maintenance table
    │   (NULL if no maintenance history)
    │
    ├─→ Check if LatestServiceDate exists
    │   │
    │   ├─→ YES: Calculate from LatestServiceDate + Frequency
    │   │   Example: 2026-11-08 + Monthly = 2026-12-08
    │   │
    │   └─→ NO: Calculate from CreatedDate + Frequency
    │       Example: 2026-02-06 + Monthly = 2026-03-06
    │
    └─→ Return Calculated Next Service Due
    ↓
Display in UI
```

---

## Console Logs

### Example Output

```
DEBUG: Calculated from Latest Service Date for MMD232: ServiceDate=2026-11-08, Frequency=Monthly, NextService=2026-12-08
DEBUG: Calculated from Created Date for T999: Created=2026-02-10, Frequency=Monthly, NextService=2026-03-10
```

**Log Interpretation:**
- **"Calculated from Latest Service Date"** = Item has maintenance history
- **"Calculated from Created Date"** = Item has NO maintenance history (new item)

---

## Files Modified

### Backend
**File:** `Backend/InventoryManagement/Repositories/MasterRegisterRepository.cs`

**Changes:**
1. Updated maintenance subquery to order by ServiceDate DESC
2. Added `LatestServiceDate` to SELECT clause
3. Updated calculation logic to check LatestServiceDate first
4. Added LatestServiceDate to GROUP BY clause

---

## Testing

### Test Case 1: New Item Without Maintenance
```
Item: T999
Created: 2026-02-10
Frequency: Monthly
Maintenance: None

Expected: 2026-03-10 (Created + 1 month)
Status: ✅ PASS
```

### Test Case 2: Item With One Maintenance
```
Item: MMD232
Created: 2026-02-06
Frequency: Monthly
Latest Service: 2026-11-08

Expected: 2026-12-08 (Latest Service + 1 month)
Status: ✅ PASS
```

### Test Case 3: Item With Multiple Maintenance
```
Item: MMD232
Created: 2026-02-06
Frequency: Monthly
Services: 2026-05-06, 2026-05-08, 2026-08-06, 2026-08-08, 2026-11-08

Expected: 2026-12-08 (Latest Service 2026-11-08 + 1 month)
Status: ✅ PASS
```

---

## Summary

The system now correctly:
1. ✅ Checks if maintenance history exists
2. ✅ Uses Latest Service Date if maintenance exists
3. ✅ Uses Created Date if NO maintenance exists
4. ✅ Always calculates fresh (not using stored values)
5. ✅ Works correctly after app restart
6. ✅ Reflects in all UI components (Master List, Product Detail, Dialog)

**Status:** ✅ COMPLETE
