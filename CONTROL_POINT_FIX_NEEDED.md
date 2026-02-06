# Control Point Not Saving to Database - Issue Analysis

## Problem
When adding a control point through the frontend UI, it does NOT save to the database table `QCControlPoint`.

## Root Cause
The frontend code in `Frontend/inventory/lib/screens/add_forms/add_control_point.dart` has a **TODO comment** instead of actual API call:

```dart
// Line 267-270
// TODO: Replace with actual API call when backend is ready
// For now, simulate API call
await Future.delayed(const Duration(seconds: 1));
bool success = true;
```

## What's Working
✅ Backend API endpoint exists: `POST /api/quality/control-point`  
✅ Backend controller, service, and repository are implemented  
✅ Frontend service method `QualityService.addControlPoint()` exists  
✅ Database table `QCControlPoint` exists  
✅ API works when tested directly (we verified this with PowerShell)

## What's NOT Working
❌ Frontend form doesn't call the API  
❌ Frontend doesn't pass the `QCTemplateId` to the AddControlPoint widget  
❌ The submit function just simulates success without saving

## Required Fixes

### Fix 1: Pass Template ID to AddControlPoint Widget

**File:** `Frontend/inventory/lib/screens/add_forms/add_control_point.dart`

Add `templateId` parameter to the widget:

```dart
class AddControlPoint extends StatefulWidget {
  const AddControlPoint({
    super.key, 
    required this.submit,
    required this.templateId,  // ADD THIS
    this.existingData,
  });

  final VoidCallback submit;
  final int templateId;  // ADD THIS
  final Map<String, dynamic>? existingData;
```

### Fix 2: Update the Submit Function

**File:** `Frontend/inventory/lib/screens/add_forms/add_control_point.dart`  
**Function:** `_submitControlPoint()` (around line 267)

Replace the TODO section with actual API call:

```dart
// Build the request payload matching backend DTO
Map<String, dynamic> requestPayload = {
  "qcTemplateId": widget.templateId,  // Use the passed template ID
  "controlPointTypeId": int.tryParse(selectedType ?? '1') ?? 1,
  "controlPointName": _controlPointNameCtrl.text.trim(),
  "targetValue": _targetValueCtrl.text.isNotEmpty ? _targetValueCtrl.text.trim() : null,
  "unit": selectedUnit ?? "",
  "tolerance": _toleranceValueCtrl.text.isNotEmpty ? _toleranceValueCtrl.text.trim() : null,
  "instructions": _instructionsCtrl.text.trim(),
  "imagePath": selectedFile?.path ?? "",
  "sequenceOrder": 1,
};

// Call the actual API
bool success = await QualityService.addControlPoint(requestPayload);
```

### Fix 3: Pass Template ID When Opening Dialog

**File:** `Frontend/inventory/lib/screens/qc_template_screen.dart`  
**Function:** `_showAddControlPointDialog()`

Update to pass the current template ID:

```dart
void _showAddControlPointDialog() {
  DialogPannelHelper().showAddPannel(
    context: context,
    addingItem: AddControlPoint(
      templateId: currentTemplateId,  // ADD THIS - use the actual template ID
      submit: () {
        // Refresh the control points list from API
        _loadControlPoints();  // Fetch fresh data from backend
      },
    ),
  );
}
```

## Testing After Fix

1. Open the QC Template screen
2. Click "Add new template" or select an existing template
3. Click "New Control Point" button
4. Fill in the form:
   - Control point name: "Test Point"
   - Type: "Measure"
   - Target value: "100"
   - Unit: "mm"
   - Tolerance: "2"
5. Click "Add control point"
6. Check SQL Server: `SELECT * FROM QCControlPoint`
7. You should see the new record

## Current Workaround

The API works fine when called directly (we tested with PowerShell). The issue is purely in the frontend not calling it.

## Priority

**HIGH** - This is a critical feature that appears to work but silently fails to save data.
