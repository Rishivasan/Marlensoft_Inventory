-- Drop existing procedures if they exist
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetQCControlPointTypes')
    DROP PROCEDURE sp_GetQCControlPointTypes;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUnits')
    DROP PROCEDURE sp_GetUnits;

GO

-- Create stored procedure to get QC Control Point Types
CREATE PROCEDURE sp_GetQCControlPointTypes
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ControlPointTypeId,
        TypeName,
        '' AS Description  -- Add empty description since column doesn't exist
    FROM QCControlPointType
    ORDER BY TypeName;
END;

GO

-- Create stored procedure to get Units
CREATE PROCEDURE sp_GetUnits
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Return common units used in quality control
    SELECT Unit
    FROM (
        VALUES 
            ('mm'),
            ('cm'),
            ('m'),
            ('kg'),
            ('g'),
            ('°C'),
            ('%'),
            ('pcs'),
            ('V'),
            ('A'),
            ('Hz'),
            ('Pa'),
            ('bar'),
            ('psi'),
            ('rpm'),
            ('dB'),
            ('lux'),
            ('pH'),
            ('Ω'),
            ('W')
    ) AS Units(Unit)
    ORDER BY Unit;
END;

GO

PRINT 'Stored procedures fixed successfully!';