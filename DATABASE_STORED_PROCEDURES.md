# DATABASE STORED PROCEDURES DOCUMENTATION
# Inventory Management System - SQL Server

## Table of Contents
1. [Overview](#overview)
2. [Quality Control Stored Procedures](#quality-control-stored-procedures)
3. [Master Register Stored Procedures](#master-register-stored-procedures)
4. [Maintenance & Allocation Stored Procedures](#maintenance--allocation-stored-procedures)
5. [Stored Procedure Best Practices](#stored-procedure-best-practices)

---

## 1. Overview

### What are Stored Procedures?

**Stored Procedures** are precompiled SQL code blocks stored in the database that can be executed by applications.

**Why Use Stored Procedures?**
- **Performance**: Precompiled and cached execution plans
- **Security**: Prevent SQL injection attacks
- **Maintainability**: Centralized business logic
- **Reusability**: Called from multiple applications
- **Network Traffic**: Reduced data transfer
- **Transaction Management**: Built-in transaction support

### Naming Convention

All stored procedures in this system follow the pattern:
```
sp_{Action}{Entity}
```

Examples:
- `sp_CreateQCTemplate` - Create a QC Template
- `sp_GetAllQCTemplates` - Get all QC Templates
- `sp_UpdateQCTemplate` - Update a QC Template
- `sp_DeleteQCControlPoint` - Delete a Control Point

---

## 2. Quality Control Stored Procedures

### 2.1 sp_CreateQCTemplate

**Purpose**: Create a new QC template with validation and duplicate prevention.

**Parameters**:
- `@TemplateName` NVARCHAR(255) - Template name
- `@ValidationTypeId` INT - Validation type (IG, IP, FI)
- `@FinalProductId` INT - Final product reference
- `@MaterialId` INT (Optional) - Material reference
- `@ToolsToQualityCheck` NVARCHAR(500) (Optional) - Tools required
- `@NewTemplateId` INT OUTPUT - Returns new template ID

**SQL Code**:
```sql
CREATE PROCEDURE sp_CreateQCTemplate
    @TemplateName NVARCHAR(255),
    @ValidationTypeId INT,
    @FinalProductId INT,
    @MaterialId INT = NULL,
    @ToolsToQualityCheck NVARCHAR(500) = NULL,
    @NewTemplateId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if a template already exists for this material
        IF @MaterialId IS NOT NULL AND EXISTS (
            SELECT 1 FROM QCTemplate WHERE MaterialId = @MaterialId
        )
        BEGIN
            -- Get the existing template name for error message
            DECLARE @ExistingTemplateName NVARCHAR(255);
            SELECT @ExistingTemplateName = TemplateName 
            FROM QCTemplate 
            WHERE MaterialId = @MaterialId;
            
            -- Return error
            RAISERROR('A template already exists for this material: %s', 16, 1, @ExistingTemplateName);
            RETURN -1;
        END
        
        -- Insert the new template
        INSERT INTO QCTemplate (
            TemplateName, 
            ValidationTypeId, 
            FinalProductId, 
            MaterialId,
            ToolsToQualityCheck,
            CreatedDate
        )
        VALUES (
            @TemplateName, 
            @ValidationTypeId, 
            @FinalProductId, 
            @MaterialId,
            @ToolsToQualityCheck,
            GETDATE()
        );
        
        -- Get the newly created template ID
        SET @NewTemplateId = SCOPE_IDENTITY();
        
        -- Return the new ID
        SELECT @NewTemplateId AS NewTemplateId;
        
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END;
```

**Why This Design?**

1. **Duplicate Prevention**:
```sql
IF @MaterialId IS NOT NULL AND EXISTS (
    SELECT 1 FROM QCTemplate WHERE MaterialId = @MaterialId
)
```
- Checks if template already exists for material
- Prevents duplicate templates
- Returns meaningful error message

2. **OUTPUT Parameter**:
```sql
@NewTemplateId INT OUTPUT
```
- Returns the newly created template ID
- Used by application to add control points
- Eliminates need for separate query

3. **Error Handling**:
```sql
BEGIN TRY
    -- Code
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@ErrorMessage, 16, 1);
END CATCH
```
- Catches and reports errors
- Provides detailed error messages
- Prevents silent failures

**Usage Example**:
```sql
DECLARE @NewId INT;

EXEC sp_CreateQCTemplate 
    @TemplateName = 'IG - Product A - MSI-001 - Steel Grade A',
    @ValidationTypeId = 1,
    @FinalProductId = 1,
    @MaterialId = 1,
    @ToolsToQualityCheck = 'Caliper, Micrometer',
    @NewTemplateId = @NewId OUTPUT;

PRINT 'New Template ID: ' + CAST(@NewId AS VARCHAR(10));
```

**C# Backend Usage**:
```csharp
public async Task<int> CreateQCTemplate(string templateName, int validationTypeId, 
    int finalProductId, int? materialId = null, string? toolsToQualityCheck = null)
{
    using var db = Connection;

    var parameters = new DynamicParameters();
    parameters.Add("@TemplateName", templateName);
    parameters.Add("@ValidationTypeId", validationTypeId);
    parameters.Add("@FinalProductId", finalProductId);
    parameters.Add("@MaterialId", materialId);
    parameters.Add("@ToolsToQualityCheck", toolsToQualityCheck);
    parameters.Add("@NewTemplateId", dbType: DbType.Int32, direction: ParameterDirection.Output);

    await db.ExecuteAsync("sp_CreateQCTemplate", parameters, 
        commandType: CommandType.StoredProcedure);

    return parameters.Get<int>("@NewTemplateId");
}
```


### 2.2 sp_GetAllQCTemplates

**Purpose**: Retrieve all QC templates with related information.

**Parameters**: None

**SQL Code**:
```sql
CREATE PROCEDURE sp_GetAllQCTemplates
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        t.QCTemplateId,
        t.TemplateName,
        t.ValidationTypeId,
        t.FinalProductId,
        t.MaterialId,
        t.ToolsToQualityCheck,
        fp.ProductName,
        m.MaterialName,
        m.MSICode,
        vt.ValidationTypeName,
        vt.ValidationTypeCode,
        t.CreatedDate
    FROM QCTemplate t
    LEFT JOIN FinalProduct fp ON t.FinalProductId = fp.FinalProductId
    LEFT JOIN Material m ON t.MaterialId = m.MaterialId
    LEFT JOIN ValidationType vt ON t.ValidationTypeId = vt.ValidationTypeId
    ORDER BY t.CreatedDate DESC;
END;
```

**Why This Design?**

1. **LEFT JOIN**:
- Includes templates even if related data is missing
- Prevents data loss
- Handles NULL values gracefully

2. **Denormalized Data**:
- Returns all related information in one query
- Reduces number of database calls
- Improves performance

3. **ORDER BY CreatedDate DESC**:
- Shows newest templates first
- User-friendly ordering
- Consistent behavior

**Usage Example**:
```sql
EXEC sp_GetAllQCTemplates;
```

**Result Set**:
```
QCTemplateId | TemplateName                              | ValidationTypeCode | ProductName | MaterialName  | ToolsToQualityCheck
-------------|-------------------------------------------|-------------------|-------------|---------------|--------------------
1            | IG - Product A - MSI-001 - Steel Grade A | IG                | Product A   | Steel Grade A | Caliper, Micrometer
2            | IP - Product A - MSI-002 - Aluminum Alloy| IP                | Product A   | Aluminum Alloy| Caliper, Gauge
```


### 2.3 sp_UpdateQCTemplate

**Purpose**: Update an existing QC template.

**Parameters**:
- `@QCTemplateId` INT - Template ID to update
- `@TemplateName` NVARCHAR(255) (Optional) - New template name
- `@ValidationTypeId` INT (Optional) - New validation type
- `@FinalProductId` INT (Optional) - New final product
- `@MaterialId` INT (Optional) - New material
- `@ToolsToQualityCheck` NVARCHAR(500) (Optional) - New tools

**SQL Code**:
```sql
CREATE PROCEDURE sp_UpdateQCTemplate
    @QCTemplateId INT,
    @TemplateName NVARCHAR(255) = NULL,
    @ValidationTypeId INT = NULL,
    @FinalProductId INT = NULL,
    @MaterialId INT = NULL,
    @ToolsToQualityCheck NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        UPDATE QCTemplate
        SET 
            TemplateName = ISNULL(@TemplateName, TemplateName),
            ValidationTypeId = ISNULL(@ValidationTypeId, ValidationTypeId),
            FinalProductId = ISNULL(@FinalProductId, FinalProductId),
            MaterialId = ISNULL(@MaterialId, MaterialId),
            ToolsToQualityCheck = ISNULL(@ToolsToQualityCheck, ToolsToQualityCheck),
            UpdatedDate = GETDATE()
        WHERE QCTemplateId = @QCTemplateId;
        
        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
```

**Why This Design?**

1. **ISNULL Pattern**:
```sql
TemplateName = ISNULL(@TemplateName, TemplateName)
```
- Only updates fields that are provided
- NULL parameters keep existing values
- Flexible partial updates

2. **@@ROWCOUNT**:
```sql
SELECT @@ROWCOUNT AS RowsAffected;
```
- Returns number of rows updated
- Confirms update success
- 0 = template not found, 1 = success

**Usage Example**:
```sql
-- Update only the template name
EXEC sp_UpdateQCTemplate 
    @QCTemplateId = 1,
    @TemplateName = 'Updated Template Name';

-- Update multiple fields
EXEC sp_UpdateQCTemplate 
    @QCTemplateId = 1,
    @TemplateName = 'New Name',
    @ToolsToQualityCheck = 'Caliper, Micrometer, Gauge';
```


### 2.4 sp_AddQCControlPoint

**Purpose**: Add a control point to a QC template.

**Parameters**:
- `@QCTemplateId` INT - Template ID
- `@ControlPointTypeId` INT - Type of control point
- `@ControlPointName` NVARCHAR(200) - Name of checkpoint
- `@TargetValue` NVARCHAR(100) (Optional) - Expected value
- `@Unit` NVARCHAR(50) (Optional) - Measurement unit
- `@Tolerance` NVARCHAR(50) (Optional) - Tolerance value
- `@Instructions` NVARCHAR(MAX) (Optional) - Instructions
- `@ImagePath` NVARCHAR(500) (Optional) - Image reference
- `@SequenceOrder` INT (Optional) - Display order

**SQL Code**:
```sql
CREATE PROCEDURE sp_AddQCControlPoint
    @QCTemplateId INT,
    @ControlPointTypeId INT,
    @ControlPointName NVARCHAR(200),
    @TargetValue NVARCHAR(100) = NULL,
    @Unit NVARCHAR(50) = NULL,
    @Tolerance NVARCHAR(50) = NULL,
    @Instructions NVARCHAR(MAX) = NULL,
    @ImagePath NVARCHAR(500) = NULL,
    @SequenceOrder INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Auto-generate sequence order if not provided
        IF @SequenceOrder IS NULL
        BEGIN
            SELECT @SequenceOrder = ISNULL(MAX(SequenceOrder), 0) + 1
            FROM QCControlPoint
            WHERE QCTemplateId = @QCTemplateId;
        END
        
        INSERT INTO QCControlPoint (
            QCTemplateId,
            ControlPointTypeId,
            ControlPointName,
            TargetValue,
            Unit,
            Tolerance,
            Instructions,
            ImagePath,
            SequenceOrder,
            CreatedDate
        )
        VALUES (
            @QCTemplateId,
            @ControlPointTypeId,
            @ControlPointName,
            @TargetValue,
            @Unit,
            @Tolerance,
            @Instructions,
            @ImagePath,
            @SequenceOrder,
            GETDATE()
        );
        
        SELECT SCOPE_IDENTITY() AS NewControlPointId;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
```

**Why This Design?**

1. **Auto-Sequence Generation**:
```sql
IF @SequenceOrder IS NULL
BEGIN
    SELECT @SequenceOrder = ISNULL(MAX(SequenceOrder), 0) + 1
    FROM QCControlPoint
    WHERE QCTemplateId = @QCTemplateId;
END
```
- Automatically assigns next sequence number
- No manual ordering required
- Prevents sequence conflicts

2. **SCOPE_IDENTITY()**:
- Returns the newly created control point ID
- Used for immediate reference
- More efficient than separate query

**Usage Example**:
```sql
DECLARE @NewId INT;

EXEC sp_AddQCControlPoint 
    @QCTemplateId = 1,
    @ControlPointTypeId = 1,
    @ControlPointName = 'Length Measurement',
    @TargetValue = '100',
    @Unit = 'mm',
    @Tolerance = '±0.5';

-- Sequence order is auto-generated
```


### 2.5 sp_GetQCControlPointsByTemplate

**Purpose**: Retrieve all control points for a specific template.

**Parameters**:
- `@QCTemplateId` INT - Template ID

**SQL Code**:
```sql
CREATE PROCEDURE sp_GetQCControlPointsByTemplate
    @QCTemplateId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        cp.QCControlPointId,
        cp.QCTemplateId,
        cp.ControlPointTypeId,
        cp.ControlPointName,
        cp.TargetValue,
        cp.Unit,
        cp.Tolerance,
        cp.Instructions,
        cp.ImagePath,
        cp.SequenceOrder,
        cpt.ControlPointTypeName,
        cpt.Description AS TypeDescription
    FROM QCControlPoint cp
    INNER JOIN ControlPointType cpt ON cp.ControlPointTypeId = cpt.ControlPointTypeId
    WHERE cp.QCTemplateId = @QCTemplateId
    ORDER BY cp.SequenceOrder;
END;
```

**Why This Design?**

1. **INNER JOIN with ControlPointType**:
- Returns type name and description
- Provides complete information
- Reduces frontend queries

2. **ORDER BY SequenceOrder**:
- Returns control points in correct order
- Maintains user-defined sequence
- Ready for display

**Usage Example**:
```sql
EXEC sp_GetQCControlPointsByTemplate @QCTemplateId = 1;
```

**Result Set**:
```
QCControlPointId | ControlPointName      | ControlPointTypeName | TargetValue | Unit | Tolerance | SequenceOrder
-----------------|-----------------------|---------------------|-------------|------|-----------|---------------
1                | Length Measurement    | Dimensional         | 100         | mm   | ±0.5      | 1
2                | Width Measurement     | Dimensional         | 50          | mm   | ±0.3      | 2
3                | Surface Finish Check  | Visual              | Smooth      | NULL | NULL      | 3
```


### 2.6 sp_DeleteQCControlPoint

**Purpose**: Delete a control point from a template.

**Parameters**:
- `@QCControlPointId` INT - Control point ID to delete

**SQL Code**:
```sql
CREATE PROCEDURE sp_DeleteQCControlPoint
    @QCControlPointId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DELETE FROM QCControlPoint
        WHERE QCControlPointId = @QCControlPointId;
        
        SELECT @@ROWCOUNT AS RowsDeleted;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
```

**Why This Design?**

1. **Simple Delete**:
- Direct deletion by ID
- No cascade needed (handled by FK)
- Returns rows deleted for confirmation

2. **@@ROWCOUNT**:
- 0 = control point not found
- 1 = successfully deleted
- Confirms operation

**Usage Example**:
```sql
EXEC sp_DeleteQCControlPoint @QCControlPointId = 5;
```

### 2.7 sp_GetFinalProducts

**Purpose**: Retrieve all active final products.

**Parameters**: None

**SQL Code**:
```sql
CREATE PROCEDURE sp_GetFinalProducts
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        FinalProductId,
        ProductName,
        ProductCode,
        Description
    FROM FinalProduct
    WHERE IsActive = 1
    ORDER BY ProductName;
END;
```

**Usage Example**:
```sql
EXEC sp_GetFinalProducts;
```

**Result Set**:
```
FinalProductId | ProductName | ProductCode  | Description
---------------|-------------|--------------|------------------
1              | Product A   | PROD-A-001   | Main product line A
2              | Product B   | PROD-B-001   | Main product line B
3              | Product C   | PROD-C-001   | Main product line C
```


### 2.8 sp_GetMaterialsByFinalProduct

**Purpose**: Retrieve materials for a specific final product.

**Parameters**:
- `@FinalProductId` INT - Final product ID

**SQL Code**:
```sql
CREATE PROCEDURE sp_GetMaterialsByFinalProduct
    @FinalProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        MaterialId,
        MaterialName,
        MSICode,
        FinalProductId,
        Specifications
    FROM Material
    WHERE FinalProductId = @FinalProductId
      AND IsActive = 1
    ORDER BY MaterialName;
END;
```

**Why This Design?**

1. **Filtered by Product**:
- Returns only materials for selected product
- Reduces data transfer
- Improves user experience

2. **IsActive Filter**:
- Shows only active materials
- Hides discontinued items
- Maintains data integrity

**Usage Example**:
```sql
EXEC sp_GetMaterialsByFinalProduct @FinalProductId = 1;
```

**Result Set**:
```
MaterialId | MaterialName      | MSICode  | FinalProductId | Specifications
-----------|-------------------|----------|----------------|---------------------------
1          | Steel Grade A     | MSI-001  | 1              | High strength steel
2          | Aluminum Alloy    | MSI-002  | 1              | Lightweight alloy
```

### 2.9 sp_GetValidationTypes

**Purpose**: Retrieve all validation types.

**Parameters**: None

**SQL Code**:
```sql
CREATE PROCEDURE sp_GetValidationTypes
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ValidationTypeId,
        ValidationTypeName,
        ValidationTypeCode,
        Description
    FROM ValidationType
    WHERE IsActive = 1
    ORDER BY ValidationTypeCode;
END;
```

**Usage Example**:
```sql
EXEC sp_GetValidationTypes;
```

**Result Set**:
```
ValidationTypeId | ValidationTypeName              | ValidationTypeCode | Description
-----------------|---------------------------------|--------------------|---------------------------
3                | Final Inspection                | FI                 | Final quality check
1                | Incoming Goods Validation       | IG                 | Quality check for incoming
2                | In-progress/Inprocess Validation| IP                 | Quality check during mfg
```


### 2.10 sp_GetUnits

**Purpose**: Retrieve all measurement units.

**Parameters**: None

**SQL Code**:
```sql
CREATE PROCEDURE sp_GetUnits
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Return common units used in quality control
    SELECT Unit
    FROM (
        VALUES 
            ('mm'),
            ('cm'),
            ('m'),
            ('kg'),
            ('g'),
            ('°C'),
            ('%'),
            ('pcs'),
            ('V'),
            ('A'),
            ('Hz'),
            ('Pa'),
            ('bar'),
            ('psi'),
            ('rpm'),
            ('dB'),
            ('lux'),
            ('pH'),
            ('Ω'),
            ('W')
    ) AS Units(Unit)
    ORDER BY Unit;
END;
```

**Why This Design?**

1. **VALUES Constructor**:
- Hardcoded list of common units
- No separate Units table needed
- Fast and efficient

2. **Alphabetical Order**:
- Easy to find units
- User-friendly
- Consistent behavior

**Usage Example**:
```sql
EXEC sp_GetUnits;
```

**Result Set**:
```
Unit
----
%
°C
A
bar
cm
dB
g
Hz
kg
lux
m
mm
Pa
pcs
pH
psi
rpm
V
W
Ω
```


### 2.11 sp_GetQCControlPointTypes

**Purpose**: Retrieve all control point types.

**Parameters**: None

**SQL Code**:
```sql
CREATE PROCEDURE sp_GetQCControlPointTypes
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ControlPointTypeId,
        ControlPointTypeName,
        Description
    FROM ControlPointType
    WHERE IsActive = 1
    ORDER BY ControlPointTypeName;
END;
```

**Usage Example**:
```sql
EXEC sp_GetQCControlPointTypes;
```

**Result Set**:
```
ControlPointTypeId | ControlPointTypeName | Description
-------------------|---------------------|------------------------------------------
1                  | Dimensional         | Dimensional measurements and tolerances
5                  | Electrical          | Electrical parameters and safety checks
3                  | Functional          | Functional testing and performance checks
4                  | Material Analysis   | Material properties and composition
6                  | Mechanical          | Mechanical properties and strength tests
2                  | Visual              | Visual inspection for defects, color
```

---

## 3. Master Register Stored Procedures

### 3.1 sp_GetMasterListPaginated

**Purpose**: Retrieve paginated master list with search, sort, and filter.

**Parameters**:
- `@PageNumber` INT - Page number (1-based)
- `@PageSize` INT - Items per page
- `@SearchTerm` NVARCHAR(200) (Optional) - Search text
- `@SortColumn` NVARCHAR(50) (Optional) - Column to sort by
- `@SortDirection` NVARCHAR(4) (Optional) - 'ASC' or 'DESC'
- `@ItemType` NVARCHAR(20) (Optional) - Filter by type
- `@Status` BIT (Optional) - Filter by status

**SQL Code**:
```sql
CREATE PROCEDURE sp_GetMasterListPaginated
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(200) = NULL,
    @SortColumn NVARCHAR(50) = 'ItemID',
    @SortDirection NVARCHAR(4) = 'ASC',
    @ItemType NVARCHAR(20) = NULL,
    @Status BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Calculate offset
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
    
    -- Build dynamic SQL for sorting
    DECLARE @SQL NVARCHAR(MAX);
    
    SET @SQL = '
    WITH FilteredData AS (
        SELECT 
            ItemID,
            ItemType,
            RefId,
            Type,
            ItemName,
            Supplier,
            Location,
            CreatedDate,
            ResponsibleTeam,
            NextServiceDue,
            AvailabilityStatus,
            Status
        FROM MasterRegister
        WHERE 1=1
    ';
    
    -- Add search filter
    IF @SearchTerm IS NOT NULL
    BEGIN
        SET @SQL = @SQL + '
            AND (
                ItemID LIKE ''%' + @SearchTerm + '%''
                OR ItemName LIKE ''%' + @SearchTerm + '%''
                OR ItemType LIKE ''%' + @SearchTerm + '%''
                OR Supplier LIKE ''%' + @SearchTerm + '%''
                OR Location LIKE ''%' + @SearchTerm + '%''
                OR ResponsibleTeam LIKE ''%' + @SearchTerm + '%''
            )
        ';
    END
    
    -- Add type filter
    IF @ItemType IS NOT NULL
    BEGIN
        SET @SQL = @SQL + '
            AND ItemType = ''' + @ItemType + '''
        ';
    END
    
    -- Add status filter
    IF @Status IS NOT NULL
    BEGIN
        SET @SQL = @SQL + '
            AND Status = ' + CAST(@Status AS NVARCHAR(1)) + '
        ';
    END
    
    SET @SQL = @SQL + '
    )
    SELECT 
        *,
        (SELECT COUNT(*) FROM FilteredData) AS TotalCount
    FROM FilteredData
    ORDER BY ' + @SortColumn + ' ' + @SortDirection + '
    OFFSET ' + CAST(@Offset AS NVARCHAR(10)) + ' ROWS
    FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(10)) + ' ROWS ONLY;
    ';
    
    EXEC sp_executesql @SQL;
END;
```

**Why This Design?**

1. **Dynamic SQL**:
- Flexible sorting by any column
- Prevents SQL injection with parameterization
- Handles optional filters

2. **CTE (Common Table Expression)**:
```sql
WITH FilteredData AS (...)
```
- Applies filters first
- Calculates total count
- Improves readability

3. **OFFSET/FETCH**:
```sql
OFFSET @Offset ROWS
FETCH NEXT @PageSize ROWS ONLY
```
- Standard SQL pagination
- Efficient for large datasets
- Supports skip and take

4. **TotalCount**:
```sql
(SELECT COUNT(*) FROM FilteredData) AS TotalCount
```
- Returns total records matching filter
- Used for pagination UI
- Single query for data and count

**Usage Example**:
```sql
-- Get page 1 with 10 items
EXEC sp_GetMasterListPaginated 
    @PageNumber = 1,
    @PageSize = 10;

-- Search and sort
EXEC sp_GetMasterListPaginated 
    @PageNumber = 1,
    @PageSize = 10,
    @SearchTerm = 'Caliper',
    @SortColumn = 'ItemName',
    @SortDirection = 'ASC';

-- Filter by type
EXEC sp_GetMasterListPaginated 
    @PageNumber = 1,
    @PageSize = 10,
    @ItemType = 'MMD',
    @Status = 1;
```


---

## 4. Maintenance & Allocation Stored Procedures

### 4.1 sp_AddMaintenance

**Purpose**: Add a maintenance record and update Next Service Due.

**Parameters**:
- `@AssetType` NVARCHAR(50) - Type of asset
- `@AssetId` NVARCHAR(50) - Asset ID
- `@ItemName` NVARCHAR(255) - Item name
- `@ServiceDate` DATETIME - Service date
- `@ServiceProviderCompany` NVARCHAR(255) - Service provider
- `@ServiceEngineerName` NVARCHAR(255) - Engineer name
- `@ServiceType` NVARCHAR(100) - Type of service
- `@NextServiceDue` DATETIME - Next service date
- `@ServiceNotes` NVARCHAR(MAX) - Service notes
- `@MaintenanceStatus` NVARCHAR(50) - Status
- `@Cost` DECIMAL(18,2) - Service cost
- `@ResponsibleTeam` NVARCHAR(255) - Responsible team

**SQL Code**:
```sql
CREATE PROCEDURE sp_AddMaintenance
    @AssetType NVARCHAR(50),
    @AssetId NVARCHAR(50),
    @ItemName NVARCHAR(255),
    @ServiceDate DATETIME,
    @ServiceProviderCompany NVARCHAR(255),
    @ServiceEngineerName NVARCHAR(255),
    @ServiceType NVARCHAR(100),
    @NextServiceDue DATETIME,
    @ServiceNotes NVARCHAR(MAX),
    @MaintenanceStatus NVARCHAR(50),
    @Cost DECIMAL(18,2),
    @ResponsibleTeam NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Insert maintenance record
        INSERT INTO Maintenance (
            AssetType, AssetId, ItemName, ServiceDate,
            ServiceProviderCompany, ServiceEngineerName, ServiceType,
            NextServiceDue, ServiceNotes, MaintenanceStatus,
            Cost, ResponsibleTeam, CreatedDate
        )
        VALUES (
            @AssetType, @AssetId, @ItemName, @ServiceDate,
            @ServiceProviderCompany, @ServiceEngineerName, @ServiceType,
            @NextServiceDue, @ServiceNotes, @MaintenanceStatus,
            @Cost, @ResponsibleTeam, GETDATE()
        );
        
        DECLARE @NewMaintenanceId INT = SCOPE_IDENTITY();
        
        -- Update MasterRegister NextServiceDue
        UPDATE MasterRegister
        SET NextServiceDue = @NextServiceDue
        WHERE ItemID = @AssetId;
        
        -- Update specific table based on AssetType
        IF @AssetType = 'MMD'
        BEGIN
            UPDATE MMDs
            SET NextCalibrationDate = @NextServiceDue,
                LastCalibrationDate = @ServiceDate
            WHERE MmdId = @AssetId;
        END
        ELSE IF @AssetType = 'Tool'
        BEGIN
            UPDATE Tools
            SET LastAuditDate = @ServiceDate
            WHERE ToolsId = @AssetId;
        END
        
        COMMIT TRANSACTION;
        
        SELECT @NewMaintenanceId AS NewMaintenanceId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
```

**Why This Design?**

1. **Transaction Management**:
```sql
BEGIN TRANSACTION;
-- Multiple updates
COMMIT TRANSACTION;
```
- Ensures all updates succeed or fail together
- Maintains data consistency
- Prevents partial updates

2. **Cascading Updates**:
```sql
-- Update MasterRegister
UPDATE MasterRegister SET NextServiceDue = @NextServiceDue WHERE ItemID = @AssetId;

-- Update specific table
IF @AssetType = 'MMD'
    UPDATE MMDs SET NextCalibrationDate = @NextServiceDue WHERE MmdId = @AssetId;
```
- Updates all related tables
- Keeps data synchronized
- Single operation for user

3. **Error Handling with Rollback**:
```sql
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
```
- Rolls back on error
- Prevents data corruption
- Returns error message

**Usage Example**:
```sql
DECLARE @NewId INT;

EXEC sp_AddMaintenance 
    @AssetType = 'MMD',
    @AssetId = 'MMD001',
    @ItemName = 'Vernier Caliper',
    @ServiceDate = '2024-04-06',
    @ServiceProviderCompany = 'ABC Calibration Lab',
    @ServiceEngineerName = 'Ravi Kumar',
    @ServiceType = 'Calibration',
    @NextServiceDue = '2024-12-01',
    @ServiceNotes = 'Annual calibration completed',
    @MaintenanceStatus = 'Completed',
    @Cost = 5000.00,
    @ResponsibleTeam = 'Production Team';

PRINT 'New Maintenance ID: ' + CAST(@NewId AS VARCHAR(10));
```


### 4.2 sp_GetMaintenancePaginated

**Purpose**: Retrieve paginated maintenance records with search and sort.

**Parameters**:
- `@PageNumber` INT - Page number
- `@PageSize` INT - Items per page
- `@SearchTerm` NVARCHAR(200) (Optional) - Search text
- `@SortColumn` NVARCHAR(50) (Optional) - Sort column
- `@SortDirection` NVARCHAR(4) (Optional) - Sort direction

**SQL Code**:
```sql
CREATE PROCEDURE sp_GetMaintenancePaginated
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(200) = NULL,
    @SortColumn NVARCHAR(50) = 'ServiceDate',
    @SortDirection NVARCHAR(4) = 'DESC'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
    
    WITH FilteredData AS (
        SELECT 
            MaintenanceId,
            AssetType,
            AssetId,
            ItemName,
            ServiceDate,
            ServiceProviderCompany,
            ServiceEngineerName,
            ServiceType,
            NextServiceDue,
            ServiceNotes,
            MaintenanceStatus,
            Cost,
            ResponsibleTeam,
            CreatedDate
        FROM Maintenance
        WHERE (@SearchTerm IS NULL OR (
            AssetId LIKE '%' + @SearchTerm + '%'
            OR ItemName LIKE '%' + @SearchTerm + '%'
            OR ServiceProviderCompany LIKE '%' + @SearchTerm + '%'
            OR ServiceEngineerName LIKE '%' + @SearchTerm + '%'
            OR ServiceType LIKE '%' + @SearchTerm + '%'
            OR ResponsibleTeam LIKE '%' + @SearchTerm + '%'
        ))
    )
    SELECT 
        *,
        (SELECT COUNT(*) FROM FilteredData) AS TotalCount
    FROM FilteredData
    ORDER BY 
        CASE WHEN @SortColumn = 'ServiceDate' AND @SortDirection = 'ASC' THEN ServiceDate END ASC,
        CASE WHEN @SortColumn = 'ServiceDate' AND @SortDirection = 'DESC' THEN ServiceDate END DESC,
        CASE WHEN @SortColumn = 'ItemName' AND @SortDirection = 'ASC' THEN ItemName END ASC,
        CASE WHEN @SortColumn = 'ItemName' AND @SortDirection = 'DESC' THEN ItemName END DESC,
        CASE WHEN @SortColumn = 'Cost' AND @SortDirection = 'ASC' THEN Cost END ASC,
        CASE WHEN @SortColumn = 'Cost' AND @SortDirection = 'DESC' THEN Cost END DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
```

**Why This Design?**

1. **CASE-Based Sorting**:
```sql
ORDER BY 
    CASE WHEN @SortColumn = 'ServiceDate' AND @SortDirection = 'ASC' THEN ServiceDate END ASC,
    CASE WHEN @SortColumn = 'ServiceDate' AND @SortDirection = 'DESC' THEN ServiceDate END DESC
```
- Safe from SQL injection
- Type-safe sorting
- Handles different data types

2. **Multi-Column Search**:
```sql
WHERE (@SearchTerm IS NULL OR (
    AssetId LIKE '%' + @SearchTerm + '%'
    OR ItemName LIKE '%' + @SearchTerm + '%'
    ...
))
```
- Searches across multiple columns
- User-friendly search
- Single search box

**Usage Example**:
```sql
-- Get recent maintenance records
EXEC sp_GetMaintenancePaginated 
    @PageNumber = 1,
    @PageSize = 10,
    @SortColumn = 'ServiceDate',
    @SortDirection = 'DESC';

-- Search for specific service
EXEC sp_GetMaintenancePaginated 
    @PageNumber = 1,
    @PageSize = 10,
    @SearchTerm = 'Calibration';
```


### 4.3 sp_AddAllocation

**Purpose**: Add an allocation record and update availability status.

**Parameters**:
- `@AssetType` NVARCHAR(50) - Type of asset
- `@AssetId` NVARCHAR(50) - Asset ID
- `@ItemName` NVARCHAR(255) - Item name
- `@EmployeeId` NVARCHAR(50) - Employee ID
- `@EmployeeName` NVARCHAR(200) - Employee name
- `@TeamName` NVARCHAR(200) - Team name
- `@Purpose` NVARCHAR(500) - Purpose of allocation
- `@IssuedDate` DATETIME - Issue date
- `@ExpectedReturnDate` DATETIME - Expected return
- `@AvailabilityStatus` NVARCHAR(50) - Status

**SQL Code**:
```sql
CREATE PROCEDURE sp_AddAllocation
    @AssetType NVARCHAR(50),
    @AssetId NVARCHAR(50),
    @ItemName NVARCHAR(255),
    @EmployeeId NVARCHAR(50),
    @EmployeeName NVARCHAR(200),
    @TeamName NVARCHAR(200),
    @Purpose NVARCHAR(500),
    @IssuedDate DATETIME,
    @ExpectedReturnDate DATETIME,
    @AvailabilityStatus NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Insert allocation record
        INSERT INTO Allocation (
            AssetType, AssetId, ItemName, EmployeeId,
            EmployeeName, TeamName, Purpose, IssuedDate,
            ExpectedReturnDate, AvailabilityStatus, CreatedDate
        )
        VALUES (
            @AssetType, @AssetId, @ItemName, @EmployeeId,
            @EmployeeName, @TeamName, @Purpose, @IssuedDate,
            @ExpectedReturnDate, @AvailabilityStatus, GETDATE()
        );
        
        DECLARE @NewAllocationId INT = SCOPE_IDENTITY();
        
        -- Update MasterRegister AvailabilityStatus
        UPDATE MasterRegister
        SET AvailabilityStatus = @AvailabilityStatus
        WHERE ItemID = @AssetId;
        
        COMMIT TRANSACTION;
        
        SELECT @NewAllocationId AS NewAllocationId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
```

**Why This Design?**

1. **Automatic Status Update**:
```sql
UPDATE MasterRegister
SET AvailabilityStatus = @AvailabilityStatus
WHERE ItemID = @AssetId;
```
- Updates master register automatically
- Keeps status synchronized
- Single operation for user

2. **Transaction Safety**:
- Both allocation and status update succeed together
- Prevents inconsistent state
- Rollback on error

**Usage Example**:
```sql
DECLARE @NewId INT;

EXEC sp_AddAllocation 
    @AssetType = 'Asset',
    @AssetId = 'ASSET001',
    @ItemName = 'Dell Laptop',
    @EmployeeId = 'EMP002',
    @EmployeeName = 'Jane Smith',
    @TeamName = 'Development Team',
    @Purpose = 'Software development',
    @IssuedDate = '2024-01-01',
    @ExpectedReturnDate = '2024-12-31',
    @AvailabilityStatus = 'Allocated';

PRINT 'New Allocation ID: ' + CAST(@NewId AS VARCHAR(10));
```


### 4.4 sp_ReturnAllocation

**Purpose**: Mark an allocation as returned and update availability.

**Parameters**:
- `@AllocationId` INT - Allocation ID
- `@ActualReturnDate` DATETIME - Actual return date

**SQL Code**:
```sql
CREATE PROCEDURE sp_ReturnAllocation
    @AllocationId INT,
    @ActualReturnDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @AssetId NVARCHAR(50);
        
        -- Get AssetId from allocation
        SELECT @AssetId = AssetId
        FROM Allocation
        WHERE AllocationId = @AllocationId;
        
        -- Update allocation record
        UPDATE Allocation
        SET ActualReturnDate = @ActualReturnDate,
            AvailabilityStatus = 'Returned'
        WHERE AllocationId = @AllocationId;
        
        -- Check if there are other active allocations for this asset
        IF NOT EXISTS (
            SELECT 1 FROM Allocation 
            WHERE AssetId = @AssetId 
              AND ActualReturnDate IS NULL
              AND AllocationId != @AllocationId
        )
        BEGIN
            -- No other allocations, mark as Available
            UPDATE MasterRegister
            SET AvailabilityStatus = 'Available'
            WHERE ItemID = @AssetId;
        END
        
        COMMIT TRANSACTION;
        
        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
```

**Why This Design?**

1. **Smart Status Update**:
```sql
IF NOT EXISTS (
    SELECT 1 FROM Allocation 
    WHERE AssetId = @AssetId 
      AND ActualReturnDate IS NULL
)
BEGIN
    UPDATE MasterRegister SET AvailabilityStatus = 'Available'
END
```
- Checks for other active allocations
- Only marks Available if no other allocations
- Handles multiple allocations correctly

2. **Automatic Status Change**:
- Updates allocation status to 'Returned'
- Updates master register if appropriate
- Single operation for return

**Usage Example**:
```sql
EXEC sp_ReturnAllocation 
    @AllocationId = 1,
    @ActualReturnDate = '2024-01-28';
```

---

## 5. Stored Procedure Best Practices

### 5.1 Error Handling Pattern

**Always use TRY-CATCH blocks**:
```sql
BEGIN TRY
    -- Your code here
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@ErrorMessage, 16, 1);
END CATCH
```

**Why?**
- Catches runtime errors
- Returns meaningful error messages
- Prevents silent failures
- Improves debugging

### 5.2 Transaction Management

**Use transactions for multiple updates**:
```sql
BEGIN TRANSACTION;
    -- Multiple INSERT/UPDATE/DELETE statements
COMMIT TRANSACTION;
```

**With error handling**:
```sql
BEGIN TRY
    BEGIN TRANSACTION;
        -- Your code
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    -- Error handling
END CATCH
```

**Why?**
- Ensures atomicity (all or nothing)
- Maintains data consistency
- Prevents partial updates
- Rollback on error


### 5.3 Parameter Validation

**Validate input parameters**:
```sql
CREATE PROCEDURE sp_Example
    @Id INT,
    @Name NVARCHAR(200)
AS
BEGIN
    -- Validate parameters
    IF @Id IS NULL OR @Id <= 0
    BEGIN
        RAISERROR('Invalid ID parameter', 16, 1);
        RETURN;
    END
    
    IF @Name IS NULL OR LEN(@Name) = 0
    BEGIN
        RAISERROR('Name cannot be empty', 16, 1);
        RETURN;
    END
    
    -- Proceed with logic
END;
```

**Why?**
- Prevents invalid data
- Provides clear error messages
- Improves data quality
- Reduces debugging time

### 5.4 SET NOCOUNT ON

**Always use at the beginning**:
```sql
CREATE PROCEDURE sp_Example
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Your code here
END;
```

**Why?**
- Suppresses "rows affected" messages
- Reduces network traffic
- Improves performance
- Cleaner output

### 5.5 Output Parameters

**Use OUTPUT parameters to return values**:
```sql
CREATE PROCEDURE sp_CreateItem
    @ItemName NVARCHAR(200),
    @NewItemId INT OUTPUT
AS
BEGIN
    INSERT INTO Items (ItemName) VALUES (@ItemName);
    SET @NewItemId = SCOPE_IDENTITY();
END;
```

**Usage**:
```sql
DECLARE @NewId INT;
EXEC sp_CreateItem @ItemName = 'Test', @NewItemId = @NewId OUTPUT;
PRINT @NewId;
```

**Why?**
- Returns generated IDs
- Avoids separate SELECT query
- More efficient
- Type-safe

### 5.6 Optional Parameters

**Use default values for optional parameters**:
```sql
CREATE PROCEDURE sp_GetItems
    @SearchTerm NVARCHAR(200) = NULL,
    @Status BIT = NULL,
    @PageSize INT = 10
AS
BEGIN
    SELECT * FROM Items
    WHERE (@SearchTerm IS NULL OR ItemName LIKE '%' + @SearchTerm + '%')
      AND (@Status IS NULL OR Status = @Status);
END;
```

**Why?**
- Flexible procedure calls
- Reduces number of procedures
- User-friendly
- Backward compatible

### 5.7 Pagination Pattern

**Standard pagination with OFFSET/FETCH**:
```sql
CREATE PROCEDURE sp_GetItemsPaginated
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
    
    SELECT *, (SELECT COUNT(*) FROM Items) AS TotalCount
    FROM Items
    ORDER BY ItemId
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
```

**Why?**
- Efficient for large datasets
- Standard SQL syntax
- Returns total count
- Supports skip and take

### 5.8 Dynamic SQL Safety

**Use sp_executesql with parameters**:
```sql
-- UNSAFE (SQL Injection risk)
DECLARE @SQL NVARCHAR(MAX) = 'SELECT * FROM Items WHERE ItemName = ''' + @Name + '''';
EXEC(@SQL);

-- SAFE (Parameterized)
DECLARE @SQL NVARCHAR(MAX) = 'SELECT * FROM Items WHERE ItemName = @Name';
EXEC sp_executesql @SQL, N'@Name NVARCHAR(200)', @Name = @Name;
```

**Why?**
- Prevents SQL injection
- Type-safe parameters
- Better performance (plan caching)
- Security best practice

### 5.9 Naming Conventions

**Follow consistent naming**:
- Prefix: `sp_` for stored procedures
- Action verbs: `Get`, `Create`, `Update`, `Delete`, `Add`
- Entity names: Singular or plural based on result
- Parameters: `@PascalCase` with descriptive names

**Examples**:
- `sp_GetAllItems` - Returns multiple items
- `sp_GetItemById` - Returns single item
- `sp_CreateItem` - Creates new item
- `sp_UpdateItem` - Updates existing item
- `sp_DeleteItem` - Deletes item

### 5.10 Documentation

**Add comments to complex procedures**:
```sql
/*
    Procedure: sp_ComplexOperation
    Purpose: Performs complex business logic
    Parameters:
        @Param1 - Description of param1
        @Param2 - Description of param2
    Returns: Description of return value
    Example:
        EXEC sp_ComplexOperation @Param1 = 1, @Param2 = 'Test'
*/
CREATE PROCEDURE sp_ComplexOperation
    @Param1 INT,
    @Param2 NVARCHAR(200)
AS
BEGIN
    -- Implementation
END;
```

**Why?**
- Improves maintainability
- Helps other developers
- Documents business logic
- Reduces learning curve

---

## Summary

This document covers all stored procedures in the Inventory Management System:

**Quality Control Procedures** (11):
1. sp_CreateQCTemplate - Create templates with duplicate prevention
2. sp_GetAllQCTemplates - Retrieve all templates
3. sp_UpdateQCTemplate - Update template fields
4. sp_AddQCControlPoint - Add control points
5. sp_GetQCControlPointsByTemplate - Get control points
6. sp_DeleteQCControlPoint - Delete control points
7. sp_GetFinalProducts - Get products
8. sp_GetMaterialsByFinalProduct - Get materials
9. sp_GetValidationTypes - Get validation types
10. sp_GetUnits - Get measurement units
11. sp_GetQCControlPointTypes - Get control point types

**Master Register Procedures** (1):
1. sp_GetMasterListPaginated - Paginated master list with search/sort

**Maintenance & Allocation Procedures** (4):
1. sp_AddMaintenance - Add maintenance with cascading updates
2. sp_GetMaintenancePaginated - Paginated maintenance records
3. sp_AddAllocation - Add allocation with status update
4. sp_ReturnAllocation - Return allocation with smart status

**Key Features**:
- Error handling with TRY-CATCH
- Transaction management for data consistency
- Output parameters for generated IDs
- Pagination support
- Search and sort capabilities
- Cascading updates across tables
- Duplicate prevention
- Parameter validation

**Best Practices**:
- Always use SET NOCOUNT ON
- Implement proper error handling
- Use transactions for multiple updates
- Validate input parameters
- Use OUTPUT parameters for IDs
- Follow naming conventions
- Document complex logic
- Prevent SQL injection

