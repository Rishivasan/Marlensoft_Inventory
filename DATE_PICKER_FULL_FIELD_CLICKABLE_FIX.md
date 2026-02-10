# Date Picker - Full Field Clickable Fix

## Problem
Date fields only opened the date picker when clicking the calendar icon, making it difficult for users to interact with date fields.

## Solution
Made the entire date field clickable by:
1. Adding `onTap` to the `TextFormField` itself
2. Changing `IconButton` to regular `Icon` in the `suffixIcon`
3. Moving the date picker logic from icon's `onPressed` to field's `onTap`

## Files Modified

### ✅ Completed
1. **Frontend/inventory/lib/screens/add_forms/add_tool.dart**
   - PO date field
   - Invoice date field
   - Last audit date field

2. **Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart**
   - Already using `onTap` - no changes needed
   - Service date field
   - Next service due date field

3. **Frontend/inventory/lib/screens/add_forms/add_allocation.dart**
   - Already using `onTap` - no changes needed
   - Issue date field
   - Expected return date field
   - Actual return date field

4. **Frontend/inventory/lib/screens/add_forms/add_mmd.dart**
   - PO date field
   - Invoice date field
   - Last calibration date field
   - Next calibration date field

5. **Frontend/inventory/lib/screens/add_forms/add_asset.dart**
   - PO date field
   - Invoice date field

6. **Frontend/inventory/lib/screens/add_forms/add_consumable.dart**
   - PO date field
   - Invoice date field

## Code Pattern

### Before (Icon Button - Only icon clickable):
```dart
TextFormField(
  readOnly: true,
  decoration: InputDecoration(
    suffixIcon: IconButton(
      icon: const Icon(Icons.calendar_today_outlined),
      onPressed: () {
        _pickDate(
          context: context,
          current: selectedDate,
          onPicked: (d) {
            setState(() => selectedDate = d);
          },
        );
      },
    ),
  ),
)
```

### After (Full field clickable):
```dart
TextFormField(
  readOnly: true,
  onTap: () {
    _pickDate(
      context: context,
      current: selectedDate,
      onPicked: (d) {
        setState(() => selectedDate = d);
      },
    );
  },
  decoration: InputDecoration(
    suffixIcon: const Icon(Icons.calendar_today_outlined),
  ),
)
```

## Benefits

1. **Better UX**: Users can click anywhere on the field to open date picker
2. **Easier to use**: Larger clickable area
3. **Consistent**: All date fields behave the same way
4. **Mobile-friendly**: Easier to tap on mobile devices
5. **Accessibility**: Better for users with motor difficulties

## Testing

For each form with date fields:
1. Open the form (Add Tool, Add MMD, Add Asset, Add Consumable, Add Maintenance, Add Allocation)
2. Click anywhere on a date field (not just the icon)
3. Verify date picker opens
4. Select a date
5. Verify date is populated in the field
6. Repeat for all date fields in the form
