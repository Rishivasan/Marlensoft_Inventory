-- Check MMD Status in database
USE InventoryManagement;

-- Check recent MMD items and their Status
SELECT TOP 10 
    MmdId,
    ModelNumber,
    Vendor,
    CalibrationStatus,
    Status,
    CreatedDate
FROM MmdsMaster 
ORDER BY CreatedDate DESC;

-- Check Status distribution
SELECT 
    Status,
    COUNT(*) as Count
FROM MmdsMaster 
GROUP BY Status;

-- Check MasterRegister entries for MMD
SELECT TOP 10 
    m.RefId,
    m.ItemType,
    m.CreatedDate,
    mm.Status as MmdStatus,
    mm.CalibrationStatus
FROM MasterRegister m
LEFT JOIN MmdsMaster mm ON m.RefId = mm.MmdId
WHERE m.ItemType = 'MMD'
ORDER BY m.CreatedDate DESC;