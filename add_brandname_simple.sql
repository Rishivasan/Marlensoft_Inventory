-- Simple script to add BrandName column to MmdsMaster table
USE InventoryManagement;

-- Add BrandName column if it doesn't exist
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'MmdsMaster' 
    AND COLUMN_NAME = 'BrandName'
)
BEGIN
    ALTER TABLE MmdsMaster ADD BrandName NVARCHAR(255) NULL;
    PRINT 'BrandName column added successfully';
END
ELSE
BEGIN
    PRINT 'BrandName column already exists';
END