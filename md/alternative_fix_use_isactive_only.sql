-- Alternative Fix: Use IsActive only, remove Status from individual tables
-- This approach centralizes active/inactive logic in MasterRegister

-- Step 1: Migrate Status data to MasterRegister IsActive
UPDATE m 
SET m.IsActive = CASE 
    WHEN t.Status = 1 THEN 1 
    ELSE 0 
END
FROM MasterRegister m
INNER JOIN ToolsMaster t ON m.RefId = t.ToolsId AND m.ItemType = 'Tool';

UPDATE m 
SET m.IsActive = CASE 
    WHEN mm.Status = 1 THEN 1 
    ELSE 0 
END
FROM MasterRegister m
INNER JOIN MmdsMaster mm ON m.RefId = mm.MmdId AND m.ItemType = 'MMD';

UPDATE m 
SET m.IsActive = CASE 
    WHEN ac.Status = 1 THEN 1 
    ELSE 0 
END
FROM MasterRegister m
INNER JOIN AssetsConsumablesMaster ac ON m.RefId = ac.AssetId AND m.ItemType IN ('Asset', 'Consumable');

-- Step 2: Remove Status columns from individual tables
ALTER TABLE ToolsMaster DROP COLUMN Status;
ALTER TABLE MmdsMaster DROP COLUMN Status;
ALTER TABLE AssetsConsumablesMaster DROP COLUMN Status;

PRINT 'Centralized IsActive approach completed!';