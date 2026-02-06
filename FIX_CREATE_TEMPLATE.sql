-- =============================================
-- Fix: Create QC Template Functionality
-- =============================================
-- This script creates the missing stored procedure and table (if needed)
-- Run this in SQL Server Management Studio on the ManufacturingApp database
-- =============================================

USE ManufacturingApp;
GO

-- Step 1: Check if QCTemplate table exists, if not create it
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
    
    PRINT 'QCTemplate table created successfully.';
END
ELSE
BEGIN
    PRINT 'QCTemplate table already exists.';
END
GO

-- Step 2: Drop existing stored procedure if it exists
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateQCTemplate')
BEGIN
    PRINT 'Dropping existing sp_CreateQCTemplate...';
    DROP PROCEDURE sp_CreateQCTemplate;
END
GO

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
        BEGIN TRANSACTION;
        
        -- Insert the new template
        INSERT INTO QCTemplate (TemplateName, ValidationTypeId, FinalProductId, CreatedDate, UpdatedDate)
        VALUES (@TemplateName, @ValidationTypeId, @FinalProductId, GETDATE(), GETDATE());
        
        -- Get the newly created template ID
        SET @NewTemplateId = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        -- Return the new ID
        SELECT @NewTemplateId AS NewTemplateId;
        
        PRINT 'Template created successfully with ID: ' + CAST(@NewTemplateId AS NVARCHAR(10));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

PRINT 'sp_CreateQCTemplate stored procedure created successfully.';
GO

-- Step 4: Test the stored procedure
PRINT 'Testing the stored procedure...';
GO

DECLARE @NewId INT;
EXEC sp_CreateQCTemplate 
    @TemplateName = 'Test Template - Installation Test',
    @ValidationTypeId = 1,
    @FinalProductId = 3,
    @NewTemplateId = @NewId OUTPUT;

PRINT 'Test completed. New Template ID: ' + CAST(@NewId AS NVARCHAR(10));

-- Verify it was created
SELECT * FROM QCTemplate WHERE QCTemplateId = @NewId;
GO

PRINT '';
PRINT '=============================================';
PRINT 'Installation Complete!';
PRINT 'You can now use the Add New Template feature.';
PRINT '=============================================';
