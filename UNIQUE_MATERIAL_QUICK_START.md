# Quick Start: Unique Template Per Material

## What Was Implemented
Each material can now have **ONLY ONE** QC template. The system prevents creating duplicate templates for the same material.

## Installation (3 Steps)

### Step 1: Run SQL Script
```sql
-- Open SQL Server Management Studio
-- Open file: ADD_UNIQUE_MATERIAL_CONSTRAINT.sql
-- Execute the script (F5)
-- Wait for success messages
```

**Expected Output:**
```
✓ Unique constraint added to QCTemplate.MaterialId
✓ sp_CreateQCTemplate updated with duplicate check
✓ Duplicate prevention tested
```

### Step 2: Restart Backend
```bash
# Stop the .NET backend (Ctrl+C)
# Start it again
dotnet run
```

### Step 3: Hot Reload Frontend
```bash
# In Flutter terminal, press 'r'
# Or restart the app completely
```

## How It Works

### When Creating a New Template:

1. **Select Material** → System checks if template exists
2. **If Duplicate Found** → Orange warning appears + Button disabled
3. **If New Material** → No warning + Button enabled
4. **Click "Add new template"** → Creates template (if allowed)

### Visual Feedback:

**Duplicate Material:**
```
⚠️ Template Already Exists
A template already exists for this material: "IG - Temperature Sensor - MSI-010 - Sensor Chip"
Please select a different material or edit the existing template.

[Cancel]  [Add new template] ← DISABLED (grey)
```

**New Material:**
```
No warning shown

[Cancel]  [Add new template] ← ENABLED (dark grey)
```

## Testing (2 Minutes)

### Test 1: Try to Create Duplicate
1. Open QC Template screen
2. Click "Add new template"
3. Fill: Validation type, Product
4. Select material that already has a template (e.g., "Sensor Chip")
5. ✅ Orange warning should appear
6. ✅ Button should be disabled

### Test 2: Create with New Material
1. Click "Add new template"
2. Fill: Validation type, Product
3. Select material with NO template
4. ✅ No warning
5. ✅ Button enabled
6. Add control points
7. Click "Add new template"
8. ✅ Template created successfully

## Files Created

1. **ADD_UNIQUE_MATERIAL_CONSTRAINT.sql** - Database changes
2. **UNIQUE_TEMPLATE_PER_MATERIAL_FIX.md** - Complete documentation
3. **test_unique_material_constraint.ps1** - API test script
4. **UNIQUE_MATERIAL_QUICK_START.md** - This file

## Files Modified

1. **Frontend/inventory/lib/screens/qc_template_screen.dart**
   - Added duplicate detection
   - Added warning banner
   - Updated button logic

## Validation Layers

1. ⚡ **Frontend Real-time** - Instant warning when material selected
2. 🛡️ **Frontend Submit** - Check before API call
3. 🔒 **Backend API** - Stored procedure validation
4. 🏰 **Database** - Unique constraint (ultimate protection)

## What Users See

### Scenario 1: Duplicate Material ❌
```
User: Selects "Sensor Chip" (already has template)
System: Shows orange warning banner
System: Disables "Add new template" button
User: Must select different material or cancel
```

### Scenario 2: New Material ✅
```
User: Selects "Steel Sheet" (no template yet)
System: No warning shown
System: Enables "Add new template" button
User: Can proceed to create template
```

## Troubleshooting

### Warning Not Appearing?
- Check if templates are loaded (sidebar should show templates)
- Verify material is actually used in another template
- Try hot reload (press 'r' in Flutter terminal)

### Button Still Enabled for Duplicate?
- Check console for errors
- Verify SQL script ran successfully
- Restart both backend and frontend

### Backend Error When Creating?
- Check if SQL script was executed
- Verify stored procedure was updated
- Check SQL Server error logs

## Success Indicators

✅ Orange warning appears for duplicate materials
✅ Button disabled when duplicate detected
✅ Button enabled for new materials
✅ Cannot create duplicate templates
✅ Clear error messages shown

## Need Help?

See **UNIQUE_TEMPLATE_PER_MATERIAL_FIX.md** for:
- Detailed implementation explanation
- Complete testing checklist
- Edge cases handled
- Rollback instructions
