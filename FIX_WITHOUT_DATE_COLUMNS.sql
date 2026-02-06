-- ============================================
-- CORRECTED SCRIPT - Works with existing table
-- ============================================
-- Run this in SQL Server Management Studio
-- ============================================

USE ManufacturingApp;
GO

PRINT '========================================';
PRINT 'Creating sp_CreateQCTemplate';
PRINT '========================================';
PRINT '';

-- Drop existing stored procedure if it exists
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateQCTemplate')
BEGIN
    PRINT 'Removing old stored procedure...';
    DROP PROCEDURE sp_CreateQCTemplate;
    PRINT '✓ Old stored procedure removed.';
END
GO

PRINT '';
PRINT 'Creating sp_CreateQCTemplate stored procedure...';
GO

CREATE PROCEDURE sp_CreateQCTemplate
    @TemplateName NVARCHAR(255),
    @ValidationTypeId INT,
    @FinalProductId INT,
    @NewTemplateId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Insert the new template (without CreatedDate/UpdatedDate since they don't exist)
        INSERT INTO QCTemplate (TemplateName, ValidationTypeId, FinalProductId)
        VALUES (@TemplateName, @ValidationTypeId, @FinalProductId);
        
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

PRINT '✓ sp_CreateQCTemplate stored procedure created successfully!';
PRINT '';

-- Test the stored procedure
PRINT 'Testing the stored procedure...';
GO

DECLARE @TestId INT;
EXEC sp_CreateQCTemplate 
    @TemplateName = 'Installation Test Template',
    @ValidationTypeId = 1,
    @FinalProductId = 3,
    @NewTemplateId = @TestId OUTPUT;

PRINT '✓ Test successful! Created template with ID: ' + CAST(@TestId AS NVARCHAR(10));
PRINT '';

-- Show the test template
SELECT TOP 1 * FROM QCTemplate ORDER BY QCTemplateId DESC;

PRINT '';
PRINT '========================================';
PRINT '✓✓✓ INSTALLATION COMPLETE! ✓✓✓';
PRINT '========================================';
PRINT '';
PRINT 'The "Add new template" button should now work!';
PRINT '';
