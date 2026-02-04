-- Drop existing sp_GetUnits procedure
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUnits')
    DROP PROCEDURE sp_GetUnits;

GO

-- Create updated stored procedure to get Units from UnitMaster table
CREATE PROCEDURE sp_GetUnits
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Return units from UnitMaster table
    SELECT 
        UnitId,
        UnitName
    FROM UnitMaster
    ORDER BY UnitName;
END;

GO

PRINT 'sp_GetUnits procedure updated to use UnitMaster table!';