# Template Naming Convention Flow

## Overview
This document explains how template names are automatically generated based on user selections in the QC Template screen.

## Template Name Format
```
{ValidationTypeCode} - {FinalProductName} - {MSICode} - {MaterialName}
```

## Validation Type Code Mapping

| Validation Type Name | Code |
|---------------------|------|
| Incoming Goods Validation | **IG** |
| In-progress Validation | **IP** |
| Inprocess Validation | **IP** |
| Final Inspection | **FI** |

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    User Fills Form                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Step 1: Select Validation Type                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Dropdown: "Incoming Goods Validation"                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Result: validationTypeCode = "IG"                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Step 2: Select Final Product                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Dropdown: "Circuit Breaker"                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Result: productName = "Circuit Breaker"                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Step 3: Select Material/Component                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Dropdown: "Steel Sheet"                                   │  │
│  │ (Loads materials for selected product)                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  API Call: GET /api/quality/materials/{productId}              │
│  Response includes:                                             │
│    - MaterialId: 1                                              │
│    - MaterialName: "Steel Sheet"                                │
│    - MSICode: "MSI-001"                                         │
│                                                                  │
│  Result: materialName = "Steel Sheet"                           │
│          msiCode = "MSI-001"                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Step 4: Generate Template Name                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Code:                                                      │  │
│  │ templateName = `${validationTypeCode} - ${productName}    │  │
│  │                 - ${msiCode} - ${materialName}`           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Result: "IG - Circuit Breaker - MSI-001 - Steel Sheet"        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Step 5: Create Template in Database                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ POST /api/quality/template                                │  │
│  │ {                                                          │  │
│  │   "templateName": "IG - Circuit Breaker - MSI-001 -       │  │
│  │                    Steel Sheet",                           │  │
│  │   "validationTypeId": 1,                                   │  │
│  │   "finalProductId": 1,                                     │  │
│  │   "productName": "Circuit Breaker"                         │  │
│  │ }                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Step 6: Display in Template List                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ ✓ IG - Circuit Breaker - MSI-001 - Steel Sheet           │  │
│  │   IP - Power Supply - MSI-010 - Sensor Chip              │  │
│  │   FI - Voltage Regulator - MSI-020 - Circuit Board       │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Example Template Names

### Example 1: Incoming Goods Validation
- **Validation Type**: Incoming Goods Validation → **IG**
- **Final Product**: Circuit Breaker
- **Material**: Steel Sheet (MSI-001)
- **Generated Name**: `IG - Circuit Breaker - MSI-001 - Steel Sheet`

### Example 2: In-progress Validation
- **Validation Type**: In-progress Validation → **IP**
- **Final Product**: Power Supply
- **Material**: Sensor Chip (MSI-010)
- **Generated Name**: `IP - Power Supply - MSI-010 - Sensor Chip`

### Example 3: Final Inspection
- **Validation Type**: Final Inspection → **FI**
- **Final Product**: Voltage Regulator
- **Material**: Circuit Board (MSI-020)
- **Generated Name**: `FI - Voltage Regulator - MSI-020 - Circuit Board`

## Code Implementation

### Frontend (qc_template_screen.dart)

```dart
// Validation type code mapping
final Map<String, String> validationTypeCodes = {
  'Incoming Goods Validation': 'IG',
  'In-progress Validation': 'IP',
  'Inprocess Validation': 'IP',
  'Final Inspection': 'FI',
};

// Generate template name
Future<void> _createNewTemplate() async {
  // Get validation type code
  final validationType = validationTypes.firstWhere(
    (v) => v['id'].toString() == selectedValidationType,
  );
  final validationTypeName = validationType['name'] as String;
  final validationTypeCode = validationTypeCodes[validationTypeName] ?? 'XX';

  // Get product name
  final productName = finalProducts.firstWhere(
    (p) => p['id'].toString() == selectedFinalProduct,
  )['name'];

  // Get material name and MSI code
  final material = materialComponents.firstWhere(
    (m) => m['id'].toString() == selectedMaterialComponent,
  );
  final materialName = material['name'] as String;
  final msiCode = material['msiCode'] as String;

  // Generate template name
  final templateName = '$validationTypeCode - $productName - $msiCode - $materialName';
  
  // Create template with generated name
  final templateData = {
    'templateName': templateName,
    'validationTypeId': int.parse(selectedValidationType!),
    'finalProductId': int.parse(selectedFinalProduct!),
    'productName': productName,
  };
  
  await QualityService.createTemplate(templateData);
}
```

## Database Structure

### MaterialComponent Table
```sql
MaterialId    FinalProductId    MSICode      MaterialName
----------    --------------    --------     ----------------
1             1                 MSI-001      Steel Sheet
2             1                 MSI-002      Aluminium Frame
3             2                 MSI-010      Sensor Chip
4             3                 MSI-020      Circuit Board
```

### QCTemplate Table (After Creation)
```sql
QCTemplateId    TemplateName                                      ValidationTypeId    FinalProductId
------------    ---------------------------------------------     ----------------    --------------
1               IG - Circuit Breaker - MSI-001 - Steel Sheet     1                   1
2               IP - Power Supply - MSI-010 - Sensor Chip        2                   2
3               FI - Voltage Regulator - MSI-020 - Circuit Board 3                   3
```

## Validation Rules

Before creating a template, the system validates:

1. ✅ **Validation Type** must be selected
2. ✅ **Final Product** must be selected
3. ✅ **Material/Component** must be selected

If any field is missing, an error message is shown and template creation is blocked.

## Benefits

1. **Consistency**: All templates follow the same naming convention
2. **Clarity**: Template names clearly indicate what they're for
3. **Traceability**: MSI codes provide material traceability
4. **Organization**: Easy to find and identify templates
5. **Automation**: No manual naming required - reduces errors
