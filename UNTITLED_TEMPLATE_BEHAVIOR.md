# Untitled Template Behavior

## Overview
The "Untitled template" is a temporary placeholder that appears only when creating a new template. It provides a clear visual indication that the user is in "new template creation mode."

## Behavior Flow

### 1. Initial State (No Untitled Template)
When the screen loads, only real templates from the database are shown:
```
Sidebar:
  IG - Circuit Breaker - MSI-001 - Steel Sheet
  IP - Power Supply - MSI-010 - Sensor Chip
  FI - Voltage Regulator - MSI-020 - Circuit Board
```

### 2. Click "Add new template" (Blue Button in Sidebar)
**Action**: User clicks the blue "Add new template" button

**Result**:
- ✅ "Untitled template" appears at the top of the sidebar
- ✅ "Untitled template" is highlighted (active)
- ✅ Form is cleared and ready for input
- ✅ All other templates are deactivated

```
Sidebar:
  ✓ Untitled template                              ← NEW, highlighted
    IG - Circuit Breaker - MSI-001 - Steel Sheet
    IP - Power Supply - MSI-010 - Sensor Chip
    FI - Voltage Regulator - MSI-020 - Circuit Board
```

### 3. Fill the Form
User fills in:
- Validation Type: Incoming Goods Validation
- Final Product: Circuit Breaker
- Material/Component: Steel Sheet (MSI-001)

```
Sidebar:
  ✓ Untitled template                              ← Still showing
    IG - Circuit Breaker - MSI-001 - Steel Sheet
    IP - Power Supply - MSI-010 - Sensor Chip
    FI - Voltage Regulator - MSI-020 - Circuit Board

Form:
  Validation type: Incoming Goods Validation
  Final product: Circuit Breaker
  Material/Component: Steel Sheet (MSI-001)
```

### 4. Click "Add new template" (Bottom Button)
**Action**: User clicks the bottom "Add new template" button

**Result**:
- ✅ Template is created in database with name: `IG - Circuit Breaker - MSI-001 - Steel Sheet`
- ✅ "Untitled template" is REMOVED from sidebar
- ✅ New template appears in sidebar with proper name
- ✅ New template is automatically selected (highlighted)
- ✅ Form is cleared

```
Sidebar:
  ✓ IG - Circuit Breaker - MSI-001 - Steel Sheet   ← NEW, highlighted
    IP - Power Supply - MSI-010 - Sensor Chip
    FI - Voltage Regulator - MSI-020 - Circuit Board

"Untitled template" is GONE!
```

### 5. Click on Existing Template
**Action**: User clicks on any existing template in the sidebar

**Result**:
- ✅ "Untitled template" is removed (if it was showing)
- ✅ Clicked template is highlighted
- ✅ Form loads with that template's data
- ✅ Control points for that template are loaded

```
Sidebar:
    IG - Circuit Breaker - MSI-001 - Steel Sheet
  ✓ IP - Power Supply - MSI-010 - Sensor Chip      ← Selected
    FI - Voltage Regulator - MSI-020 - Circuit Board

"Untitled template" is GONE!
```

### 6. Click "Add new template" Again
**Action**: User clicks the blue "Add new template" button again

**Result**:
- ✅ "Untitled template" appears again at the top
- ✅ Form is cleared
- ✅ Ready for new template creation

```
Sidebar:
  ✓ Untitled template                              ← Back again!
    IG - Circuit Breaker - MSI-001 - Steel Sheet
    IP - Power Supply - MSI-010 - Sensor Chip
    FI - Voltage Regulator - MSI-020 - Circuit Board
```

## Key Rules

### When "Untitled template" Appears:
✅ When user clicks "Add new template" button (blue button in sidebar)

### When "Untitled template" Disappears:
✅ After successfully creating a template (bottom button)
✅ When clicking on any existing template in the sidebar

### Special Behaviors:
- ✅ "Untitled template" has ID = -1 (special identifier)
- ✅ Cannot add control points to "Untitled template"
- ✅ Clicking on "Untitled template" itself does nothing (it's already active)
- ✅ Only ONE "Untitled template" can exist at a time

## Visual Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  Initial State: No Untitled Template                        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Sidebar:                                              │  │
│  │   IG - Circuit Breaker - MSI-001 - Steel Sheet       │  │
│  │   IP - Power Supply - MSI-010 - Sensor Chip          │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼ Click "Add new template" (blue)
┌─────────────────────────────────────────────────────────────┐
│  "Untitled template" Appears                                │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Sidebar:                                              │  │
│  │   ✓ Untitled template                                 │  │ ← NEW
│  │     IG - Circuit Breaker - MSI-001 - Steel Sheet     │  │
│  │     IP - Power Supply - MSI-010 - Sensor Chip        │  │
│  └───────────────────────────────────────────────────────┘  │
│  Form: Empty, ready for input                               │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼ Fill form and click "Add new template" (bottom)
┌─────────────────────────────────────────────────────────────┐
│  "Untitled template" Disappears, New Template Appears      │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Sidebar:                                              │  │
│  │   ✓ IG - Circuit Breaker - MSI-001 - Steel Sheet     │  │ ← NEW
│  │     IP - Power Supply - MSI-010 - Sensor Chip        │  │
│  │     FI - Voltage Regulator - MSI-020 - Circuit Board │  │
│  └───────────────────────────────────────────────────────┘  │
│  "Untitled template" is GONE!                              │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼ Click existing template
┌─────────────────────────────────────────────────────────────┐
│  Existing Template Selected                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Sidebar:                                              │  │
│  │     IG - Circuit Breaker - MSI-001 - Steel Sheet     │  │
│  │   ✓ IP - Power Supply - MSI-010 - Sensor Chip        │  │ ← Selected
│  │     FI - Voltage Regulator - MSI-020 - Circuit Board │  │
│  └───────────────────────────────────────────────────────┘  │
│  Form: Shows template data                                  │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼ Click "Add new template" (blue) again
┌─────────────────────────────────────────────────────────────┐
│  "Untitled template" Appears Again                          │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Sidebar:                                              │  │
│  │   ✓ Untitled template                                 │  │ ← Back!
│  │     IG - Circuit Breaker - MSI-001 - Steel Sheet     │  │
│  │     IP - Power Supply - MSI-010 - Sensor Chip        │  │
│  │     FI - Voltage Regulator - MSI-020 - Circuit Board │  │
│  └───────────────────────────────────────────────────────┘  │
│  Form: Empty, ready for new input                           │
└─────────────────────────────────────────────────────────────┘
```

## Code Implementation

### Adding "Untitled template"
```dart
void _prepareNewTemplate() {
  setState(() {
    // Add "Untitled template" at the top
    templates.insert(0, {
      'id': -1,  // Special ID
      'name': 'Untitled template',
      'isActive': true,
    });
    
    // Clear form fields
    selectedValidationType = null;
    selectedFinalProduct = null;
    selectedMaterialComponent = null;
    // ...
  });
}
```

### Removing "Untitled template"
```dart
// After creating template
templates.removeWhere((t) => t['id'] == -1);

// When clicking existing template
templates.removeWhere((t) => t['id'] == -1);
```

### Preventing Control Points on Untitled Template
```dart
void _showAddControlPointDialog() {
  if (selectedTemplateId == null || selectedTemplateId == -1) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please create the template first before adding control points'),
      ),
    );
    return;
  }
  // ... show dialog
}
```

## User Experience Benefits

✅ **Clear Visual Feedback**: User knows they're creating a new template
✅ **No Confusion**: "Untitled template" only appears when needed
✅ **Clean Sidebar**: After creation, only real templates are shown
✅ **Intuitive Workflow**: Natural flow from "Untitled" to named template
✅ **Prevents Errors**: Can't add control points to unsaved template

## Testing Checklist

- [ ] Click "Add new template" → "Untitled template" appears
- [ ] Fill form and create template → "Untitled template" disappears
- [ ] New template appears with correct generated name
- [ ] Click existing template → "Untitled template" disappears (if showing)
- [ ] Click "Add new template" again → "Untitled template" reappears
- [ ] Try to add control point to "Untitled template" → Shows error message
- [ ] Create multiple templates → Each time "Untitled template" appears and disappears correctly

## Status
🟢 **COMPLETE** - "Untitled template" behavior is now working as expected
