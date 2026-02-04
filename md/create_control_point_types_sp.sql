-- Create stored procedure to get QC Control Point Types
CREATE PROCEDURE sp_GetQCControlPointTypes
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ControlPointTypeId,
        TypeName,
        Description
    FROM QCControlPointType
    WHERE IsActive = 1
    ORDER BY TypeName;
END;

-- Create stored procedure to get Units
CREATE PROCEDURE sp_GetUnits
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Return common units used in quality control
    SELECT DISTINCT Unit AS Unit
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

PRINT 'Stored procedures created successfully!';