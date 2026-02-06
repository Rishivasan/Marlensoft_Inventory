# Templates Dynamic Loading and Auto-Naming Fix

## Problem
1. The QC Template screen was displaying hardcoded template names instead of loading actual templates from the database
2. Template names were not following the required naming convention

## Solution
Implemented dynamic template loading from the backend API and automatic template name generation based on form data.

## Template Naming Convention
Templates are now automatically named using this format:
```
{ValidationTypeCode} - {FinalProductName} - {MSICode} - {MaterialName}
```

### Validation Type Codes:
- **IG** = Incoming Goods Validation
- **IP** = In-progress Validation (or Inprocess Validation)
- **FI** = Final Inspection

### Example Template Names:
- `IG - Circuit Breaker - MSI-001 - Steel Sheet`
- `IP - Power Supply - MSI-010 - Sensor Chip`
- `FI - Voltage Regulator - MSI-020 - Circuit Board`

## Changes Made

### 1. Frontend Service (`quality_service.dart`)
Added new method to fetch templates from the backend:
```dart
static Future<List<dynamic>> getTemplates() async {
  final response = await http.get(
    Uri.parse('$baseUrl/Quality/templates'),
    headers: {'Content-Type': 'application/json'},
  );
  // Returns list of templates from database
}
```

### 2. QC Template Screen (`qc_template_screen.dart`)

#### Added Validation Type Code Mapping:
```dart
final Map<String, String> validationTypeCodes = {
  'Incoming Goods Validation': 'IG',
  'In-progress Validation': 'IP',
  'Inprocess Validation': 'IP',
  'Final Inspection': 'FI',
};
```

#### Updated Material Loading:
Materials now include MSICode field:
```dart
materialComponents = materialsData.map((item) => {
  'id': item['MaterialId'],
  'name': item['MaterialName'],
  'msiCode': item['MSICode'],  // Added MSI Code
}).toList();
```

#### Auto-Generate Template Name:
When creating a template, the name is automatically generated:
```dart
// Get validation type code (IG, IP, or FI)
final validationTypeCode = validationTypeCodes[validationTypeName] ?? 'XX';

// Get product name
final productName = finalProducts.firstWhere(...)['name'];

// Get material name and MSI code
final materialName = material['name'];
final msiCode = material['msiCode'];

// Generate template name
final templateName = '$validationTypeCode - $productName - $msiCode - $materialName';
```

#### Added Material Validation:
Template creation now requires all three fields:
- Validation Type (required)
- Final Product (required)
- Material/Component (required) ← **New validation**

### 3. Backend (Already Existed)
The backend already had the necessary structure:
- `MaterialDto` includes `MSICode` field
- `GET /api/quality/materials/{productId}` returns materials with MSI codes
- `GET /api/quality/templates` returns all templates

## Data Flow
1. User opens QC Template screen
2. Templates are loaded from database via API
3. User selects:
   - Validation Type (e.g., "Incoming Goods Validation")
   - Final Product (e.g., "Circuit Breaker")
   - Material/Component (e.g., "Steel Sheet" with MSI-001)
4. User clicks "Add new template"
5. System generates template name: `IG - Circuit Breaker - MSI-001 - Steel Sheet`
6. Template is created in database with generated name
7. Template list refreshes and shows the new template

## UI States
1. **Loading**: Shows circular progress indicator while fetching templates
2. **Empty**: Shows "No templates yet" message with icon when list is empty
3. **Loaded**: Displays list of templates with auto-generated names

## Validation
The system now validates that all required fields are selected before creating a template:
- ✅ Validation Type must be selected
- ✅ Final Product must be selected
- ✅ Material/Component must be selected (new requirement)

## Testing
Run the test script to verify the API endpoint:
```powershell
.\test_templates_api.ps1
```

## Benefits
- ✅ Templates now reflect actual database content
- ✅ No more hardcoded data
- ✅ Consistent naming convention across all templates
- ✅ Template names are descriptive and include all relevant information
- ✅ MSI codes are properly included in template names
- ✅ Validation type codes (IG/IP/FI) make templates easy to identify
- ✅ Real-time updates when templates are created
- ✅ Better user experience with loading and empty states
