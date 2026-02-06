# Create Template Database Fix - Missing Stored Procedure

## Problem
When clicking "Add new template", the error occurs:
```
Error creating template: Exception: Failed to create template
```

The API returns **400 Bad Request**.

## Root Cause
The backend is trying to call a stored procedure `sp_CreateQCTemplate` that **doesn't exist** in the database.

**Backend Code (QualityRepository.cs):**
```csharp
await db.ExecuteAsync("sp_CreateQCTemplate",
    parameters,
    commandType: CommandType.StoredProcedure);
```

This stored procedure was never created, causing the 400 error.

## Solution
Create the missing stored procedure and ensure the QCTemplate table exists.

## Fix Instructions

### Step 1: Run the SQL Script
1. Open **SQL Server Management Studio**
2. Connect to your SQL Server: `RISHIVASAN-PC`
3. Open the file: `FIX_CREATE_TEMPLATE.sql`
4. Make sure you're connected to the **ManufacturingApp** database
5. Click **Execute** (or press F5)

The script will:
- ✅ Create `QCTemplate` table if it doesn't exist
- ✅ Create `sp_CreateQCTemplate` stored procedure
- ✅ Test the stored procedure
- ✅ Show you the test results

### Step 2: Verify Installation
After running the script, you should see output like:
```
QCTemplate table already exists.
sp_CreateQCTemplate stored procedure created successfully.
Testing the stored procedure...
Test completed. New Template ID: 8
Installation Complete!
```

### Step 3: Test in the Application
1. Open the frontend application
2. Go to Quality Check Customization
3. Select a validation type
4. Select a final product
5. Click "Add new template"
6. Should now work successfully!

## What the Script Creates

### 1. QCTemplate Table (if not exists)
```sql
CREATE TABLE QCTemplate (
    QCTemplateId INT IDENTITY(1,1) PRIMARY KEY,
    TemplateName NVARCHAR(255) NOT NULL,
    ValidationTypeId INT NOT NULL,
    FinalProductId INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE()
);
```

### 2. sp_CreateQCTemplate Stored Procedure
```sql
CREATE PROCEDURE sp_CreateQCTemplate
    @TemplateName NVARCHAR(255),
    @ValidationTypeId INT,
    @FinalProductId INT,
    @NewTemplateId INT OUTPUT
AS
BEGIN
    INSERT INTO QCTemplate (TemplateName, ValidationTypeId, FinalProductId)
    VALUES (@TemplateName, @ValidationTypeId, @FinalProductId);
    
    SET @NewTemplateId = SCOPE_IDENTITY();
    SELECT @NewTemplateId AS NewTemplateId;
END;
```

## Testing After Fix

### Test 1: Create Template via API
```powershell
$body = '{"templateName":"Test Template","validationTypeId":1,"finalProductId":3}'
Invoke-RestMethod -Uri "http://localhost:5069/api/quality/template" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"
```

**Expected Response:**
```json
{
  "templateId": 8
}
```

### Test 2: Create Template via UI
1. Open Quality Check Customization
2. Select "Incoming Goods Validation"
3. Select "Circuit Breaker"
4. Click "Add new template"
5. Should see: "Template created successfully!"
6. New template appears in the list

### Test 3: Verify in Database
```sql
SELECT * FROM QCTemplate ORDER BY QCTemplateId DESC;
```

Should show your newly created templates.

## Error Messages

### Before Fix
```
Error creating template: Exception: Failed to create template
API Status: 400 Bad Request
```

### After Fix
```
Template created successfully!
New template ID: 8
```

## Database Schema

### QCTemplate Table
| Column | Type | Description |
|--------|------|-------------|
| QCTemplateId | INT (PK, Identity) | Auto-increment ID |
| TemplateName | NVARCHAR(255) | Template name |
| ValidationTypeId | INT | FK to ValidationTypes |
| FinalProductId | INT | FK to FinalProducts |
| CreatedDate | DATETIME | Creation timestamp |
| UpdatedDate | DATETIME | Last update timestamp |

### Related Tables
- **ValidationTypes** - Contains validation type options
- **FinalProducts** - Contains product options
- **QCControlPoint** - Contains control points for each template (FK: QCTemplateId)

## Why This Happened
The stored procedure was referenced in the backend code but was never created in the database. This is a common issue when:
1. Database migrations weren't run
2. Stored procedure creation script was missing
3. Database was set up manually without all required objects

## Files Involved

### SQL Scripts
- `FIX_CREATE_TEMPLATE.sql` - Main fix script (run this!)
- `create_qc_template_sp.sql` - Alternative script

### Backend Files
- `Backend/InventoryManagement/Repositories/QualityRepository.cs` - Calls the stored procedure
- `Backend/InventoryManagement/Controllers/QualityController.cs` - API endpoint
- `Backend/InventoryManagement/Services/QualityService.cs` - Service layer

### Frontend Files
- `Frontend/inventory/lib/screens/qc_template_screen.dart` - UI that calls the API
- `Frontend/inventory/lib/services/quality_service.dart` - API client

## Status After Fix
✅ QCTemplate table exists  
✅ sp_CreateQCTemplate stored procedure exists  
✅ API returns 200 OK  
✅ Templates save to database  
✅ UI shows success message  
✅ New templates appear in the list  

## Next Steps After Running the Fix
1. Run `FIX_CREATE_TEMPLATE.sql` in SQL Server Management Studio
2. Restart the backend application (if needed)
3. Test creating a template in the UI
4. Verify templates are saved in the database

## Support
If you still get errors after running the script:
1. Check that you're connected to the correct database (ManufacturingApp)
2. Check that the SQL Server service is running
3. Verify the connection string in `appsettings.json`
4. Check the backend console for detailed error messages
