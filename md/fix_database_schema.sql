-- Fix Database Schema: Remove IsActive column and standardize Status fields
-- This script handles constraints and dependencies properly

PRINT 'Starting database schema fix...';

-- Step 1: Drop the default constraint on IsActive column
DECLARE @ConstraintName NVARCHAR(200)
SELECT @ConstraintName = name 
FROM sys.default_constraints 
WHERE parent_object_id = OBJECT_ID('MasterRegister') 
AND parent_column_id = (SELECT column_id FROM sys.columns WHERE object_id = OBJECT_ID('MasterRegister') AND name = 'IsActive')

IF @ConstraintName IS NOT NULL
BEGIN
    DECLARE @SQL NVARCHAR(500) = 'ALTER TABLE MasterRegister DROP CONSTRAINT ' + @ConstraintName
    EXEC sp_executesql @SQL
    PRINT 'Dropped default constraint: ' + @ConstraintName
END

-- Step 2: Now drop the IsActive column
ALTER TABLE MasterRegister DROP COLUMN IsActive;
PRINT 'Dropped IsActive column from MasterRegister';

-- Step 3: Standardize ToolsMaster Status column to BIT (boolean)
-- First check if it's already BIT type
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ToolsMaster') AND name = 'Status' AND system_type_id = 104) -- 104 is BIT type
BEGIN
    PRINT 'ToolsMaster Status is already BIT type';
END
ELSE
BEGIN
    -- Convert INT Status to BIT Status
    ALTER TABLE ToolsMaster ALTER COLUMN Status BIT;
    PRINT 'Converted ToolsMaster Status from INT to BIT';
END

-- Step 4: Verify all Status columns are now consistent
PRINT 'Verifying Status column types:';
SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length,
    c.is_nullable
FROM sys.tables t
INNER JOIN sys.columns c ON t.object_id = c.object_id
INNER JOIN sys.types ty ON c.system_type_id = ty.system_type_id
WHERE t.name IN ('ToolsMaster', 'MmdsMaster', 'AssetsConsumablesMaster', 'MasterRegister')
AND c.name IN ('Status', 'IsActive')
ORDER BY t.name, c.name;

-- Step 5: Update any existing Status = 0 records to ensure consistency
UPDATE ToolsMaster SET Status = 0 WHERE Status IS NULL;
UPDATE MmdsMaster SET Status = 0 WHERE Status IS NULL;
UPDATE AssetsConsumablesMaster SET Status = 0 WHERE Status IS NULL;

PRINT 'Database schema fix completed successfully!';
PRINT 'Summary:';
PRINT '- Removed IsActive column from MasterRegister';
PRINT '- Standardized all Status columns to BIT type';
PRINT '- Updated NULL Status values to 0 (inactive)';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Rebuild and restart the backend application';
PRINT '2. Test item creation to ensure Status = 1 is set correctly';
PRINT '3. Verify master list only shows active items';