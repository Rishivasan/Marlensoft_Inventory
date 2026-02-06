-- Create stored procedure for creating QC templates

USE ManufacturingApp;
GO

-- Drop if exists
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateQCTemplate')
    DROP PROCEDURE sp_CreateQCTemplate;
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
        INSERT INTO QCTemplate (TemplateName, ValidationTypeId, FinalProductId)
        VALUES (@TemplateName, @ValidationTypeId, @FinalProductId);
        
        -- Get the newly created template ID
        SET @NewTemplateId = SCOPE_IDENTITY();
        
        -- Return success
        SELECT @NewTemplateId AS NewTemplateId;
    END TRY
    BEGIN CATCH
        -- Return error
        THROW;
    END CATCH
END;
GO

-- Test the stored procedure
DECLARE @NewId INT;
EXEC sp_CreateQCTemplate 
    @TemplateName = 'Test Template',
    @ValidationTypeId = 1,
    @FinalProductId = 3,
    @NewTemplateId = @NewId OUTPUT;

SELECT @NewId AS CreatedTemplateId;

-- Verify it was created
SELECT * FROM QCTemplate WHERE QCTemplateId = @NewId;
GO
