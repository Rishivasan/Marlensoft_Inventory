-- Create QCControlPointType table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='QCControlPointType' AND xtype='U')
BEGIN
    CREATE TABLE QCControlPointType (
        ControlPointTypeId INT IDENTITY(1,1) PRIMARY KEY,
        TypeName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500),
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME DEFAULT GETDATE()
    );

    -- Insert default control point types
    INSERT INTO QCControlPointType (TypeName, Description) VALUES
    ('Measure', 'Taking measures requires to enter the product''s measurements during a transfer or during the manufacturing process. To use it, it necessary to specify the norm for your product''s measurements, but also a tolerance threshold.'),
    ('Visual Check', 'Visual inspection of the product for defects, color, finish, etc.'),
    ('Performance Test', 'Testing the performance characteristics of the product.'),
    ('Material Analysis', 'Analysis of material properties and composition.');
END

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
        Description
    FROM QCControlPointType
    WHERE IsActive = 1
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

PRINT 'Tables and stored procedures created successfully!';