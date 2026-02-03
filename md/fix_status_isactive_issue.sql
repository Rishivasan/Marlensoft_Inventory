-- Fix Status vs IsActive Issue
-- Option 1: Remove IsActive from MasterRegister, standardize on Status

-- Step 1: Standardize Status field types (make all bool for consistency)
-- Update ToolsMaster to use bool instead of int
ALTER TABLE ToolsMaster ALTER COLUMN Status BIT;

-- Update existing data (1 -> true, 0 -> false)
UPDATE ToolsMaster SET Status = CASE WHEN Status = 1 THEN 1 ELSE 0 END;

-- Step 2: Remove IsActive from MasterRegister (after backing up data)
-- First, create backup
SELECT * INTO MasterRegister_Backup FROM MasterRegister;

-- Remove IsActive column
ALTER TABLE MasterRegister DROP COLUMN IsActive;

-- Step 3: Update queries to only use Status field from individual tables
-- No need for IsActive filtering in MasterRegister anymore

PRINT 'Status/IsActive standardization completed!';