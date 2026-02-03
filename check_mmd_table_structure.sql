-- Check MmdsMaster table structure
USE InventoryManagement;

-- Show table structure
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'MmdsMaster'
ORDER BY ORDINAL_POSITION;

-- Show sample data
SELECT TOP 3 
    MmdId,
    CASE 
        WHEN EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'MmdsMaster' AND COLUMN_NAME = 'BrandName')
        THEN 'BrandName column exists'
        ELSE 'BrandName column missing'
    END as BrandNameStatus,
    StorageLocation,
    Vendor
FROM MmdsMaster;