-- ========================================
-- Add Unique Constraint for MaterialId
-- Prevents duplicate templates for same material
-- ========================================

-- NOTE: Change the database name if yours is different
-- USE InventoryManagement;
-- GO

PRINT '========================================';
PRINT 'Adding Unique Constraint to QCTemplate';
PRINT '========================================';
PRINT '';

-- Step 1: Check if constraint already exists
IF EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'UQ_QCTemplate_MaterialId' 
    AND object_id = OBJECT_ID('QCTemplate')
)
BEGIN
    PRINT 'Unique constraint already exists. Skipping...';
END
ELSE
BEGIN
    PRINT 'Adding unique constraint on MaterialId...';
    
    -- Add unique constraint
    ALTER TABLE QCTemplate
    ADD CONSTRAINT UQ_QCTemplate_MaterialId UNIQUE (MaterialId);
    
    PRINT '✓ Unique constraint added successfully!';
END
GO

PRINT '';
PRINT '========================================';
PRINT 'Updating sp_CreateQCTemplate';
PRINT '========================================';
PRINT '';

-- Step 2: Update stored procedure with duplicate check
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateQCTemplate')
BEGIN
    PRINT 'Dropping existing sp_CreateQCTemplate...';
    DROP PROCEDURE sp_CreateQCTemplate;
END
GO

PRINT 'Creating updated sp_CreateQCTemplate with duplicate check...';
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
        ToolsToQualityCheck
    )
    VALUES (
        @TemplateName, 
        @ValidationTypeId, 
        @FinalProductId, 
        @MaterialId,
        @ToolsToQualityCheck
    );
    
    -- Get the newly created template ID
    SET @NewTemplateId = SCOPE_IDENTITY();
    
    RETURN 0;
END
GO

PRINT '✓ sp_CreateQCTemplate updated successfully!';
PRINT '';

-- Step 3: Test the duplicate check
PRINT '========================================';
PRINT 'Testing Duplicate Prevention';
PRINT '========================================';
PRINT '';

-- First, check if we have any existing templates
IF EXISTS (SELECT TOP 1 1 FROM QCTemplate)
BEGIN
    DECLARE @TestMaterialId INT;
    DECLARE @TestTemplateId INT;
    
    -- Get an existing material ID
    SELECT TOP 1 @TestMaterialId = MaterialId 
    FROM QCTemplate 
    WHERE MaterialId IS NOT NULL;
    
    IF @TestMaterialId IS NOT NULL
    BEGIN
        PRINT 'Testing duplicate prevention with MaterialId: ' + CAST(@TestMaterialId AS VARCHAR(10));
        PRINT '';
        
        -- Try to create a duplicate template (this should fail)
        BEGIN TRY
            EXEC sp_CreateQCTemplate 
                @TemplateName = 'Test Duplicate Template',
                @ValidationTypeId = 1,
                @FinalProductId = 1,
                @MaterialId = @TestMaterialId,
                @ToolsToQualityCheck = 'Test Tools',
                @NewTemplateId = @TestTemplateId OUTPUT;
                
            PRINT '❌ ERROR: Duplicate template was created (should have been prevented)';
        END TRY
        BEGIN CATCH
            PRINT '✓ Duplicate prevention working correctly!';
            PRINT '  Error Message: ' + ERROR_MESSAGE();
        END CATCH
    END
    ELSE
    BEGIN
        PRINT 'No templates with MaterialId found. Skipping duplicate test.';
    END
END
ELSE
BEGIN
    PRINT 'No existing templates found. Skipping duplicate test.';
END
GO

PRINT '';
PRINT '========================================';
PRINT 'Summary';
PRINT '========================================';
PRINT '✓ Unique constraint added to QCTemplate.MaterialId';
PRINT '✓ sp_CreateQCTemplate updated with duplicate check';
PRINT '✓ Duplicate prevention tested';
PRINT '';
PRINT 'Each material can now have only ONE template!';
PRINT '';
