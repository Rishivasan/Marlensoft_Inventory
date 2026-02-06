-- ============================================
-- COPY THIS ENTIRE SCRIPT AND RUN IT IN SQL SERVER MANAGEMENT STUDIO
-- ============================================
-- 1. Open SQL Server Management Studio
-- 2. Connect to: RISHIVASAN-PC
-- 3. Select Database: ManufacturingApp
-- 4. Copy this entire script
-- 5. Paste into a new query window
-- 6. Press F5 to execute
-- ============================================

USE ManufacturingApp;
GO

PRINT '========================================';
PRINT 'Creating QC Template Database Objects';
PRINT '========================================';
PRINT '';

-- Step 1: Create QCTemplate table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[QCTemplate]') AND type in (N'U'))
BEGIN
    PRINT 'Creating QCTemplate table...';
    
    CREATE TABLE [dbo].[QCTemplate](
        [QCTemplateId] [int] IDENTITY(1,1) NOT NULL,
        [TemplateName] [nvarchar](255) NOT NULL,
        [ValidationTypeId] [int] NOT NULL,
        [FinalProductId] [int] NOT NULL,
        [CreatedDate] [datetime] NULL DEFAULT (GETDATE()),
        [UpdatedDate] [datetime] NULL DEFAULT (GETDATE()),
        CONSTRAINT [PK_QCTemplate] PRIMARY KEY CLUSTERED ([QCTemplateId] ASC)
    );
    
    PRINT '✓ QCTemplate table created successfully!';
END
ELSE
BEGIN
    PRINT '✓ QCTemplate table already exists.';
END
GO

PRINT '';

-- Step 2: Drop existing stored procedure if it exists
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateQCTemplate')
BEGIN
    PRINT 'Removing old stored procedure...';
    DROP PROCEDURE sp_CreateQCTemplate;
    PRINT '✓ Old stored procedure removed.';
END
GO

PRINT '';

-- Step 3: Create the stored procedure
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
        -- Insert the new template
        INSERT INTO QCTemplate (TemplateName, ValidationTypeId, FinalProductId, CreatedDate, UpdatedDate)
        VALUES (@TemplateName, @ValidationTypeId, @FinalProductId, GETDATE(), GETDATE());
        
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

-- Step 4: Test the stored procedure
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
PRINT 'Next steps:';
PRINT '1. Close this query window';
PRINT '2. Go back to your application';
PRINT '3. Try clicking "Add new template" again';
PRINT '4. It should now work!';
PRINT '';
PRINT '========================================';
