-- Check if the stored procedure exists
USE ManufacturingApp;
GO

-- Check for sp_CreateQCTemplate
SELECT 
    name AS StoredProcedureName,
    create_date AS CreatedDate,
    modify_date AS ModifiedDate
FROM sys.objects 
WHERE type = 'P' 
AND name = 'sp_CreateQCTemplate';

-- If no results, the stored procedure doesn't exist

-- Also check if QCTemplate table exists
SELECT 
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'QCTemplate';

-- If no results, the table doesn't exist either
