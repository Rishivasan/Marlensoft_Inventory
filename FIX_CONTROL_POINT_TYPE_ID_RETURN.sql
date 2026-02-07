-- ========================================
-- Fix: Control Point Type ID Not Returned
-- Ensures ControlPointTypeId is included in API response
-- ========================================

PRINT '========================================';
PRINT 'Checking sp_GetQCControlPointsByTemplate';
PRINT '========================================';
PRINT '';

-- Check if stored procedure exists
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetQCControlPointsByTemplate')
BEGIN
    PRINT 'Stored procedure exists. Updating...';
    DROP PROCEDURE sp_GetQCControlPointsByTemplate;
END
ELSE
BEGIN
    PRINT 'Stored procedure does not exist. Creating...';
END
GO

CREATE PROCEDURE sp_GetQCControlPointsByTemplate
    @QCTemplateId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        QCControlPointId,
        QCTemplateId,
        ControlPointTypeId,  -- IMPORTANT: This must be included!
        ControlPointName,
        TargetValue,
        Unit,
        Tolerance,
        Instructions,
        ImagePath,
        SequenceOrder
    FROM QCControlPoint
    WHERE QCTemplateId = @QCTemplateId
    ORDER BY SequenceOrder;
END
GO

PRINT '✓ sp_GetQCControlPointsByTemplate updated successfully!';
PRINT '';

-- Test the stored procedure
PRINT '========================================';
PRINT 'Testing the Stored Procedure';
PRINT '========================================';
PRINT '';

-- Check if we have any templates
IF EXISTS (SELECT TOP 1 1 FROM QCTemplate)
BEGIN
    DECLARE @TestTemplateId INT;
    
    -- Get the first template ID
    SELECT TOP 1 @TestTemplateId = QCTemplateId FROM QCTemplate;
    
    PRINT 'Testing with Template ID: ' + CAST(@TestTemplateId AS VARCHAR(10));
    PRINT '';
    
    -- Execute the stored procedure
    EXEC sp_GetQCControlPointsByTemplate @QCTemplateId = @TestTemplateId;
    
    PRINT '';
    PRINT 'Check the results above - ControlPointTypeId column should be present!';
END
ELSE
BEGIN
    PRINT 'No templates found. Skipping test.';
END
GO

PRINT '';
PRINT '========================================';
PRINT 'Summary';
PRINT '========================================';
PRINT '✓ sp_GetQCControlPointsByTemplate updated';
PRINT '✓ ControlPointTypeId is now included in results';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Restart your .NET backend';
PRINT '2. Hot reload Flutter app';
PRINT '3. Create a new template with control points';
PRINT '4. Numbers should now show correctly!';
PRINT '';
