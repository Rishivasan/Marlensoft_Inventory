-- Fix the NextServiceDue calculation - the previous update was setting it to CreatedDate instead of calculating properly

-- First, let's see what we have currently
SELECT TOP 5 
    ToolsId, 
    ToolName, 
    CreatedDate, 
    MaintainanceFrequency, 
    NextServiceDue,
    CASE 
        WHEN NextServiceDue = CreatedDate THEN 'SAME AS CREATED'
        ELSE 'DIFFERENT'
    END AS Status
FROM ToolsMaster 
WHERE NextServiceDue IS NOT NULL
ORDER BY CreatedDate DESC;

-- Now fix the calculation for Tools
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
WHERE MaintainanceFrequency IS NOT NULL;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ToolsMaster records';

-- Fix the calculation for Assets/Consumables
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
WHERE MaintenanceFrequency IS NOT NULL;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' AssetsConsumablesMaster records';

-- Fix the calculation for MMDs
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
WHERE CalibrationFrequency IS NOT NULL;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' MmdsMaster records';

-- Verify the fix
SELECT TOP 5 
    ToolsId, 
    ToolName, 
    CreatedDate, 
    MaintainanceFrequency, 
    NextServiceDue,
    DATEDIFF(DAY, CreatedDate, NextServiceDue) AS DaysDifference
FROM ToolsMaster 
WHERE NextServiceDue IS NOT NULL
ORDER BY CreatedDate DESC;

PRINT 'Next service date calculation fix completed!';