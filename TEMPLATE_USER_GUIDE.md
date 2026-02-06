# QC Template - User Guide

## Overview
The QC Template screen allows you to create quality control templates with auto-generated descriptive names.

## Template Name Format
All templates follow this naming convention:
```
{ValidationTypeCode} - {FinalProductName} - {MSICode} - {MaterialName}
```

## Validation Type Codes
| Type | Code | When to Use |
|------|------|-------------|
| Incoming Goods Validation | **IG** | When materials arrive from suppliers |
| In-progress Validation | **IP** | During manufacturing process |
| Final Inspection | **FI** | For final product quality check |

## How to Create a New Template

### Step 1: Start New Template
Click the **"Add new template"** button in the left sidebar.

**Result**: The form will clear and be ready for new input.

### Step 2: Fill Basic Information

#### Validation Type (Required)
Select the type of validation:
- Incoming Goods Validation
- In-progress Validation
- Final Inspection

#### Final Product (Required)
Select the product this template is for:
- Circuit Breaker
- Power Supply
- Voltage Regulator
- etc.

#### Material/Component (Required)
Select the material or component:
- Steel Sheet (MSI-001)
- Sensor Chip (MSI-010)
- Circuit Board (MSI-020)
- etc.

**Note**: Materials are loaded based on the selected Final Product.

#### Tools to Quality Check (Optional)
Enter any tools needed for quality checking.

### Step 3: Create Template
Click the **"Add new template"** button at the bottom right.

**Result**: 
- Template is created with auto-generated name
- Template appears in sidebar
- Form clears for next template

## Example Workflow

### Example 1: Creating an Incoming Goods Template

**Selections**:
- Validation Type: **Incoming Goods Validation**
- Final Product: **Circuit Breaker**
- Material: **Steel Sheet (MSI-001)**

**Generated Template Name**:
```
IG - Circuit Breaker - MSI-001 - Steel Sheet
```

### Example 2: Creating an In-progress Template

**Selections**:
- Validation Type: **In-progress Validation**
- Final Product: **Power Supply**
- Material: **Sensor Chip (MSI-010)**

**Generated Template Name**:
```
IP - Power Supply - MSI-010 - Sensor Chip
```

### Example 3: Creating a Final Inspection Template

**Selections**:
- Validation Type: **Final Inspection**
- Final Product: **Voltage Regulator**
- Material: **Circuit Board (MSI-020)**

**Generated Template Name**:
```
FI - Voltage Regulator - MSI-020 - Circuit Board
```

## Adding Control Points

After creating a template, you can add quality control points:

1. Select the template from the sidebar
2. Click **"Add control point"** button
3. Fill in control point details:
   - Control Point Name
   - Control Point Type
   - Target Value
   - Unit
   - Tolerance
4. Click **"Add"** to save

Control points will appear in the list below the form.

## Viewing Existing Templates

1. Templates are listed in the left sidebar
2. Click on any template to view its details
3. The selected template will be highlighted in blue
4. Control points for that template will be displayed

## Template List

Templates in the sidebar show their full generated names:
```
✓ IG - Circuit Breaker - MSI-001 - Steel Sheet
  IP - Power Supply - MSI-010 - Sensor Chip
  FI - Voltage Regulator - MSI-020 - Circuit Board
```

The checkmark (✓) or blue highlight indicates the currently selected template.

## Tips

### Finding Templates
Templates are organized by their names, which include:
- **Validation Type Code** (IG/IP/FI) - Easy to filter by validation stage
- **Product Name** - Easy to find templates for specific products
- **MSI Code** - Unique material identifier for traceability
- **Material Name** - Clear indication of what material is being checked

### Creating Multiple Templates
You can create multiple templates for the same product with different:
- Validation types (IG, IP, FI)
- Materials (different MSI codes)
- Quality control requirements

### Best Practices
1. **Be Specific**: Select the exact material for each template
2. **Use Correct Validation Type**: Choose IG for incoming goods, IP for in-process, FI for final
3. **Add Control Points**: Define specific quality checks for each template
4. **Review Before Creating**: Ensure all selections are correct before clicking "Add new template"

## Common Scenarios

### Scenario 1: Quality Check for Incoming Materials
**Use**: Incoming Goods Validation (IG)
**Example**: `IG - Circuit Breaker - MSI-001 - Steel Sheet`
**Purpose**: Check material quality when it arrives from supplier

### Scenario 2: Quality Check During Production
**Use**: In-progress Validation (IP)
**Example**: `IP - Power Supply - MSI-010 - Sensor Chip`
**Purpose**: Check quality during assembly or manufacturing

### Scenario 3: Final Product Inspection
**Use**: Final Inspection (FI)
**Example**: `FI - Voltage Regulator - MSI-020 - Circuit Board`
**Purpose**: Final quality check before shipping

## Troubleshooting

### "Please select a validation type"
**Solution**: You must select a validation type before creating the template.

### "Please select a final product"
**Solution**: You must select a final product before creating the template.

### "Please select a material/component"
**Solution**: You must select a material/component before creating the template.

### Material dropdown is empty
**Solution**: First select a Final Product. Materials will load based on the selected product.

### Template not appearing in sidebar
**Solution**: Wait a moment for the template list to refresh from the database. If it still doesn't appear, try refreshing the page.

## Summary

✅ **Easy to Use**: Simple form with clear fields
✅ **Auto-Naming**: No need to manually create template names
✅ **Consistent**: All templates follow the same naming format
✅ **Descriptive**: Template names clearly indicate their purpose
✅ **Traceable**: MSI codes provide material traceability
✅ **Organized**: Templates are easy to find and identify

## Need Help?

If you encounter any issues or have questions about creating templates, please contact your system administrator.
