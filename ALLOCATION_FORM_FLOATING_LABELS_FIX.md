# Allocation Form - Floating Labels Style Update

## Changes Made

Updated the Add Allocation form to match the Maintenance form style with floating labels that appear on the border line when focused or filled.

## File Modified

### `Frontend/inventory/lib/screens/add_forms/add_allocation.dart`

## What Changed

### Before:
- Labels were static text above each field
- Separate `Column` widgets wrapping each field with its label
- Labels used `Padding` widget above `TextFormField`

### After:
- Labels now float on the border line (like maintenance form)
- Uses `label:` property in `InputDecoration`
- Cleaner, more modern UI with less code
- Consistent with maintenance form styling

## Implementation Details

### Added `_inputDecoration` Method
```dart
InputDecoration _inputDecoration({
  required Widget label,
  required String hint,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    label: label,  // This creates the floating label effect
    hintText: hint,
    // ... styling properties
  );
}
```

### Updated All Fields
1. **Issue Date** - Floating label with calendar icon
2. **Employee Name** - Floating label
3. **Team Name** - Floating label
4. **Purpose** - Floating label
5. **Expected Return Date** - Floating label with calendar icon
6. **Actual Return Date** - Floating label with calendar icon (optional field)
7. **Status** - Floating label with dropdown

### Field Structure Change

**Before:**
```dart
Column(
  children: [
    Padding(child: _requiredLabel("Field name")),
    TextFormField(
      decoration: InputDecoration(hintText: "..."),
    ),
  ],
)
```

**After:**
```dart
TextFormField(
  decoration: _inputDecoration(
    label: _requiredLabel("Field name"),
    hint: "...",
  ),
)
```

## Visual Behavior

- **Empty field**: Label appears as placeholder text
- **Focused field**: Label floats up to the border line with blue color
- **Filled field**: Label stays on the border line
- **Required fields**: Show red asterisk (*) in the floating label

## Benefits

1. **Consistency**: Matches maintenance form exactly
2. **Modern UI**: Floating labels are a Material Design pattern
3. **Less Code**: Removed unnecessary Column and Padding widgets
4. **Better UX**: Clear visual feedback when field is focused/filled
5. **Space Efficient**: Labels don't take up extra vertical space

## Testing

1. Open any product detail page
2. Go to "Usage & allocation management" tab
3. Click "Add new allocation" button
4. Verify all fields have floating labels
5. Click on a field - label should float up to border
6. Fill a field - label should stay on border
7. Empty a field - label should return to placeholder position
8. Check that required fields show red asterisk (*)
