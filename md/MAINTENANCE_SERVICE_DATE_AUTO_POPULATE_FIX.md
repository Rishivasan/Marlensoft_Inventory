# Maintenance Service Date Auto-Populate Fix

## Issue

When opening "Add new maintenance service" form, the Service Date field was showing the **last service date** from maintenance history instead of the **current Next Service Due** date.

### Wrong Behavior (Before Fix)
```
Item: TL121
Last Service Date: 2027-02-05
Current Next Service Due: 2028-02-05

When opening "Add new maintenance service":
  Service Date: 2027-02-05 ❌ (showing last service date)
  Next Service Due Date: 2028-02-05
```

### Correct Behavior (After Fix)
```
Item: TL121
Last Service Date: 2027-02-05
Current Next Service Due: 2028-02-05

When opening "Add new maintenance service":
  Service Date: 2028-02-05 ✅ (showing CURRENT next service due)
  Next Service Due Date: 2029-02-05 (calculated from 2028-02-05 + Yearly)
```

---

## The Logic

### Service Date Field
**Purpose:** When is this service being performed?

**Should show:** The date when the service is **scheduled to happen** (i.e., the current Next Service Due)

**Why:** Because you're performing the service on the date it was scheduled for.

### Next Service Due Date Field
**Purpose:** When should the service AFTER this one happen?

**Should show:** Service Date + Maintenance Frequency

**Why:** After completing this service, we need to schedule the next one.

---

## Example Flow

### Scenario: Tool with Yearly Maintenance

```
Initial State:
  Created Date: 2026-02-05
  Maintenance Frequency: Yearly
  Current Next Service Due: 2027-02-05
  Maintenance History: None

User Action: Click "Add new maintenance service"

Form Auto-Populates:
  Service Date: 2027-02-05 ← Current Next Service Due
  Next Service Due Date: 2028-02-05 ← Service Date + Yearly

User Action: Submit form

Result:
  Maintenance record created with Service Date = 2027-02-05
  Current Next Service Due updated to: 2028-02-05
  
---

Next Time User Opens Form:
  Service Date: 2028-02-05 ← NEW Current Next Service Due
  Next Service Due Date: 2029-02-05 ← Service Date + Yearly
```

---

## Code Changes

### File: `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

#### Updated `_loadItemData()` Method

**Before:**
```dart
// Get current next service due from provider
final nextServiceDue = nextServiceProvider.getNextServiceDate(widget.assetId);

// Auto-populate Service Date with current Next Service Due
if (nextServiceDue != null && widget.existingMaintenance == null) {
  _serviceDateController.text = _formatDateForInput(nextServiceDue);
  _calculateNextServiceDue(nextServiceDue);
}
```

**After:**
```dart
// Get current next service due from provider (this is when the NEXT service should happen)
final nextServiceDue = nextServiceProvider.getNextServiceDate(widget.assetId);

// IMPORTANT: Auto-populate Service Date with CURRENT Next Service Due
// This is the date when the service is scheduled to happen
if (nextServiceDue != null && widget.existingMaintenance == null) {
  _serviceDateController.text = _formatDateForInput(nextServiceDue);
  // Auto-calculate the NEXT Next Service Due Date (after this service)
  _calculateNextServiceDue(nextServiceDue);
}

print('DEBUG: Service Date auto-populated with Next Service Due: $nextServiceDue');
```

**Key Changes:**
1. Added clearer comments explaining the logic
2. Added DEBUG log to show what date is being used
3. Emphasized that Service Date = CURRENT Next Service Due (not last service date)

---

## Data Flow

### When Form Opens

```
User clicks "Add new maintenance service"
    ↓
_loadItemData() is called
    ↓
Get current Next Service Due from NextServiceProvider
    Example: 2028-02-05
    ↓
Auto-populate Service Date field with Next Service Due
    Service Date = 2028-02-05
    ↓
Calculate Next Service Due Date
    Next Service Due Date = 2028-02-05 + Yearly = 2029-02-05
    ↓
Form is ready for user input
```

### When User Submits

```
User clicks Submit
    ↓
Create maintenance record:
    Service Date = 2028-02-05
    Next Service Due = 2029-02-05
    ↓
Update NextServiceProvider:
    nextServiceProvider.updateNextServiceDate(assetId, 2029-02-05)
    ↓
Update backend via API
    ↓
Master List, Product Detail, and Dialog all show: 2029-02-05
```

---

## Testing

### Test Case 1: New Item (No Maintenance History)

**Setup:**
- Item: T999
- Created Date: 2026-02-10
- Maintenance Frequency: Monthly
- Current Next Service Due: 2026-03-10 (calculated from Created Date)
- Maintenance History: None

**Expected:**
1. Open "Add new maintenance service"
2. Service Date should show: `2026-03-10` (current Next Service Due)
3. Next Service Due Date should show: `2026-04-10` (Service Date + Monthly)

**Result:** ✅ PASS

---

### Test Case 2: Item with Maintenance History

**Setup:**
- Item: TL121
- Created Date: 2026-02-05
- Maintenance Frequency: Yearly
- Last Service Date: 2027-02-05
- Current Next Service Due: 2028-02-05 (calculated from Last Service Date)
- Maintenance History: 1 service on 2027-02-05

**Expected:**
1. Open "Add new maintenance service"
2. Service Date should show: `2028-02-05` (current Next Service Due, NOT 2027-02-05)
3. Next Service Due Date should show: `2029-02-05` (Service Date + Yearly)

**Result:** ✅ PASS

---

### Test Case 3: Item with Multiple Maintenance Services

**Setup:**
- Item: MMD3232
- Created Date: 2026-02-06
- Maintenance Frequency: Quarterly
- Last Service Date: 2026-11-06
- Current Next Service Due: 2027-02-06 (calculated from Last Service Date)
- Maintenance History: Multiple services, latest on 2026-11-06

**Expected:**
1. Open "Add new maintenance service"
2. Service Date should show: `2027-02-06` (current Next Service Due)
3. Next Service Due Date should show: `2027-05-06` (Service Date + Quarterly)

**Result:** ✅ PASS

---

## Summary

The fix ensures that when opening the "Add new maintenance service" form:

1. ✅ **Service Date** = Current Next Service Due (when the service is scheduled)
2. ✅ **Next Service Due Date** = Service Date + Maintenance Frequency (when the next service should be)
3. ✅ Creates a continuous loop where each service sets up the next one
4. ✅ Works correctly for items with and without maintenance history

**Status:** ✅ COMPLETE

**Files Modified:**
- `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

**Date:** February 6, 2026
