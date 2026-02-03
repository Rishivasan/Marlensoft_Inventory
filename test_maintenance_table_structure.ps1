# Test script to check maintenance table structure and data
Write-Host "=== MAINTENANCE TABLE STRUCTURE AND DATA TEST ===" -ForegroundColor Green

# Database connection parameters
$server = "DESKTOP-RHVHASAN\SQLEXPRESS"
$database = "InventoryManagement"

Write-Host "`n1. Checking for maintenance-related tables..." -ForegroundColor Yellow
$tableQuery = @"
SELECT TABLE_NAME, TABLE_SCHEMA
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE' 
AND (TABLE_NAME LIKE '%maintenance%' OR TABLE_NAME LIKE '%Maintenance%')
ORDER BY TABLE_NAME
"@

try {
    $tables = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query $tableQuery
    if ($tables) {
        Write-Host "Found maintenance tables:" -ForegroundColor Green
        $tables | Format-Table -AutoSize
        
        # Check each table structure
        foreach ($table in $tables) {
            $tableName = $table.TABLE_NAME
            Write-Host "`n2. Checking structure of table: $tableName" -ForegroundColor Yellow
            
            $structureQuery = @"
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = '$tableName'
ORDER BY ORDINAL_POSITION
"@
            
            $columns = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query $structureQuery
            $columns | Format-Table -AutoSize
            
            Write-Host "`n3. Checking data in table: $tableName" -ForegroundColor Yellow
            $dataQuery = "SELECT TOP 10 * FROM [$tableName] ORDER BY CreatedDate DESC"
            
            try {
                $data = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query $dataQuery
                if ($data) {
                    Write-Host "Found $($data.Count) records:" -ForegroundColor Green
                    $data | Format-Table -AutoSize
                } else {
                    Write-Host "No data found in $tableName" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "Error querying data from $tableName : $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "No maintenance tables found!" -ForegroundColor Red
    }
} catch {
    Write-Host "Error checking tables: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n4. Testing maintenance API endpoint..." -ForegroundColor Yellow
try {
    $apiUrl = "http://localhost:5000/api/maintenance"
    Write-Host "Calling: $apiUrl"
    
    $response = Invoke-RestMethod -Uri $apiUrl -Method GET -ContentType "application/json"
    Write-Host "API Response:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Error calling maintenance API: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== TEST COMPLETE ===" -ForegroundColor Green