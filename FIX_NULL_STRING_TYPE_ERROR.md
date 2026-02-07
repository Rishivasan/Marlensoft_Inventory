# Fix: Type 'Null' is not a subtype of type 'String' Error

## Problem
When adding a control point to an untitled template, the app crashed with:
```
type 'Null' is not a subtype of type 'String'
```

## Root Cause
The control point data structure had a mismatch between:
- **API payload format**: Uses `'controlPointName'` as the key
- **Display format**: Expects `'name'` as the key

When we stored temporary control points, we used the API format, but when displaying them, we tried to access `point['name']`, which was null.

## Solution

### 1. Normalize Data Structure
When adding a temporary control point, we now normalize the data to match the display format:

```dart
final normalizedData = {
  'id': DateTime.now().millisecondsSinceEpoch, // Temporary ID
  'name': controlPointData['controlPointName'] ?? '', // Map to 'name'
  'order': tempControlPoints.length + 1,
  'typeId': controlPointData['controlPointTypeId'],
  'targetValue': controlPointData['targetValue'],
  'unit': controlPointData['unit'],
  'tolerance': controlPointData['tolerance'],
  '_originalData': controlPointData, // Keep original for API submission
};
```

### 2. Separate Storage
- **tempControlPoints**: Stores original API format (for submission)
- **controlPoints**: Stores normalized format (for display)

### 3. Updated Delete Logic
Now removes from both lists correctly:
```dart
// Remove from display list by temporary ID
controlPoints.removeWhere((cp) => cp['id'] == pointId);
// Remove from temp list by name
tempControlPoints.removeWhere((cp) => 
  cp['controlPointName'] == point['name']);
```

## Files Modified
- `Frontend/inventory/lib/screens/qc_template_screen.dart`
  - Updated `_showAddControlPointDialog()` method
  - Fixed delete functionality
  - Updated `_prepareNewTemplate()` method

## Testing
1. Click "Add new template"
2. Fill basic information
3. Click "Add control point"
4. Fill control point details
5. Click "Add control point" button
6. ✅ Control point should appear in list without error
7. ✅ Green banner should show count
8. ✅ Delete should work correctly

## Why This Happened
The original implementation directly copied the API payload to the display list:
```dart
// OLD (BROKEN)
controlPoints = List.from(tempControlPoints);
```

This caused a type mismatch because:
- API uses: `controlPointName` (String)
- Display expects: `name` (String)
- When accessing `point['name']`, it returned `null`
- Flutter expected a String, got null → Type error

## Prevention
Always normalize data structures when converting between different formats (API ↔ UI).
