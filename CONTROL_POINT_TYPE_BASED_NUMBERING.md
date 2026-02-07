# Control Point Type-Based Numbering

## Problem
Control points were showing sequential numbers (1, 1, 1 or 1, 2, 3) regardless of their type, which was confusing.

## Solution
Numbers now reflect the **control point type**:
- **Measure** → Shows **1**
- **Take a picture** → Shows **2**
- **Visual inspection** → Shows **3**

## Before (Wrong)
```
1  AS (Measure)
1  we (Take a picture)
1  AWER (Visual inspection)
```
All showing "1" - confusing!

## After (Correct)
```
1  AS (Measure)
2  we (Take a picture)
3  AWER (Visual inspection)
```
Numbers match the type - clear!

## Implementation

### Helper Function
```dart
String _getTypeBasedNumber(int? typeId) {
  // Map control point type ID to display number
  // 1 = Measure → Show 1
  // 2 = Take a picture → Show 2  
  // 3 = Visual inspection → Show 3
  if (typeId == null) return '1';
  return typeId.toString();
}
```

### Display Update
```dart
// OLD: Sequential order
Text('${point['order']}')

// NEW: Type-based number
Text(_getTypeBasedNumber(point['typeId']))
```

## Type ID Mapping

Based on the control point types in your system:

| Type ID | Type Name | Display Number |
|---------|-----------|----------------|
| 1 | Measure | 1 |
| 2 | Take a picture | 2 |
| 3 | Visual inspection | 3 |

## Example Scenarios

### Scenario 1: All Same Type
```
Template with 3 Measure control points:
1  Width Check (Measure)
1  Height Check (Measure)
1  Depth Check (Measure)
```
All show "1" because they're all Measure type.

### Scenario 2: Mixed Types
```
Template with different types:
1  Dimension Check (Measure)
2  Photo Documentation (Take a picture)
3  Surface Quality (Visual inspection)
1  Tolerance Check (Measure)
```
Numbers reflect the type, not the order.

### Scenario 3: Multiple of Each Type
```
Template with multiple of each:
1  Width (Measure)
1  Height (Measure)
2  Front Photo (Take a picture)
2  Back Photo (Take a picture)
3  Color Check (Visual inspection)
3  Defect Check (Visual inspection)
```

## Benefits

1. **Clear Type Identification**: Users immediately know the type by the number
2. **Consistent**: Same type always shows same number
3. **Visual Grouping**: Easy to see which control points are the same type
4. **No Confusion**: No more wondering why all show "1"

## Files Modified

1. **Frontend/inventory/lib/screens/qc_template_screen.dart**
   - Added `_getTypeBasedNumber()` helper function
   - Updated control point display to use type-based numbering

## Testing

### Test 1: Create Template with Mixed Types
1. Add a Measure control point → Should show **1**
2. Add a Take a picture control point → Should show **2**
3. Add a Visual inspection control point → Should show **3**

### Test 2: Multiple Same Type
1. Add 3 Measure control points → All should show **1**
2. Add 2 Take a picture control points → Both should show **2**

### Test 3: Existing Templates
1. Open existing template
2. Check control point numbers
3. Should show type-based numbers (1, 2, or 3)

## Hot Reload

After the code change:
```bash
# In Flutter terminal, press 'r' for hot reload
# Or restart the app
```

## Visual Result

The green circle with the number now shows:
- **1** for all Measure types
- **2** for all Take a picture types
- **3** for all Visual inspection types

This makes it immediately clear what type each control point is!
