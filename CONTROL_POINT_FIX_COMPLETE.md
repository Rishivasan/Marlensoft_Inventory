# Control Point Save to Database - Fix Complete

## Problem
When adding a control point through the frontend UI, it was NOT being saved to the `QCControlPoint` database table.

## Root Cause
The frontend code had a TODO comment instead of actually calling the backend API:
```dart
// TODO: Replace with actual API call when backend is ready
await Future.delayed(const Duration(seconds: 1));
bool success = true;
```

## Changes Made

### 1. Updated AddControlPoint Widget
**File:** `Frontend/inventory/lib/screens/add_forms/add_control_point.dart`

- Added `templateId` parameter to the widget constructor
- Replaced the TODO/mock code with actual API call
- Built proper request payload matching backend DTO structure

**Before:**
```dart
class AddControlPoint extends StatefulWidget {
  const AddControlPoint({
    super.key, 
    required this.submit,
    this.existingData,
  });
```

**After:**
```dart
class AddControlPoint extends StatefulWidget {
  const AddControlPoint({
    super.key, 
    required this.submit,
    required this.templateId,  // NEW
    this.existingData,
  });

  final int templateId;  // NEW
```

**Submit Function - Before:**
```dart
// TODO: Replace with actual API call when backend is ready
await Future.delayed(const Duration(seconds: 1));
bool success = true;
```

**Submit Function - After:**
```dart
Map<String, dynamic> requestPayload = {
  "qcTemplateId": widget.templateId,
  "controlPointTypeId": int.tryParse(selectedType ?? '1') ?? 1,
  "controlPointName": _controlPointNameCtrl.text.trim(),
  "targetValue": _targetValueCtrl.text.isNotEmpty ? _targetValueCtrl.text.trim() : null,
  "unit": selectedUnit ?? "",
  "tolerance": _toleranceValueCtrl.text.isNotEmpty ? _toleranceValueCtrl.text.trim() : null,
  "instructions": _instructionsCtrl.text.trim(),
  "imagePath": selectedFile?.path ?? "",
  "sequenceOrder": 1,
};

bool success = await QualityService.addControlPoint(requestPayload);
```

### 2. Updated QC Template Screen
**File:** `Frontend/inventory/lib/screens/qc_template_screen.dart`

- Added `selectedTemplateId` state variable to track which template is selected
- Added IDs to the templates list
- Updated template selection to track the selected ID
- Updated `_showAddControlPointDialog()` to pass the template ID

**Changes:**
```dart
// Added state variable
int? selectedTemplateId;

// Added IDs to templates
final List<Map<String, dynamic>> templates = [
  {'id': 3, 'name': 'Untitled template', 'isActive': true},
  {'id': 1, 'name': 'ABI 220 - Metal plate', 'isActive': false},
  // ... etc
];

// Updated template selection
onTap: () {
  setState(() {
    for (var t in templates) {
      t['isActive'] = false;
    }
    template['isActive'] = true;
    selectedTemplateId = template['id']; // NEW
  });
}

// Updated dialog to pass template ID
void _showAddControlPointDialog() {
  if (selectedTemplateId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a template first'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  DialogPannelHelper().showAddPannel(
    context: context,
    addingItem: AddControlPoint(
      templateId: selectedTemplateId!,  // NEW
      submit: () { /* ... */ },
    ),
  );
}
```

### 3. Fixed API Endpoint
**File:** `Frontend/inventory/lib/services/quality_service.dart`

Fixed the endpoint URL to match the backend controller route.

**Before:**
```dart
Uri.parse('$baseUrl/Quality/control-points')
```

**After:**
```dart
Uri.parse('$baseUrl/quality/control-point')
```

## How to Test

### Option 1: Using the UI
1. Run the frontend application
2. Navigate to Quality Check Customization screen
3. Select a template (e.g., "Untitled template")
4. Click "New Control Point" button
5. Fill in the form:
   - Control point name: "Test Point"
   - Type: "Measure"
   - Target value: "100"
   - Unit: "mm"
   - Tolerance: "2"
6. Click "Add control point"
7. Check database: `SELECT * FROM QCControlPoint`
8. You should see the new record

### Option 2: Using the Test Script
Run the PowerShell test script:
```powershell
.\test_control_point_fix.ps1
```

This script will:
- Check current control points in database
- Prompt you to add one through the UI
- Verify it was saved to the database

## Database Table
**Table Name:** `QCControlPoint`

**Columns:**
- QCControlPointId (PK)
- QCTemplateId (FK)
- ControlPointTypeId
- ControlPointName
- TargetValue
- Unit
- Tolerance
- Instructions
- ImagePath
- SequenceOrder

## API Endpoint
**POST** `http://localhost:5069/api/quality/control-point`

**Request Body:**
```json
{
  "qcTemplateId": 3,
  "controlPointTypeId": 3,
  "controlPointName": "Width Measurement",
  "targetValue": "100",
  "unit": "mm",
  "tolerance": "2",
  "instructions": "Measure width at center",
  "imagePath": "",
  "sequenceOrder": 1
}
```

**Response:**
```
"Control point added"
```

## Status
✅ **FIXED** - Control points now save to database when added through the UI

## Files Modified
1. `Frontend/inventory/lib/screens/add_forms/add_control_point.dart`
2. `Frontend/inventory/lib/screens/qc_template_screen.dart`
3. `Frontend/inventory/lib/services/quality_service.dart`

## Next Steps
Consider implementing:
- Loading control points from API instead of hardcoded list
- Edit control point functionality
- Delete control point functionality
- Proper template management (create, edit, delete templates)
