-- Cleanup script to remove duplicate entries
-- This script will keep the earliest created entry for each duplicate ID

-- Remove duplicate MMDs (keep the earliest one)
WITH DuplicateMMDs AS (
    SELECT MmdId, 
           ROW_NUMBER() OVER (PARTITION BY MmdId ORDER BY CreatedDate ASC) as rn
    FROM MmdsMaster
)
DELETE FROM MmdsMaster 
WHERE MmdId IN (
    SELECT MmdId FROM DuplicateMMDs WHERE rn > 1
) AND CreatedDate NOT IN (
    SELECT MIN(CreatedDate) FROM MmdsMaster GROUP BY MmdId
);

-- Remove duplicate Tools (keep the earliest one)  
WITH DuplicateTools AS (
    SELECT ToolsId,
           ROW_NUMBER() OVER (PARTITION BY ToolsId ORDER BY CreatedDate ASC) as rn
    FROM ToolsMaster
)
DELETE FROM ToolsMaster
WHERE ToolsId IN (
    SELECT ToolsId FROM DuplicateTools WHERE rn > 1
) AND CreatedDate NOT IN (
    SELECT MIN(CreatedDate) FROM ToolsMaster GROUP BY ToolsId
);

-- Remove duplicate Assets/Consumables (keep the earliest one)
WITH DuplicateAssets AS (
    SELECT AssetId,
           ROW_NUMBER() OVER (PARTITION BY AssetId ORDER BY CreatedDate ASC) as rn  
    FROM AssetsConsumablesMaster
)
DELETE FROM AssetsConsumablesMaster
WHERE AssetId IN (
    SELECT AssetId FROM DuplicateAssets WHERE rn > 1
) AND CreatedDate NOT IN (
    SELECT MIN(CreatedDate) FROM AssetsConsumablesMaster GROUP BY AssetId
);

-- Remove duplicate MasterRegister entries (keep the earliest one)
WITH DuplicateMaster AS (
    SELECT RefId,
           ROW_NUMBER() OVER (PARTITION BY RefId ORDER BY CreatedDate ASC) as rn
    FROM MasterRegister  
)
DELETE FROM MasterRegister
WHERE RefId IN (
    SELECT RefId FROM DuplicateMaster WHERE rn > 1
) AND CreatedDate NOT IN (
    SELECT MIN(CreatedDate) FROM MasterRegister GROUP BY RefId
);

-- Verify cleanup results
SELECT 'MMDs with duplicates' as TableName, COUNT(*) as DuplicateCount
FROM (
    SELECT MmdId, COUNT(*) as cnt 
    FROM MmdsMaster 
    GROUP BY MmdId 
    HAVING COUNT(*) > 1
) duplicates
UNION ALL
SELECT 'Tools with duplicates', COUNT(*)
FROM (
    SELECT ToolsId, COUNT(*) as cnt 
    FROM ToolsMaster 
    GROUP BY ToolsId 
    HAVING COUNT(*) > 1
) duplicates
UNION ALL  
SELECT 'Assets with duplicates', COUNT(*)
FROM (
    SELECT AssetId, COUNT(*) as cnt 
    FROM AssetsConsumablesMaster 
    GROUP BY AssetId 
    HAVING COUNT(*) > 1
) duplicates;