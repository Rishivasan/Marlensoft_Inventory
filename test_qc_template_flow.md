# QC Template Flow Testing Guide

## Test 1: Create New Template with Control Points (Happy Path)

### Steps:
1. Open the QC Template screen
2. Click "Add new template" button in the left sidebar
3. Verify "Untitled template" appears in sidebar and is active
4. Fill in basic information:
   - Validation type: Select "Incoming Goods Validation"
   - Final product: Select any product
   - Material/Component: Select any material
   - Tools to quality check: Enter "PR"

5. Click "Add control point" button
6. Fill control point form:
   - QC control point name: "Dimension Check"
   - Type: "Measure"
   - Target value: "100"
   - Unit: "mm"
   - Tolerance value: "5"
7. Click "Add control point" button in dialog
8. Verify:
   - ✅ Control point appears in the list
   - ✅ Green banner shows: "1 control point added. Click 'Add new template' to save everything."
   - ✅ Success message: "Control point added! Click 'Add new template' to save."

9. Add another control point:
   - Click "Add control point" again
   - Name: "Visual Inspection"
   - Type: "Visual Inspection"
   - Instructions: "Check for defects"
   - Click "Add control point"

10. Verify:
    - ✅ Both control points appear in list
    - ✅ Green banner shows: "2 control points added. Click 'Add new template' to save everything."

11. Click grey "Add new template" button at bottom
12. Verify:
    - ✅ Loading indicator appears
    - ✅ Template is created with auto-generated name
    - ✅ Template appears in sidebar
    - ✅ "Untitled template" is removed from sidebar
    - ✅ Both control points are saved
    - ✅ Success message: "Template created: [template name]"

### Expected Result:
✅ Template created successfully with both control points

---

## Test 2: Validation - Missing Basic Information

### Steps:
1. Click "Add new template"
2. Add a control point without filling basic information
3. Click "Add control point" button (should work)
4. Click grey "Add new template" button at bottom

### Expected Result:
❌ Error message: "Please select a validation type"

---

## Test 3: Validation - Missing Control Points

### Steps:
1. Click "Add new template"
2. Fill all basic information
3. Do NOT add any control points
4. Click grey "Add new template" button at bottom

### Expected Result:
❌ Error message: "Please add at least one control point before creating the template"

---

## Test 4: Delete Temporary Control Point

### Steps:
1. Click "Add new template"
2. Add 2 control points
3. Verify green banner shows "2 control points added"
4. Click delete icon on first control point
5. Confirm deletion

### Expected Result:
✅ Control point removed from list immediately
✅ Green banner updates to "1 control point added"
✅ No API call made (check network tab)

---

## Test 5: Add Control Point to Existing Template

### Steps:
1. Select an existing template from sidebar
2. Click "Add control point" button
3. Fill control point details
4. Click "Add control point"

### Expected Result:
✅ Loading indicator appears
✅ API call is made immediately
✅ Control point appears in list
✅ Success message: "Control point added successfully!"

---

## Test 6: Delete Control Point from Existing Template

### Steps:
1. Select an existing template with control points
2. Click delete icon on a control point
3. Confirm deletion

### Expected Result:
✅ Loading indicator appears
✅ API call is made to delete
✅ Control point removed from list
✅ Success message: "Control point deleted successfully"

---

## Test 7: Cancel Untitled Template

### Steps:
1. Click "Add new template"
2. Fill basic information
3. Add 2 control points
4. Click "Cancel" button at bottom

### Expected Result:
✅ Dialog closes
✅ Temporary control points are discarded
✅ "Untitled template" remains in sidebar (if not removed)

---

## Test 8: Switch Between Templates

### Steps:
1. Click "Add new template"
2. Add 2 control points (don't save)
3. Click on an existing template in sidebar

### Expected Result:
✅ Switches to existing template
✅ Shows control points from that template
✅ "Untitled template" is removed from sidebar
✅ Temporary control points are lost (expected behavior)

---

## Test 9: Multiple Control Points of Different Types

### Steps:
1. Click "Add new template"
2. Fill basic information
3. Add control points of each type:
   - Measure type
   - Visual Inspection type
   - Take a Picture type
4. Click "Add new template"

### Expected Result:
✅ All control points saved correctly
✅ Each type's specific fields are preserved

---

## Test 10: Form Validation in Control Point Dialog

### Steps:
1. Click "Add new template"
2. Click "Add control point"
3. Try to submit without filling required fields

### Expected Result:
❌ Validation errors appear for empty required fields
❌ Dialog does not close

---

## Regression Tests

### Test R1: Existing Template Workflow Still Works
1. Select existing template
2. Add control point → Should save immediately
3. Delete control point → Should delete immediately
4. Verify no breaking changes

### Test R2: Template Name Generation
1. Create new template
2. Verify name format: `{ValidationTypeCode} - {ProductName} - {MSICode} - {MaterialName}`
3. Example: `IG - Circuit Breaker - MSI-020 - Circuit Board`

### Test R3: Tools Field Persistence
1. Create new template with tools field filled
2. Verify tools field is saved in database
3. Load template and verify tools field displays correctly

---

## Known Issues to Watch For

1. **Memory Leak**: Ensure `tempControlPoints` is cleared after template creation
2. **State Sync**: Verify `controlPoints` and `tempControlPoints` stay in sync
3. **API Errors**: Handle network failures gracefully
4. **Duplicate Control Points**: Ensure no duplicates when saving

---

## Success Criteria

✅ Users can add control points before creating template
✅ Validation prevents incomplete templates
✅ Green banner provides clear feedback
✅ Temporary control points are saved correctly
✅ Delete works for both temporary and saved control points
✅ No breaking changes to existing template workflow
✅ All error cases handled gracefully
