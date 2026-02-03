-- Add BrandName column to MmdsMaster table if it doesn't exist
USE InventoryManagement;

-- Check if BrandName column exists, if not add it
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'MmdsMaster' 
    AND COLUMN_NAME = 'BrandName'
)
BEGIN
    ALTER TABLE MmdsMaster 
    ADD BrandName NVARCHAR(255) NULL;
    
    PRINT 'BrandName column added to MmdsMaster table';
END
ELSE
BEGIN
    PRINT 'BrandName column already exists in MmdsMaster table';
END

-- Show the updated table structure
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'MmdsMaster'
ORDER BY ORDINAL_POSITION;