# Date Picker Calendar Sync Fix

## Issue
When date fields are pre-filled with data, the calendar picker doesn't reflect the current field value. Instead, it always opens to the current date (DateTime.now()), causing confusion for users.

**Example:**
- Field shows: "2029-02-10"
- Calendar opens to: February 2026 (current date)
- Expected: Calendar should open to February 2029, day 10

## Root Cause
The `showDatePicker` widget was using `DateTime.now()` as the `initialDate` instead of parsing the current value from the text field controller.

## Solution
Updated the date picker methods to parse the current field value and use it as the initial date:

### Fixed Files:

#### 1. Maintenance Service Form
**File:** `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

**Before:**
```dart
Future<void> _selectDate(TextEditingController controller, {bool isServiceDate = false}) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(), // ❌ Always current date
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
```

**After:**
```dart
Future<void> _selectDate(TextEditingController controller, {bool isServiceDate = false}) async {
  // Parse the current date from the controller, fallback to DateTime.now()
  DateTime initialDate = DateTime.now();
  if (controller.text.isNotEmpty) {
    try {
      initialDate = DateTime.parse(controller.text);
    } catch (e) {
      // If parsing fails, use current date
      initialDate = DateTime.now();
    }
  }
  
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate, // ✅ Uses field value or current date
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
```

#### 2. Allocation Form
**File:** `Frontend/inventory/lib/screens/add_forms/add_allocation.dart`

Applied the same fix to the allocation form's `_selectDate` method.

### Already Correct Forms:
The following forms already had the correct implementation:
- ✅ MMD Form (`add_mmd.dart`) - Uses `current ?? now`
- ✅ Tool Form (`add_tool.dart`) - Uses `current ?? now`
- ✅ Consumable Form (`add_consumable.dart`) - Uses `current ?? now`
- ✅ Asset Form (`add_asset.dart`) - Uses `current ?? now`

## Testing
1. Open any form with date fields
2. Pre-fill a date field (e.g., "2029-02-10")
3. Click the calendar icon
4. ✅ Calendar should open to the correct year/month/day
5. ✅ The date from the field should be highlighted

## Benefits
- ✅ Calendar now reflects the current field value
- ✅ Better user experience when editing existing records
- ✅ Consistent behavior across all date pickers
- ✅ Graceful fallback to current date if parsing fails
- ✅ No breaking changes to existing functionality

## Impact
This fix affects all date picker interactions in:
- Maintenance Service forms (Service Date, Next Service Due)
- Allocation forms (Issue Date, Expected Return, Actual Return)
- All other forms already had correct implementation