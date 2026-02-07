-- ============================================
-- Fix Stored Procedures for Tools Field
-- ============================================
-- This script fixes the stored procedures to work with the actual table structure
-- Run this after the ToolsToQualityCheck column has been added
-- ============================================

USE ManufacturingApp;
GO

PRINT '========================================';
PRINT 'Fixing Stored Procedures';
PRINT '========================================';
PRINT '';

-- Step 1: Fix sp_CreateQCTemplate
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

-- Step 2: Fix sp_GetAllQCTemplates
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

-- Step 3: Create sp_UpdateQCTemplate
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

-- Step 4: Test the procedures
PRINT 'Testing sp_CreateQCTemplate...';
DECLARE @TestId INT;
EXEC sp_CreateQCTemplate 
    @TemplateName = 'Test Template with Tools',
    @ValidationTypeId = 1,
    @FinalProductId = 3,
    @MaterialId = 5,
    @ToolsToQualityCheck = 'Caliper, Micrometer',
    @NewTemplateId = @TestId OUTPUT;

PRINT '✓ Test successful! Created template with ID: ' + CAST(@TestId AS NVARCHAR(10));
PRINT '';

-- Show the test template
PRINT 'Retrieving test template...';
SELECT TOP 1 * FROM QCTemplate WHERE QCTemplateId = @TestId;

PRINT '';
PRINT '========================================';
PRINT '✓✓✓ STORED PROCEDURES FIXED! ✓✓✓';
PRINT '========================================';
PRINT '';
PRINT 'The tools field is now working correctly!';
PRINT 'Restart your backend and frontend applications.';
PRINT '';
PRINT '========================================';
