# QC Template Creation - New User Guide

## Overview
You can now create QC templates by filling in all information first, then saving everything together. No need to save the template before adding control points!

---

## Creating a New Template

### Step 1: Start a New Template
1. Click the **"Add new template"** button in the left sidebar
2. An "Untitled template" entry will appear at the top of the sidebar

### Step 2: Fill Basic Information
Fill in all required fields (marked with *):
- **Validation type**: Select the type of validation (e.g., Incoming Goods Validation)
- **Final product**: Select the product this template is for
- **Material/Component**: Select the material (loads after selecting product)
- **Tools to quality check**: Enter the tools needed (e.g., "PR", "Caliper")

### Step 3: Add Control Points
1. Click the **"Add control point"** button (blue button on the right)
2. Fill in the control point details:
   - **QC control point name**: Name of the check (e.g., "Dimension Check")
   - **Type**: Select the type (Measure, Visual Inspection, or Take a Picture)
   - Fill type-specific fields that appear
3. Click **"Add control point"** in the dialog
4. The control point will appear in the list immediately
5. Repeat to add more control points

### Step 4: Save the Template
1. Review your basic information and control points
2. A green banner will show: "X control points added. Click 'Add new template' to save everything."
3. Click the grey **"Add new template"** button at the bottom
4. The template will be created with an auto-generated name
5. All control points will be saved automatically

---

## Template Naming Convention

Templates are automatically named using this format:
```
{ValidationTypeCode} - {ProductName} - {MSICode} - {MaterialName}
```

**Example:**
```
IG - Circuit Breaker - MSI-020 - Circuit Board
```

**Validation Type Codes:**
- IG = Incoming Goods Validation
- IP = In-progress Validation / Inprocess Validation
- FI = Final Inspection

---

## Control Point Types

### 1. Measure
For dimensional checks and measurements.

**Required Fields:**
- Target value (e.g., 100)
- Unit (e.g., mm, cm, kg)
- Tolerance value (e.g., 5)

**Optional:**
- File upload (reference image or document)

### 2. Visual Inspection
For visual quality checks.

**Required Fields:**
- Instructions (what to check for)

**Optional:**
- File upload (reference image)

### 3. Take a Picture
For photo documentation requirements.

**Required Fields:**
- Comments (instructions for the photo)

**Optional:**
- File upload (example photo)

---

## Managing Control Points

### Adding Control Points
- Click "Add control point" button
- Fill in the form
- Click "Add control point" to save
- For untitled templates: Saved locally until you click "Add new template"
- For existing templates: Saved immediately to database

### Deleting Control Points
- Click the red delete icon next to a control point
- Confirm the deletion
- For untitled templates: Removed from local list
- For existing templates: Deleted from database

### Reordering Control Points
- Drag the handle icon (≡) to reorder
- Order determines the sequence during quality checks

---

## Validation Rules

Before you can save a template, you must:
1. ✅ Select a validation type
2. ✅ Select a final product
3. ✅ Select a material/component
4. ✅ Add at least one control point

If any of these are missing, you'll see an error message explaining what's needed.

---

## Tips & Best Practices

### 1. Plan Your Control Points
Before creating the template, list out all the checks you need. This makes the process faster.

### 2. Use Clear Names
Give control points descriptive names like:
- ✅ "Width Measurement at Point A"
- ❌ "Check 1"

### 3. Add Instructions
For Visual Inspection and Take a Picture types, provide clear instructions:
- ✅ "Check for scratches, dents, or discoloration on the surface"
- ❌ "Check quality"

### 4. Set Realistic Tolerances
For Measure type, set tolerances that match your quality standards:
- Target: 100mm, Tolerance: ±5mm means acceptable range is 95-105mm

### 5. Upload Reference Images
Use the file upload feature to provide visual examples of:
- What good quality looks like
- What defects to look for
- Where to take measurements

---

## Common Workflows

### Creating a Simple Template
```
1. Click "Add new template"
2. Fill basic info (2 minutes)
3. Add 3-5 control points (5 minutes)
4. Click "Add new template" to save
Total time: ~7 minutes
```

### Creating a Complex Template
```
1. Click "Add new template"
2. Fill basic info
3. Add 10+ control points with images
4. Review and adjust order
5. Click "Add new template" to save
Total time: ~15-20 minutes
```

### Modifying an Existing Template
```
1. Select template from sidebar
2. Add new control points as needed
3. Delete obsolete control points
4. Changes save automatically
```

---

## Troubleshooting

### "Please select a validation type"
**Problem:** You tried to save without selecting a validation type.
**Solution:** Select a validation type from the dropdown.

### "Please add at least one control point"
**Problem:** You tried to save without adding any control points.
**Solution:** Click "Add control point" and add at least one check.

### Control point not appearing
**Problem:** You clicked "Add control point" but nothing happened.
**Solution:** Check that all required fields are filled (marked with *).

### Template name looks wrong
**Problem:** The auto-generated name doesn't match your expectations.
**Solution:** The name is generated from your selections. Check that you selected the correct:
- Validation type
- Final product
- Material/Component

### Lost my work
**Problem:** You added control points but they disappeared.
**Solution:** For untitled templates, control points are only saved when you click "Add new template". If you switch to another template or close the screen, they will be lost.

---

## Keyboard Shortcuts

- **Tab**: Move to next field
- **Shift + Tab**: Move to previous field
- **Enter**: Submit form (in dialogs)
- **Esc**: Close dialog

---

## Visual Indicators

### Green Banner
Shows when you've added control points to an untitled template:
```
"2 control points added. Click 'Add new template' to save everything."
```

### Blue Highlight
Indicates the currently selected template in the sidebar.

### Red Asterisk (*)
Marks required fields that must be filled.

### Loading Spinner
Appears when saving data to the server.

---

## Need Help?

If you encounter issues:
1. Check this guide for common solutions
2. Verify all required fields are filled
3. Check your internet connection
4. Contact support with:
   - What you were trying to do
   - What error message you saw
   - Screenshots if possible
