-- Add MaterialId to QCTemplate table and update stored procedures
-- This allows templates to remember which material was selected

PRINT '========================================';
PRINT 'Adding MaterialId to QCTemplate';
PRINT '========================================';
PRINT '';

-- Step 1: Add MaterialId column if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[QCTemplate]') AND name = 'MaterialId')
BEGIN
    PRINT 'Adding MaterialId column to QCTemplate table...';
    ALTER TABLE [dbo].[QCTemplate]
    ADD [MaterialId] [int] NULL;
    PRINT '✓ MaterialId column added successfully!';
END
ELSE
BEGIN
    PRINT '✓ MaterialId column already exists.';
END
GO

PRINT '';

-- Step 2: Drop and recreate sp_CreateQCTemplate with MaterialId
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateQCTemplate')
BEGIN
    PRINT 'Dropping existing sp_CreateQCTemplate...';
    DROP PROCEDURE sp_CreateQCTemplate;
    PRINT '✓ Dropped successfully.';
END
GO

PRINT 'Creating updated sp_CreateQCTemplate...';
GO

CREATE PROCEDURE sp_CreateQCTemplate
    @TemplateName NVARCHAR(255),
    @ValidationTypeId INT,
    @FinalProductId INT,
    @MaterialId INT = NULL,
    @ProductName NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NewId INT;
    
    INSERT INTO QCTemplate (TemplateName, ValidationTypeId, FinalProductId, MaterialId)
    VALUES (@TemplateName, @ValidationTypeId, @FinalProductId, @MaterialId);
    
    SET @NewId = SCOPE_IDENTITY();
    
    SELECT @NewId AS TemplateId;
END
GO

PRINT '✓ sp_CreateQCTemplate created successfully!';
PRINT '';

-- Step 3: Drop and recreate sp_GetAllQCTemplates to include MaterialId
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllQCTemplates')
BEGIN
    PRINT 'Dropping existing sp_GetAllQCTemplates...';
    DROP PROCEDURE sp_GetAllQCTemplates;
    PRINT '✓ Dropped successfully.';
END
GO

PRINT 'Creating updated sp_GetAllQCTemplates...';
GO

CREATE PROCEDURE sp_GetAllQCTemplates
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        QCTemplateId,
        TemplateName,
        ValidationTypeId,
        FinalProductId,
        MaterialId
    FROM QCTemplate
    ORDER BY QCTemplateId DESC;
END
GO

PRINT '✓ sp_GetAllQCTemplates created successfully!';
PRINT '';

-- Step 4: Test the updated stored procedure
PRINT '========================================';
PRINT 'Testing Updated Stored Procedures';
PRINT '========================================';
PRINT '';

DECLARE @TestId INT;
PRINT 'Creating test template with MaterialId...';
EXEC sp_CreateQCTemplate 
    @TemplateName = 'IG - Test Product - MSI-999 - Test Material',
    @ValidationTypeId = 1,
    @FinalProductId = 1,
    @MaterialId = 1,
    @ProductName = 'Test Product';

PRINT '';
PRINT 'Retrieving all templates...';
EXEC sp_GetAllQCTemplates;

PRINT '';
PRINT '========================================';
PRINT 'Migration Complete!';
PRINT '========================================';
PRINT '';
PRINT 'Summary:';
PRINT '✓ MaterialId column added to QCTemplate table';
PRINT '✓ sp_CreateQCTemplate updated to accept MaterialId';
PRINT '✓ sp_GetAllQCTemplates updated to return MaterialId';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Update backend C# code to include MaterialId';
PRINT '2. Update frontend to send and receive MaterialId';
PRINT '3. Test template creation and retrieval';
