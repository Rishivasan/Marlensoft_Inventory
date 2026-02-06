-- Add NextServiceDue fields to all item tables for automatic next service date calculation

-- Add NextServiceDue to ToolsMaster table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ToolsMaster]') AND name = 'NextServiceDue')
BEGIN
    ALTER TABLE ToolsMaster ADD NextServiceDue DATETIME NULL;
    PRINT 'Added NextServiceDue column to ToolsMaster table';
END
ELSE
BEGIN
    PRINT 'NextServiceDue column already exists in ToolsMaster table';
END

-- Add NextServiceDue to AssetsConsumablesMaster table (for both Assets and Consumables)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AssetsConsumablesMaster]') AND name = 'NextServiceDue')
BEGIN
    ALTER TABLE AssetsConsumablesMaster ADD NextServiceDue DATETIME NULL;
    PRINT 'Added NextServiceDue column to AssetsConsumablesMaster table';
END
ELSE
BEGIN
    PRINT 'NextServiceDue column already exists in AssetsConsumablesMaster table';
END

-- Note: MmdsMaster table already has NextCalibration field which serves the same purpose

-- Create indexes for better performance on NextServiceDue queries
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ToolsMaster_NextServiceDue')
BEGIN
    CREATE INDEX IX_ToolsMaster_NextServiceDue ON ToolsMaster(NextServiceDue);
    PRINT 'Created index IX_ToolsMaster_NextServiceDue';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_AssetsConsumablesMaster_NextServiceDue')
BEGIN
    CREATE INDEX IX_AssetsConsumablesMaster_NextServiceDue ON AssetsConsumablesMaster(NextServiceDue);
    PRINT 'Created index IX_AssetsConsumablesMaster_NextServiceDue';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_MmdsMaster_NextCalibration')
BEGIN
    CREATE INDEX IX_MmdsMaster_NextCalibration ON MmdsMaster(NextCalibration);
    PRINT 'Created index IX_MmdsMaster_NextCalibration';
END

-- Update existing records with calculated next service dates based on created date and maintenance frequency
PRINT 'Calculating next service dates for existing records...';

-- Update ToolsMaster with next service dates
UPDATE ToolsMaster 
SET NextServiceDue = 
    CASE 
        WHEN MaintainanceFrequency = 'Daily' THEN DATEADD(DAY, 1, CreatedDate)
        WHEN MaintainanceFrequency = 'Weekly' THEN DATEADD(DAY, 7, CreatedDate)
        WHEN MaintainanceFrequency = 'Monthly' THEN DATEADD(MONTH, 1, CreatedDate)
        WHEN MaintainanceFrequency = 'Quarterly' THEN DATEADD(MONTH, 3, CreatedDate)
        WHEN MaintainanceFrequency = 'Half-yearly' THEN DATEADD(MONTH, 6, CreatedDate)
        WHEN MaintainanceFrequency = 'Yearly' THEN DATEADD(YEAR, 1, CreatedDate)
        WHEN MaintainanceFrequency = '2nd year' THEN DATEADD(YEAR, 2, CreatedDate)
        WHEN MaintainanceFrequency = '3rd year' THEN DATEADD(YEAR, 3, CreatedDate)
        ELSE DATEADD(YEAR, 1, CreatedDate) -- Default to yearly
    END
WHERE NextServiceDue IS NULL AND MaintainanceFrequency IS NOT NULL;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ToolsMaster records with next service dates';

-- Update AssetsConsumablesMaster with next service dates
UPDATE AssetsConsumablesMaster 
SET NextServiceDue = 
    CASE 
        WHEN MaintenanceFrequency = 'Daily' THEN DATEADD(DAY, 1, CreatedDate)
        WHEN MaintenanceFrequency = 'Weekly' THEN DATEADD(DAY, 7, CreatedDate)
        WHEN MaintenanceFrequency = 'Monthly' THEN DATEADD(MONTH, 1, CreatedDate)
        WHEN MaintenanceFrequency = 'Quarterly' THEN DATEADD(MONTH, 3, CreatedDate)
        WHEN MaintenanceFrequency = 'Half-yearly' THEN DATEADD(MONTH, 6, CreatedDate)
        WHEN MaintenanceFrequency = 'Yearly' THEN DATEADD(YEAR, 1, CreatedDate)
        WHEN MaintenanceFrequency = '2nd year' THEN DATEADD(YEAR, 2, CreatedDate)
        WHEN MaintenanceFrequency = '3rd year' THEN DATEADD(YEAR, 3, CreatedDate)
        ELSE DATEADD(YEAR, 1, CreatedDate) -- Default to yearly
    END
WHERE NextServiceDue IS NULL AND MaintenanceFrequency IS NOT NULL;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' AssetsConsumablesMaster records with next service dates';

-- Update MmdsMaster with next calibration dates (using existing NextCalibration field)
UPDATE MmdsMaster 
SET NextCalibration = 
    CASE 
        WHEN CalibrationFrequency = 'Daily' THEN DATEADD(DAY, 1, CreatedDate)
        WHEN CalibrationFrequency = 'Weekly' THEN DATEADD(DAY, 7, CreatedDate)
        WHEN CalibrationFrequency = 'Monthly' THEN DATEADD(MONTH, 1, CreatedDate)
        WHEN CalibrationFrequency = 'Quarterly' THEN DATEADD(MONTH, 3, CreatedDate)
        WHEN CalibrationFrequency = 'Half-yearly' THEN DATEADD(MONTH, 6, CreatedDate)
        WHEN CalibrationFrequency = 'Yearly' THEN DATEADD(YEAR, 1, CreatedDate)
        WHEN CalibrationFrequency = '2nd year' THEN DATEADD(YEAR, 2, CreatedDate)
        WHEN CalibrationFrequency = '3rd year' THEN DATEADD(YEAR, 3, CreatedDate)
        ELSE DATEADD(YEAR, 1, CreatedDate) -- Default to yearly
    END
WHERE NextCalibration IS NULL AND CalibrationFrequency IS NOT NULL;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' MmdsMaster records with next calibration dates';

-- Create a view to get all items with their next service due dates
IF OBJECT_ID('vw_AllItemsNextServiceDue', 'V') IS NOT NULL
    DROP VIEW vw_AllItemsNextServiceDue;
GO

CREATE VIEW vw_AllItemsNextServiceDue AS
SELECT 
    'Tool' as ItemType,
    ToolsId as AssetId,
    ToolName as ItemName,
    MaintainanceFrequency as MaintenanceFrequency,
    CreatedDate,
    NextServiceDue,
    CASE 
        WHEN NextServiceDue IS NULL THEN 'No Schedule'
        WHEN NextServiceDue < GETDATE() THEN 'Overdue'
        WHEN NextServiceDue <= DATEADD(DAY, 7, GETDATE()) THEN 'Due Soon'
        ELSE 'Scheduled'
    END as MaintenanceStatus,
    DATEDIFF(DAY, GETDATE(), NextServiceDue) as DaysUntilService
FROM ToolsMaster
WHERE Status = 1

UNION ALL

SELECT 
    CASE WHEN ItemTypeKey = 1 THEN 'Asset' ELSE 'Consumable' END as ItemType,
    AssetId,
    AssetName as ItemName,
    MaintenanceFrequency,
    CreatedDate,
    NextServiceDue,
    CASE 
        WHEN NextServiceDue IS NULL THEN 'No Schedule'
        WHEN NextServiceDue < GETDATE() THEN 'Overdue'
        WHEN NextServiceDue <= DATEADD(DAY, 7, GETDATE()) THEN 'Due Soon'
        ELSE 'Scheduled'
    END as MaintenanceStatus,
    DATEDIFF(DAY, GETDATE(), NextServiceDue) as DaysUntilService
FROM AssetsConsumablesMaster
WHERE Status = 1

UNION ALL

SELECT 
    'MMD' as ItemType,
    MmdId as AssetId,
    ModelNumber as ItemName,
    CalibrationFrequency as MaintenanceFrequency,
    CreatedDate,
    NextCalibration as NextServiceDue,
    CASE 
        WHEN NextCalibration IS NULL THEN 'No Schedule'
        WHEN NextCalibration < GETDATE() THEN 'Overdue'
        WHEN NextCalibration <= DATEADD(DAY, 7, GETDATE()) THEN 'Due Soon'
        ELSE 'Scheduled'
    END as MaintenanceStatus,
    DATEDIFF(DAY, GETDATE(), NextCalibration) as DaysUntilService
FROM MmdsMaster
WHERE Status = 1;
GO

PRINT 'Created view vw_AllItemsNextServiceDue for consolidated next service due information';

-- Test the view
SELECT TOP 10 * FROM vw_AllItemsNextServiceDue ORDER BY NextServiceDue;

PRINT 'Next service due fields and calculations setup completed successfully!';