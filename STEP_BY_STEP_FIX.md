# Step-by-Step Fix for "Add New Template" Error

## The Problem
You're getting this error:
```
Error creating template: Exception: Failed to create template
```

## Why It's Happening
The database is missing a stored procedure that the backend needs.

## How to Fix It (5 Simple Steps)

### Step 1: Open SQL Server Management Studio
- Look for "Microsoft SQL Server Management Studio" in your Start menu
- Click to open it

### Step 2: Connect to Your Database
- Server name: `RISHIVASAN-PC`
- Authentication: Use the credentials you normally use
- Click "Connect"

### Step 3: Select the Database
- In the dropdown at the top, select: `ManufacturingApp`
- OR: Click "New Query" and the first line will be `USE ManufacturingApp;`

### Step 4: Run the Fix Script
**Option A - Open the file:**
1. Click: File → Open → File
2. Navigate to your project folder
3. Open: `RUN_THIS_IN_SSMS.sql`
4. Click the "Execute" button (or press F5)

**Option B - Copy and paste:**
1. Open the file `RUN_THIS_IN_SSMS.sql` in any text editor
2. Copy ALL the text
3. In SQL Server Management Studio, click "New Query"
4. Paste the text
5. Click the "Execute" button (or press F5)

### Step 5: Verify Success
You should see output like:
```
========================================
Creating QC Template Database Objects
========================================

✓ QCTemplate table already exists.
✓ sp_CreateQCTemplate stored procedure created successfully!
✓ Test successful! Created template with ID: 8

========================================
✓✓✓ INSTALLATION COMPLETE! ✓✓✓
========================================
```

## After Running the Script

1. **Go back to your application**
2. **Try clicking "Add new template" again**
3. **It should now work!**

## Still Not Working?

If you still get an error after running the script:

1. **Restart your backend application:**
   - Stop the backend (Ctrl+C in the terminal)
   - Start it again (`dotnet run`)

2. **Check the backend console** for any error messages

3. **Make sure you ran the script in the correct database:**
   - Database name should be: `ManufacturingApp`
   - Server should be: `RISHIVASAN-PC`

## What the Script Does

The script creates:
1. **QCTemplate table** - Stores your templates
2. **sp_CreateQCTemplate** - Stored procedure that creates new templates

Without these, the "Add new template" button cannot work.

## Files You Need

- `RUN_THIS_IN_SSMS.sql` - The fix script (in your project root folder)

## Quick Reference

**Database:** ManufacturingApp  
**Server:** RISHIVASAN-PC  
**Script:** RUN_THIS_IN_SSMS.sql  
**Action:** Execute (F5)  

---

**That's it!** After running the script, your "Add new template" feature will work.
