-- ============================================
-- Add Tools Field to QCTemplate Table
-- ============================================
-- This script adds the "ToolsToQualityCheck" field to store tools information per template
-- ============================================

USE ManufacturingApp;
GO

PRINT '========================================';
PRINT 'Adding Tools Field to QCTemplate';
PRINT '========================================';
PRINT '';

-- Step 1: Add ToolsToQualityCheck column if it doesn't exist
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[QCTemplate]') 
    AND name = 'ToolsToQualityCheck'
)
BEGIN
    PRINT 'Adding ToolsToQualityCheck column...';
    
    ALTER TABLE [dbo].[QCTemplate]
    ADD [ToolsToQualityCheck] NVARCHAR(500) NULL;
    
    PRINT '✓ ToolsToQualityCheck column added successfully!';
END
ELSE
BEGIN
    PRINT '✓ ToolsToQualityCheck column already exists.';
END
GO

PRINT '';

-- Step 2: Update sp_CreateQCTemplate to include Tools parameter
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateQCTemplate')
BEGIN
    PRINT 'Updating sp_CreateQCTemplate stored procedure...';
    DROP PROCEDURE sp_CreateQCTemplate;
END
GO

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
        -- Insert the new template
        INSERT INTO QCTemplate (
            TemplateName, 
            ValidationTypeId, 
            FinalProductId, 
            MaterialId,
            ToolsToQualityCheck,
            CreatedAt
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
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

PRINT '✓ sp_CreateQCTemplate updated successfully!';
PRINT '';

-- Step 3: Update sp_GetAllQCTemplates to include Tools field
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllQCTemplates')
BEGIN
    PRINT 'Updating sp_GetAllQCTemplates stored procedure...';
    DROP PROCEDURE sp_GetAllQCTemplates;
END
GO

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
        t.CreatedAt
    FROM QCTemplate t
    LEFT JOIN FinalProduct fp ON t.FinalProductId = fp.FinalProductId
    ORDER BY t.CreatedAt DESC;
END;
GO

PRINT '✓ sp_GetAllQCTemplates updated successfully!';
PRINT '';

-- Step 4: Create sp_UpdateQCTemplate for updating templates
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateQCTemplate')
BEGIN
    DROP PROCEDURE sp_UpdateQCTemplate;
END
GO

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
            ToolsToQualityCheck = ISNULL(@ToolsToQualityCheck, ToolsToQualityCheck)
        WHERE QCTemplateId = @QCTemplateId;
        
        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

PRINT '✓ sp_UpdateQCTemplate created successfully!';
PRINT '';

-- Step 5: Verify the changes
PRINT 'Verifying table structure...';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'QCTemplate'
ORDER BY ORDINAL_POSITION;

PRINT '';
PRINT '========================================';
PRINT '✓✓✓ TOOLS FIELD ADDED SUCCESSFULLY! ✓✓✓';
PRINT '========================================';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Update the backend C# code to include ToolsToQualityCheck';
PRINT '2. Update the frontend to save and load tools data';
PRINT '3. Restart your application';
PRINT '';
PRINT '========================================';
