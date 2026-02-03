-- Script to check maintenance data in the database
-- Run this in SQL Server Management Studio or sqlcmd

USE InventoryManagement;

-- Check if Maintenance table exists and show its structure
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Maintenance'
ORDER BY ORDINAL_POSITION;

-- Show all maintenance records
SELECT 
    MaintenanceId,
    AssetId,
    AssetType,
    ItemName,
    ServiceDate,
    ServiceProviderCompany,
    ServiceEngineerName,
    ServiceType,
    NextServiceDue,
    MaintenanceStatus,
    Cost,
    ResponsibleTeam,
    CreatedDate
FROM Maintenance 
ORDER BY CreatedDate DESC;

-- Count total maintenance records
SELECT COUNT(*) as TotalMaintenanceRecords FROM Maintenance;

-- Show recent maintenance records (last 10)
SELECT TOP 10 
    MaintenanceId,
    AssetId,
    ItemName,
    ServiceType,
    ServiceDate,
    CreatedDate
FROM Maintenance 
ORDER BY CreatedDate DESC;