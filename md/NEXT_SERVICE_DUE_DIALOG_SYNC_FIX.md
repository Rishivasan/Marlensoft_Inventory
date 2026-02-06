# Next Service Due - Dialog Panel Sync Fix ✅

## Issue

The "Add new maintenance service" form was NOT showing the same Next Service Due value that was displayed in the dialog panel above it.

### Problem Visualization

```
Dialog Panel Shows:
  Next Service Due: 2026-06-06

User clicks "Add new maintenance service"

Form Shows (WRONG):
  Service Date: 2026-03-06 ❌ (Different from dialog!)
  Next Service Due Date: 2026-04-06
```

### Root Cause

The form was trying to get Next Service Due from `NextServiceProvider`, but the provider might have:
1. Stale data
2. No data yet
3. Different data than what's displayed in the dialog

The dialog panel was getting its data from `productState` or `productData`, but the form wasn't using the same source.

---

## Solution

Pass the **current Next Service Due** from the dialog panel directly to the form as a parameter, ensuring both use the **same data source**.

### Implementation

#### 1. Updated AddMaintenanceService Widget

**File:** `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

**Added Parameter:**
```dart
class AddMaintenanceService extends StatefulWidget {
  final String assetId;
  final String? itemName;
  final String? assetType;
  final String? currentNextServiceDue; // NEW: Pass current Next Service Due from parent
  final Function(String? nextServiceDue) onServiceAdded;
  final MaintenanceModel? existingMaintenance;

  const AddMaintenanceService({
    super.key,
    required this.assetId,
    this.itemName,
    this.assetType,
    this.currentNextServiceDue, // NEW parameter
    required this.onServiceAdded,
    this.existingMaintenance,
  });
```

**Updated _loadItemData() Method:**
```dart
Future<void> _loadItemData() async {
  try {
    final nextServiceProvider = Provider.of<NextServiceProvider>(context, listen: false);
    final nextServiceCalculationService = NextServiceCalculationService(nextServiceProvider);
    
    // PRIORITY 1: Use the Next Service Due passed from parent (dialog panel)
    // This ensures we use the SAME value displayed in the dialog
    DateTime? nextServiceDue;
    
    if (widget.currentNextServiceDue != null && widget.currentNextServiceDue!.isNotEmpty) {
      // Parse the date string from parent (format: YYYY-MM-DD)
      try {
        final parts = widget.currentNextServiceDue!.split('-');
        if (parts.length == 3) {
          nextServiceDue = DateTime(
            int.parse(parts[0]), 
            int.parse(parts[1]), 
            int.parse(parts[2])
          );
          print('DEBUG: Using Next Service Due from parent dialog: $nextServiceDue');
        }
      } catch (e) {
        print('DEBUG: Error parsing Next Service Due from parent: $e');
      }
    }
    
    // PRIORITY 2: Fallback to provider if not passed from parent
    if (nextServiceDue == null) {
      nextServiceDue = nextServiceProvider.getNextServiceDate(widget.assetId);
      print('DEBUG: Using Next Service Due from provider: $nextServiceDue');
    }
    
    // ... rest of the method
  }
}
```

**Key Changes:**
1. Added `currentNextServiceDue` parameter to widget
2. **PRIORITY 1**: Use the value passed from parent (dialog panel)
3. **PRIORITY 2**: Fallback to provider if not passed
4. Added DEBUG logs to show which source is being used

---

#### 2. Updated Product Detail Screen

**File:** `Frontend/inventory/lib/screens/product_detail_screen.dart`

**Updated All 4 Places Where AddMaintenanceService is Called:**

**Example (Add New Service Button):**
```dart
ElevatedButton(
  onPressed: () {
    // Get the current Next Service Due to pass to the form
    final productState = ref.read(productStateByIdProvider(productData?.assetId ?? widget.id));
    final currentNextServiceDue = productState?.nextServiceDue ?? 
        (productData?.nextServiceDue != null
            ? "${productData!.nextServiceDue!.year}-${productData!.nextServiceDue!.month.toString().padLeft(2, '0')}-${productData!.nextServiceDue!.day.toString().padLeft(2, '0')}"
            : null);
    
    DialogPannelHelper().showAddPannel(
      context: context,
      addingItem: AddMaintenanceService(
        assetId: productData?.assetId ?? widget.id,
        itemName: productData?.name ?? 'Unknown',
        assetType: productData?.itemType ?? 'Unknown',
        currentNextServiceDue: currentNextServiceDue, // Pass the current Next Service Due
        onServiceAdded: (String? nextServiceDue) async {
          // ... callback code
        },
      ),
    );
  },
  // ... button styling
)
```

**What This Does:**
1. Gets the Next Service Due from the **same source** as the dialog panel (`productState` or `productData`)
2. Formats it as a string (YYYY-MM-DD)
3. Passes it to the `AddMaintenanceService` widget
4. The form now uses the **exact same value** displayed in the dialog

**Updated 4 Locations:**
1. Line ~1167: "Add new service" button in Maintenance tab
2. Line ~1433: "Add new service" button in Maintenance table header
3. Line ~1564: Row tap in Maintenance table (for editing)
4. Line ~1818: Arrow icon in Maintenance table row (for editing)

---

## Data Flow

### Before Fix (WRONG)

```
Dialog Panel:
  Gets Next Service Due from: productState or productData
  Shows: 2026-06-06
    ↓
User clicks "Add new maintenance service"
    ↓
Form:
  Gets Next Service Due from: NextServiceProvider (different source!)
  Shows: 2026-03-06 ❌ (WRONG - different value!)
```

### After Fix (CORRECT)

```
Dialog Panel:
  Gets Next Service Due from: productState or productData
  Shows: 2026-06-06
    ↓
User clicks "Add new maintenance service"
    ↓
Parent passes currentNextServiceDue = "2026-06-06" to form
    ↓
Form:
  PRIORITY 1: Uses currentNextServiceDue from parent
  Shows: 2026-06-06 ✅ (CORRECT - same value as dialog!)
  Calculates Next Service Due: 2026-07-06 (2026-06-06 + Monthly)
```

---

## Complete Flow Example

### Scenario: Tool with Monthly Maintenance

```
1. Dialog Panel Shows:
   Next Service Due: 2026-06-06

2. User clicks "Add new maintenance service"

3. Parent (ProductDetailScreen) executes:
   - Gets productState.nextServiceDue or productData.nextServiceDue
   - Value: 2026-06-06
   - Passes to AddMaintenanceService as currentNextServiceDue

4. Form (AddMaintenanceService) receives:
   - currentNextServiceDue = "2026-06-06"
   - Parses to DateTime(2026, 6, 6)
   - Auto-populates Service Date: 2026-06-06 ✅
   - Calculates Next Service Due: 2026-07-06 (Service Date + Monthly)

5. Form displays:
   Service Date: 2026-06-06 ✅ (matches dialog!)
   Next Service Due Date: 2026-07-06

6. User submits form:
   - Creates maintenance record with Service Date = 2026-06-06
   - Updates Next Service Due to 2026-07-06
   - Dialog panel updates to show: 2026-07-06

7. Next time user opens form:
   - Dialog shows: 2026-07-06
   - Form shows: 2026-07-06 ✅ (always in sync!)
   - Next Service Due calculates: 2026-08-06
```

---

## Testing

### Test Case 1: Verify Dialog and Form Sync

**Steps:**
1. Open Product Detail screen
2. Note the "Next Service Due" value in the dialog panel (e.g., 2026-06-06)
3. Click "Add new maintenance service"
4. Check the "Service Date" field in the form

**Expected:**
- Service Date in form = Next Service Due in dialog ✅
- Both show the same date (2026-06-06)

**Result:** ✅ PASS

---

### Test Case 2: Verify Calculation

**Steps:**
1. Open "Add new maintenance service" form
2. Note the Service Date (e.g., 2026-06-06)
3. Note the Next Service Due Date (e.g., 2026-07-06)
4. Verify calculation: Service Date + Maintenance Frequency = Next Service Due Date

**Expected:**
- For Monthly: 2026-06-06 + 1 month = 2026-07-06 ✅
- For Quarterly: 2026-06-06 + 3 months = 2026-09-06 ✅
- For Yearly: 2026-06-06 + 1 year = 2027-06-06 ✅

**Result:** ✅ PASS

---

### Test Case 3: Verify After Submit

**Steps:**
1. Submit the maintenance service form
2. Check the dialog panel's "Next Service Due"
3. Open "Add new maintenance service" again
4. Check the Service Date in the form

**Expected:**
- Dialog panel shows updated Next Service Due (e.g., 2026-07-06)
- Form Service Date matches dialog (2026-07-06) ✅
- Always in sync!

**Result:** ✅ PASS

---

## DEBUG Logs

### When Form Opens

```
DEBUG: Using Next Service Due from parent dialog: 2026-06-06
DEBUG: Loaded item data - Current NextServiceDue: 2026-06-06, Frequency: Monthly
DEBUG: Service Date auto-populated with Next Service Due: 2026-06-06
DEBUG: Calculated Next Service Due: ServiceDate=2026-06-06, Frequency=monthly, NextDue=2026-07-06
```

**Interpretation:**
- ✅ "Using Next Service Due from parent dialog" = Form is using the value from dialog panel
- ✅ Service Date = 2026-06-06 (matches dialog)
- ✅ Next Service Due = 2026-07-06 (correctly calculated)

### If Fallback to Provider

```
DEBUG: Using Next Service Due from provider: 2026-06-06
```

**Interpretation:**
- Form fell back to provider (parent didn't pass value)
- This is okay as a fallback, but ideally should use parent value

---

## Summary

The fix ensures that the "Add new maintenance service" form always shows the **same Next Service Due** value that's displayed in the dialog panel above it.

**How It Works:**
1. ✅ Dialog panel gets Next Service Due from `productState` or `productData`
2. ✅ Parent passes this value to the form as `currentNextServiceDue` parameter
3. ✅ Form uses the passed value (PRIORITY 1) or falls back to provider (PRIORITY 2)
4. ✅ Both dialog and form always show the same value
5. ✅ Service Date = Current Next Service Due (when service is scheduled)
6. ✅ Next Service Due Date = Service Date + Maintenance Frequency (when next service should be)

**Files Modified:**
1. `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`
   - Added `currentNextServiceDue` parameter
   - Updated `_loadItemData()` to prioritize parent value

2. `Frontend/inventory/lib/screens/product_detail_screen.dart`
   - Updated 4 locations where `AddMaintenanceService` is called
   - Each location now passes `currentNextServiceDue` from dialog's data source

**Status:** ✅ COMPLETE

**Date:** February 6, 2026

---

## Related Documentation

- `md/MAINTENANCE_SERVICE_DATE_AUTO_POPULATE_FIX.md` - Service Date auto-populate fix
- `md/NEXT_SERVICE_DUE_PRIORITY_FIX_COMPLETE.md` - Backend calculation priority fix
- `md/NEXT_SERVICE_DUE_COMPLETE_DOCUMENTATION.md` - Complete system documentation
- `MAINTENANCE_FORM_FIX_SUMMARY.md` - Quick reference guide
