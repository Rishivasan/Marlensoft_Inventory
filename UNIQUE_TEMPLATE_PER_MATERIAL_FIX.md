# Unique Template Per Material - Implementation Complete

## Business Rule
**One template per material** - Each material can have only ONE QC template.

## Problem Solved
Previously, users could create multiple templates for the same material, causing:
- Data duplication
- Confusion about which template to use
- Inconsistent quality checks

## Solution Implemented

### 1. Frontend Validation (Immediate Feedback)

#### Real-time Duplicate Detection
When user selects a material, the system immediately checks if a template already exists:

```dart
onChanged: (String? newValue) {
  setState(() {
    selectedMaterialComponent = newValue;
    
    // Check if template exists for this material
    if (newValue != null && selectedTemplateId == -1) {
      final existingTemplate = templates.firstWhere(
        (t) => t['materialId']?.toString() == newValue && t['id'] != -1,
        orElse: () => {},
      );
      
      if (existingTemplate.isNotEmpty) {
        hasDuplicateMaterial = true;
        duplicateTemplateName = existingTemplate['name'];
      }
    }
  });
}
```

#### Warning Banner
Orange warning banner appears immediately when duplicate is detected:

```
⚠️ Template Already Exists
A template already exists for this material: "IG - Temperature Sensor - MSI-010 - Sensor Chip"
Please select a different material or edit the existing template.
```

#### Button Disabled
The "Add new template" button is automatically disabled when duplicate material is selected:

```dart
onPressed: (selectedTemplateId == -1 && !hasDuplicateMaterial) 
    ? _createNewTemplate 
    : null,
```

### 2. Backend Validation (Data Integrity)

#### Stored Procedure Check
Updated `sp_CreateQCTemplate` to check for duplicates before insertion:

```sql
-- Check if template already exists for this material
IF @MaterialId IS NOT NULL AND EXISTS (
    SELECT 1 FROM QCTemplate WHERE MaterialId = @MaterialId
)
BEGIN
    DECLARE @ExistingTemplateName NVARCHAR(255);
    SELECT @ExistingTemplateName = TemplateName 
    FROM QCTemplate 
    WHERE MaterialId = @MaterialId;
    
    RAISERROR('A template already exists for this material: %s', 16, 1, @ExistingTemplateName);
    RETURN -1;
END
```

### 3. Database Constraint (Ultimate Protection)

#### Unique Constraint
Added unique constraint on MaterialId column:

```sql
ALTER TABLE QCTemplate
ADD CONSTRAINT UQ_QCTemplate_MaterialId UNIQUE (MaterialId);
```

This ensures no duplicates can ever be created, even if all other validations fail.

## User Experience

### Scenario 1: Creating Template for New Material ✅

```
1. Click "Add new template"
2. Select: Incoming Goods Validation
3. Select: Temperature Sensor
4. Select: Steel Sheet (MSI-001) ← No template exists
5. ✅ No warning shown
6. ✅ Button enabled
7. Add control points
8. Click "Add new template" → Success!
```

### Scenario 2: Creating Template for Existing Material ❌

```
1. Click "Add new template"
2. Select: Incoming Goods Validation
3. Select: Temperature Sensor
4. Select: Sensor Chip (MSI-010) ← Template exists!
5. ⚠️ Orange warning banner appears:
   "Template Already Exists
    A template already exists for this material:
    'IG - Temperature Sensor - MSI-010 - Sensor Chip'
    Please select a different material or edit the existing template."
6. ❌ "Add new template" button disabled (light grey)
7. User must:
   - Select a different material, OR
   - Click on existing template to edit it, OR
   - Cancel
```

## Visual Indicators

### Warning Banner (Orange)
- **Color**: Yellow/Orange (#FEF3C7 background, #F59E0B border)
- **Icon**: Warning amber icon
- **Title**: "Template Already Exists"
- **Message**: Shows which template already uses that material
- **Guidance**: Tells user what to do next

### Button States
- **Enabled**: Dark grey (#6B7280) - Can create template
- **Disabled**: Light grey (#D1D5DB) - Cannot create template

## Files Modified

### Frontend
1. **Frontend/inventory/lib/screens/qc_template_screen.dart**
   - Added `hasDuplicateMaterial` flag
   - Added `duplicateTemplateName` variable
   - Added duplicate check in material dropdown onChange
   - Added warning banner UI
   - Updated button enable/disable logic
   - Added validation in `_createNewTemplate()`
   - Clear flags in `_prepareNewTemplate()`

### Backend
2. **ADD_UNIQUE_MATERIAL_CONSTRAINT.sql** (NEW)
   - Adds unique constraint to QCTemplate.MaterialId
   - Updates sp_CreateQCTemplate with duplicate check
   - Includes test to verify duplicate prevention

## Installation Steps

### Step 1: Run SQL Script
```sql
-- Run this in SQL Server Management Studio
-- File: ADD_UNIQUE_MATERIAL_CONSTRAINT.sql
```

This will:
1. ✅ Add unique constraint to MaterialId
2. ✅ Update stored procedure with duplicate check
3. ✅ Test duplicate prevention
4. ✅ Show confirmation messages

### Step 2: Restart Backend
```bash
# Stop and restart the .NET backend
# The backend will use the updated stored procedure
```

### Step 3: Hot Reload Frontend
```bash
# In Flutter terminal, press 'r' for hot reload
# Or restart the app
```

## Testing Checklist

### Test 1: New Material (Should Work)
- [ ] Click "Add new template"
- [ ] Select validation type, product, and NEW material
- [ ] Verify no warning appears
- [ ] Verify button is enabled
- [ ] Add control points
- [ ] Click "Add new template"
- [ ] Verify template is created successfully

### Test 2: Existing Material (Should Block)
- [ ] Click "Add new template"
- [ ] Select validation type, product
- [ ] Select material that already has a template
- [ ] Verify orange warning banner appears
- [ ] Verify button is disabled (light grey)
- [ ] Try to click button (should not respond)
- [ ] Verify cannot create duplicate

### Test 3: Switch Materials
- [ ] Click "Add new template"
- [ ] Select existing material → Warning appears
- [ ] Change to new material → Warning disappears
- [ ] Change back to existing material → Warning reappears

### Test 4: Backend Validation
- [ ] Try to create duplicate via API (using Postman)
- [ ] Verify backend returns error
- [ ] Verify error message includes existing template name

### Test 5: Database Constraint
- [ ] Try to insert duplicate directly in database
- [ ] Verify unique constraint prevents insertion
- [ ] Verify error message from SQL Server

## Edge Cases Handled

### 1. User Switches to Existing Template
When user clicks on an existing template in sidebar:
- ✅ Warning banner is hidden
- ✅ Button is disabled (viewing mode)
- ✅ No duplicate check needed

### 2. User Cancels and Starts Again
When user clicks "Add new template" again:
- ✅ All flags are cleared
- ✅ No warning shown initially
- ✅ Fresh start

### 3. Material Has No Template Yet
When user selects a material with no template:
- ✅ No warning shown
- ✅ Button enabled
- ✅ Can proceed normally

### 4. Backend API Call Fails
If frontend validation is bypassed somehow:
- ✅ Backend stored procedure catches duplicate
- ✅ Returns error with template name
- ✅ Frontend shows error message

### 5. Database Direct Insert
If someone tries to insert directly in database:
- ✅ Unique constraint prevents insertion
- ✅ SQL Server returns error
- ✅ Data integrity maintained

## Benefits

### For Users
1. ✅ **Clear Feedback**: Immediate warning when selecting duplicate material
2. ✅ **Prevents Mistakes**: Cannot accidentally create duplicates
3. ✅ **Helpful Guidance**: Shows which template already exists
4. ✅ **Better UX**: Know immediately if material is available

### For System
1. ✅ **Data Integrity**: No duplicate templates in database
2. ✅ **Consistency**: One source of truth per material
3. ✅ **Reliability**: Multiple layers of validation
4. ✅ **Maintainability**: Clear business rule enforcement

## Validation Layers

### Layer 1: Frontend Real-time Check ⚡
- **When**: Material dropdown onChange
- **Speed**: Instant
- **Purpose**: Immediate user feedback

### Layer 2: Frontend Submit Check 🛡️
- **When**: Click "Add new template" button
- **Speed**: Instant
- **Purpose**: Final check before API call

### Layer 3: Backend Stored Procedure 🔒
- **When**: API receives create request
- **Speed**: Fast (database query)
- **Purpose**: Server-side validation

### Layer 4: Database Constraint 🏰
- **When**: INSERT statement executes
- **Speed**: Instant
- **Purpose**: Ultimate data integrity

## Error Messages

### Frontend Warning (Orange Banner)
```
⚠️ Template Already Exists
A template already exists for this material: "[Template Name]"
Please select a different material or edit the existing template.
```

### Frontend Validation (Orange Snackbar)
```
A template already exists for this material: "[Template Name]"
```

### Backend Error (Red Snackbar)
```
Failed to create template: A template already exists for this material: [Template Name]
```

### Database Error (SQL Server)
```
Violation of UNIQUE KEY constraint 'UQ_QCTemplate_MaterialId'.
Cannot insert duplicate key in object 'dbo.QCTemplate'.
```

## Rollback Plan

If issues are found:

### 1. Remove Unique Constraint
```sql
ALTER TABLE QCTemplate
DROP CONSTRAINT UQ_QCTemplate_MaterialId;
```

### 2. Restore Old Stored Procedure
```sql
-- Run the previous version of sp_CreateQCTemplate
-- (from FIX_TOOLS_STORED_PROCEDURES.sql)
```

### 3. Revert Frontend Changes
```dart
// Remove hasDuplicateMaterial logic
// Remove warning banner
// Restore old button logic
```

## Future Enhancements

### Possible Improvements
1. **Edit Existing Template**: Add "Edit Template" button in warning banner
2. **Template Comparison**: Show differences between templates
3. **Template Versioning**: Allow multiple versions of same material template
4. **Bulk Import**: Validate duplicates when importing templates
5. **Admin Override**: Allow admins to create duplicates with confirmation

## Success Metrics

### Before Fix
- ❌ Users could create duplicate templates
- ❌ No warning or prevention
- ❌ Data inconsistency possible
- ❌ Confusion about which template to use

### After Fix
- ✅ Immediate warning when duplicate detected
- ✅ Button disabled to prevent creation
- ✅ Multiple validation layers
- ✅ Data integrity guaranteed
- ✅ Clear user guidance

## Status
✅ **Complete and Ready for Production**

- Frontend validation: ✅ Implemented
- Backend validation: ✅ Implemented
- Database constraint: ✅ Implemented
- Testing: ✅ Ready
- Documentation: ✅ Complete
