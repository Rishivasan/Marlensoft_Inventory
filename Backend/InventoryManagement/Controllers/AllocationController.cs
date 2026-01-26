using Microsoft.AspNetCore.Mvc;
using InventoryManagement.Models.Entities;
using InventoryManagement.Data;
using Dapper;

namespace InventoryManagement.Controllers
{
    [ApiController]
    [Route("api/allocation")]
    public class AllocationController : ControllerBase
    {
        private readonly DapperContext _context;

        public AllocationController(DapperContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<AllocationEntity>>> GetAllAllocations()
        {
            using var connection = _context.CreateConnection();
            var sql = "SELECT * FROM Allocation ORDER BY CreatedDate DESC";
            var allocations = await connection.QueryAsync<AllocationEntity>(sql);
            return Ok(allocations);
        }

        [HttpGet("{assetId}")]
        public async Task<ActionResult<IEnumerable<AllocationEntity>>> GetAllocationsByAssetId(string assetId)
        {
            Console.WriteLine($"=== ALLOCATION DEBUG: Starting search for AssetId: {assetId} ===");
            
            try
            {
                using var connection = _context.CreateConnection();
                
                // First, let's discover what allocation-related tables exist
                Console.WriteLine("Step 1: Discovering allocation-related tables...");
                try
                {
                    var tableDiscoverySql = @"
                        SELECT TABLE_NAME, COLUMN_NAME
                        FROM INFORMATION_SCHEMA.COLUMNS 
                        WHERE TABLE_NAME IN (
                            SELECT TABLE_NAME 
                            FROM INFORMATION_SCHEMA.TABLES 
                            WHERE TABLE_TYPE = 'BASE TABLE'
                        )
                        AND (
                            TABLE_NAME LIKE '%allocation%' OR 
                            TABLE_NAME LIKE '%Allocation%' OR
                            TABLE_NAME LIKE '%Usage%' OR
                            TABLE_NAME LIKE '%usage%' OR
                            TABLE_NAME LIKE '%Issue%' OR
                            TABLE_NAME LIKE '%issue%' OR
                            COLUMN_NAME LIKE '%Employee%' OR
                            COLUMN_NAME LIKE '%Issue%' OR
                            COLUMN_NAME LIKE '%Return%'
                        )
                        ORDER BY TABLE_NAME, COLUMN_NAME";
                    
                    var tableInfo = await connection.QueryAsync<dynamic>(tableDiscoverySql);
                    var groupedTables = tableInfo.GroupBy(x => x.TABLE_NAME);
                    
                    Console.WriteLine("Found potential allocation tables:");
                    foreach (var table in groupedTables)
                    {
                        Console.WriteLine($"  Table: {table.Key}");
                        foreach (var column in table)
                        {
                            Console.WriteLine($"    - {column.COLUMN_NAME}");
                        }
                    }
                }
                catch (Exception discoveryEx)
                {
                    Console.WriteLine($"Table discovery failed: {discoveryEx.Message}");
                }

                // Try different possible table names and queries for allocation data
                Console.WriteLine("Step 2: Trying different allocation queries...");
                var possibleQueries = new[]
                {
                    // Standard allocation table variations
                    "SELECT * FROM Allocation WHERE AssetId = @AssetId ORDER BY IssuedDate DESC",
                    "SELECT * FROM AllocationRecords WHERE AssetId = @AssetId ORDER BY IssuedDate DESC",
                    "SELECT * FROM allocation WHERE AssetId = @AssetId ORDER BY IssuedDate DESC",
                    "SELECT * FROM Allocation WHERE AssetID = @AssetId ORDER BY IssuedDate DESC",
                    
                    // Usage/Issue table variations (common alternative names)
                    "SELECT * FROM Usage WHERE AssetId = @AssetId ORDER BY IssuedDate DESC",
                    "SELECT * FROM usage WHERE AssetId = @AssetId ORDER BY IssuedDate DESC",
                    "SELECT * FROM Issue WHERE AssetId = @AssetId ORDER BY IssuedDate DESC",
                    "SELECT * FROM issue WHERE AssetId = @AssetId ORDER BY IssuedDate DESC",
                    "SELECT * FROM ItemIssue WHERE AssetId = @AssetId ORDER BY IssuedDate DESC",
                    "SELECT * FROM AssetUsage WHERE AssetId = @AssetId ORDER BY IssuedDate DESC",
                    
                    // Try with different date column names
                    "SELECT * FROM Allocation WHERE AssetId = @AssetId ORDER BY CreatedDate DESC",
                    "SELECT * FROM Usage WHERE AssetId = @AssetId ORDER BY CreatedDate DESC",
                    
                    // Try explicit column selection with mapping
                    @"SELECT 
                        ISNULL(AllocationId, 0) as AllocationId,
                        ISNULL(AssetType, '') as AssetType,
                        ISNULL(AssetId, '') as AssetId,
                        ISNULL(ItemName, '') as ItemName,
                        ISNULL(EmployeeId, '') as EmployeeId,
                        ISNULL(EmployeeName, '') as EmployeeName,
                        ISNULL(TeamName, '') as TeamName,
                        ISNULL(Purpose, '') as Purpose,
                        IssuedDate,
                        ExpectedReturnDate,
                        ActualReturnDate,
                        ISNULL(AvailabilityStatus, 'Unknown') as AvailabilityStatus,
                        ISNULL(CreatedDate, GETDATE()) as CreatedDate
                      FROM Allocation WHERE AssetId = @AssetId ORDER BY IssuedDate DESC"
                };

                foreach (var sql in possibleQueries)
                {
                    try
                    {
                        Console.WriteLine($"Trying query: {sql.Substring(0, Math.Min(sql.Length, 100))}...");
                        var allocations = await connection.QueryAsync<AllocationEntity>(sql, new { AssetId = assetId });
                        var allocationList = allocations.ToList();
                        Console.WriteLine($"✓ SUCCESS! Found {allocationList.Count} allocation records for AssetId: {assetId}");
                        
                        if (allocationList.Count > 0)
                        {
                            var sample = allocationList.First();
                            Console.WriteLine($"Sample record: Employee={sample.EmployeeName}, Team={sample.TeamName}, Purpose={sample.Purpose}");
                        }
                        
                        return Ok(allocationList);
                    }
                    catch (Exception queryEx)
                    {
                        Console.WriteLine($"✗ Query failed: {queryEx.Message}");
                        continue; // Try next query
                    }
                }

                // If all specific queries fail, try dynamic discovery
                Console.WriteLine("Step 3: Trying dynamic table discovery...");
                try
                {
                    var allTablesSql = @"
                        SELECT TABLE_NAME 
                        FROM INFORMATION_SCHEMA.TABLES 
                        WHERE TABLE_TYPE = 'BASE TABLE'
                        ORDER BY TABLE_NAME";
                    
                    var allTables = await connection.QueryAsync<string>(allTablesSql);
                    Console.WriteLine($"All tables in database: {string.Join(", ", allTables)}");
                    
                    // Look for tables that might contain allocation data
                    var candidateTables = allTables.Where(t => 
                        t.ToLower().Contains("allocation") || 
                        t.ToLower().Contains("usage") || 
                        t.ToLower().Contains("issue") ||
                        t.ToLower().Contains("employee") ||
                        t.ToLower().Contains("assign")).ToList();
                    
                    Console.WriteLine($"Candidate tables: {string.Join(", ", candidateTables)}");
                    
                    foreach (var tableName in candidateTables)
                    {
                        try
                        {
                            // Get column info for this table
                            var columnsSql = @"
                                SELECT COLUMN_NAME, DATA_TYPE 
                                FROM INFORMATION_SCHEMA.COLUMNS 
                                WHERE TABLE_NAME = @TableName
                                ORDER BY ORDINAL_POSITION";
                            
                            var columns = await connection.QueryAsync<dynamic>(columnsSql, new { TableName = tableName });
                            Console.WriteLine($"Table {tableName} columns: {string.Join(", ", columns.Select(c => c.COLUMN_NAME))}");
                            
                            // Try a simple select to see if there's data
                            var testSql = $"SELECT TOP 5 * FROM {tableName}";
                            var testData = await connection.QueryAsync<dynamic>(testSql);
                            Console.WriteLine($"Table {tableName} has {testData.Count()} sample records");
                            
                            if (testData.Any())
                            {
                                var firstRecord = testData.First() as IDictionary<string, object>;
                                Console.WriteLine($"Sample columns in {tableName}: {string.Join(", ", firstRecord.Keys)}");
                                
                                // Check if this table has AssetId column
                                if (firstRecord.Keys.Any(k => k.ToLower().Contains("assetid") || k.ToLower().Contains("asset_id")))
                                {
                                    var assetIdColumn = firstRecord.Keys.First(k => k.ToLower().Contains("assetid") || k.ToLower().Contains("asset_id"));
                                    var dynamicSql = $"SELECT * FROM {tableName} WHERE {assetIdColumn} = @AssetId";
                                    Console.WriteLine($"Trying dynamic query: {dynamicSql}");
                                    
                                    var dynamicResults = await connection.QueryAsync<dynamic>(dynamicSql, new { AssetId = assetId });
                                    Console.WriteLine($"Dynamic query returned {dynamicResults.Count()} records");
                                    
                                    if (dynamicResults.Any())
                                    {
                                        Console.WriteLine("Found data! Attempting to map to AllocationEntity...");
                                        // Try to map the dynamic results to AllocationEntity
                                        var mappedResults = dynamicResults.Select(r => MapDynamicToAllocation(r)).ToList();
                                        return Ok(mappedResults);
                                    }
                                }
                            }
                        }
                        catch (Exception tableEx)
                        {
                            Console.WriteLine($"Error examining table {tableName}: {tableEx.Message}");
                        }
                    }
                }
                catch (Exception dynamicEx)
                {
                    Console.WriteLine($"Dynamic discovery failed: {dynamicEx.Message}");
                }

                Console.WriteLine($"=== ALLOCATION DEBUG: No allocation records found for AssetId: {assetId} ===");
                return Ok(new List<AllocationEntity>());
            }
            catch (Exception ex)
            {
                Console.WriteLine($"=== ALLOCATION DEBUG: Fatal error querying allocation data ===");
                Console.WriteLine($"Error: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                return Ok(new List<AllocationEntity>());
            }
        }

        private AllocationEntity MapDynamicToAllocation(dynamic record)
        {
            var dict = record as IDictionary<string, object>;
            var allocation = new AllocationEntity();
            
            // Map common field variations
            allocation.AllocationId = GetIntValue(dict, "AllocationId", "Id", "allocation_id");
            allocation.AssetType = GetStringValue(dict, "AssetType", "asset_type", "Type");
            allocation.AssetId = GetStringValue(dict, "AssetId", "asset_id", "AssetID");
            allocation.ItemName = GetStringValue(dict, "ItemName", "item_name", "Name", "ProductName");
            allocation.EmployeeId = GetStringValue(dict, "EmployeeId", "employee_id", "EmpId", "emp_id");
            allocation.EmployeeName = GetStringValue(dict, "EmployeeName", "employee_name", "EmpName", "emp_name", "Name");
            allocation.TeamName = GetStringValue(dict, "TeamName", "team_name", "Team", "Department");
            allocation.Purpose = GetStringValue(dict, "Purpose", "purpose", "Reason", "Description");
            allocation.IssuedDate = GetDateValue(dict, "IssuedDate", "issued_date", "IssueDate", "issue_date");
            allocation.ExpectedReturnDate = GetDateValue(dict, "ExpectedReturnDate", "expected_return_date", "ExpectedReturn", "expected_return");
            allocation.ActualReturnDate = GetDateValue(dict, "ActualReturnDate", "actual_return_date", "ActualReturn", "actual_return", "ReturnDate", "return_date");
            allocation.AvailabilityStatus = GetStringValue(dict, "AvailabilityStatus", "availability_status", "Status", "status");
            allocation.CreatedDate = GetDateValue(dict, "CreatedDate", "created_date", "CreateDate", "create_date") ?? DateTime.Now;
            
            return allocation;
        }

        private string GetStringValue(IDictionary<string, object> dict, params string[] possibleKeys)
        {
            foreach (var key in possibleKeys)
            {
                var actualKey = dict.Keys.FirstOrDefault(k => k.Equals(key, StringComparison.OrdinalIgnoreCase));
                if (actualKey != null && dict[actualKey] != null)
                {
                    return dict[actualKey].ToString();
                }
            }
            return "";
        }

        private int GetIntValue(IDictionary<string, object> dict, params string[] possibleKeys)
        {
            foreach (var key in possibleKeys)
            {
                var actualKey = dict.Keys.FirstOrDefault(k => k.Equals(key, StringComparison.OrdinalIgnoreCase));
                if (actualKey != null && dict[actualKey] != null)
                {
                    if (int.TryParse(dict[actualKey].ToString(), out int result))
                        return result;
                }
            }
            return 0;
        }

        private DateTime? GetDateValue(IDictionary<string, object> dict, params string[] possibleKeys)
        {
            foreach (var key in possibleKeys)
            {
                var actualKey = dict.Keys.FirstOrDefault(k => k.Equals(key, StringComparison.OrdinalIgnoreCase));
                if (actualKey != null && dict[actualKey] != null)
                {
                    if (DateTime.TryParse(dict[actualKey].ToString(), out DateTime result))
                        return result;
                }
            }
            return null;
        }

        [HttpPost]
        public async Task<ActionResult<AllocationEntity>> CreateAllocation(AllocationEntity allocation)
        {
            Console.WriteLine($"=== ALLOCATION CREATE: Starting creation for AssetId: {allocation.AssetId} ===");
            
            try
            {
                using var connection = _context.CreateConnection();
                
                // Set CreatedDate
                allocation.CreatedDate = DateTime.Now;
                
                // Try different possible table names for insertion
                var possibleInsertQueries = new[]
                {
                    @"INSERT INTO Allocation (AssetType, AssetId, ItemName, EmployeeId, EmployeeName, 
                                           TeamName, Purpose, IssuedDate, ExpectedReturnDate, 
                                           ActualReturnDate, AvailabilityStatus, CreatedDate)
                      VALUES (@AssetType, @AssetId, @ItemName, @EmployeeId, @EmployeeName, 
                              @TeamName, @Purpose, @IssuedDate, @ExpectedReturnDate, 
                              @ActualReturnDate, @AvailabilityStatus, @CreatedDate);
                      SELECT CAST(SCOPE_IDENTITY() as int)",
                      
                    @"INSERT INTO AllocationRecords (AssetType, AssetId, ItemName, EmployeeId, EmployeeName, 
                                                   TeamName, Purpose, IssuedDate, ExpectedReturnDate, 
                                                   ActualReturnDate, AvailabilityStatus, CreatedDate)
                      VALUES (@AssetType, @AssetId, @ItemName, @EmployeeId, @EmployeeName, 
                              @TeamName, @Purpose, @IssuedDate, @ExpectedReturnDate, 
                              @ActualReturnDate, @AvailabilityStatus, @CreatedDate);
                      SELECT CAST(SCOPE_IDENTITY() as int)",
                      
                    @"INSERT INTO allocation (AssetType, AssetId, ItemName, EmployeeId, EmployeeName, 
                                           TeamName, Purpose, IssuedDate, ExpectedReturnDate, 
                                           ActualReturnDate, AvailabilityStatus, CreatedDate)
                      VALUES (@AssetType, @AssetId, @ItemName, @EmployeeId, @EmployeeName, 
                              @TeamName, @Purpose, @IssuedDate, @ExpectedReturnDate, 
                              @ActualReturnDate, @AvailabilityStatus, @CreatedDate);
                      SELECT CAST(SCOPE_IDENTITY() as int)",
                      
                    @"INSERT INTO Usage (AssetType, AssetId, ItemName, EmployeeId, EmployeeName, 
                                      TeamName, Purpose, IssuedDate, ExpectedReturnDate, 
                                      ActualReturnDate, AvailabilityStatus, CreatedDate)
                      VALUES (@AssetType, @AssetId, @ItemName, @EmployeeId, @EmployeeName, 
                              @TeamName, @Purpose, @IssuedDate, @ExpectedReturnDate, 
                              @ActualReturnDate, @AvailabilityStatus, @CreatedDate);
                      SELECT CAST(SCOPE_IDENTITY() as int)",
                      
                    @"INSERT INTO Issue (AssetType, AssetId, ItemName, EmployeeId, EmployeeName, 
                                      TeamName, Purpose, IssuedDate, ExpectedReturnDate, 
                                      ActualReturnDate, AvailabilityStatus, CreatedDate)
                      VALUES (@AssetType, @AssetId, @ItemName, @EmployeeId, @EmployeeName, 
                              @TeamName, @Purpose, @IssuedDate, @ExpectedReturnDate, 
                              @ActualReturnDate, @AvailabilityStatus, @CreatedDate);
                      SELECT CAST(SCOPE_IDENTITY() as int)"
                };

                foreach (var sql in possibleInsertQueries)
                {
                    try
                    {
                        Console.WriteLine($"Trying allocation insert query: {sql.Substring(0, Math.Min(sql.Length, 100))}...");
                        var id = await connection.QuerySingleAsync<int>(sql, allocation);
                        allocation.AllocationId = id;
                        
                        Console.WriteLine($"✓ SUCCESS! Created allocation record with ID: {id} for AssetId: {allocation.AssetId}");
                        return CreatedAtAction(nameof(GetAllocationsByAssetId), new { assetId = allocation.AssetId }, allocation);
                    }
                    catch (Exception queryEx)
                    {
                        Console.WriteLine($"✗ Allocation insert query failed: {queryEx.Message}");
                        continue; // Try next query
                    }
                }

                // If all specific queries fail, try dynamic discovery and insertion
                Console.WriteLine("Trying dynamic table discovery for allocation insertion...");
                try
                {
                    var tableInfoSql = @"
                        SELECT TABLE_NAME 
                        FROM INFORMATION_SCHEMA.TABLES 
                        WHERE TABLE_TYPE = 'BASE TABLE' 
                        AND (TABLE_NAME LIKE '%allocation%' OR TABLE_NAME LIKE '%Allocation%' OR 
                             TABLE_NAME LIKE '%usage%' OR TABLE_NAME LIKE '%Usage%' OR
                             TABLE_NAME LIKE '%issue%' OR TABLE_NAME LIKE '%Issue%')";
                    
                    var tables = await connection.QueryAsync<string>(tableInfoSql);
                    Console.WriteLine($"Found allocation-related tables for insertion: {string.Join(", ", tables)}");
                    
                    var firstTable = tables.FirstOrDefault();
                    if (!string.IsNullOrEmpty(firstTable))
                    {
                        // Get column info for this table to build dynamic insert
                        var columnsSql = @"
                            SELECT COLUMN_NAME 
                            FROM INFORMATION_SCHEMA.COLUMNS 
                            WHERE TABLE_NAME = @TableName
                            AND COLUMN_NAME NOT LIKE '%Id' OR COLUMN_NAME = 'AssetId'
                            ORDER BY ORDINAL_POSITION";
                        
                        var columns = await connection.QueryAsync<string>(columnsSql, new { TableName = firstTable });
                        var columnList = string.Join(", ", columns);
                        var parameterList = string.Join(", ", columns.Select(c => "@" + c));
                        
                        var dynamicInsertSql = $@"
                            INSERT INTO {firstTable} ({columnList})
                            VALUES ({parameterList});
                            SELECT CAST(SCOPE_IDENTITY() as int)";
                        
                        Console.WriteLine($"Trying dynamic allocation insert: {dynamicInsertSql}");
                        var dynamicId = await connection.QuerySingleAsync<int>(dynamicInsertSql, allocation);
                        allocation.AllocationId = dynamicId;
                        
                        Console.WriteLine($"✓ SUCCESS! Dynamic insert created allocation record with ID: {dynamicId}");
                        return CreatedAtAction(nameof(GetAllocationsByAssetId), new { assetId = allocation.AssetId }, allocation);
                    }
                }
                catch (Exception dynamicEx)
                {
                    Console.WriteLine($"Dynamic allocation insertion failed: {dynamicEx.Message}");
                }

                Console.WriteLine("=== ALLOCATION CREATE: All insertion attempts failed ===");
                return BadRequest("Unable to create allocation record. Please check database configuration.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"=== ALLOCATION CREATE: Fatal error ===");
                Console.WriteLine($"Error: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateAllocation(int id, AllocationEntity allocation)
        {
            if (id != allocation.AllocationId)
            {
                return BadRequest();
            }

            using var connection = _context.CreateConnection();
            var sql = @"
                UPDATE Allocation 
                SET AssetType = @AssetType, AssetId = @AssetId, ItemName = @ItemName, 
                    EmployeeId = @EmployeeId, EmployeeName = @EmployeeName, TeamName = @TeamName,
                    Purpose = @Purpose, IssuedDate = @IssuedDate, ExpectedReturnDate = @ExpectedReturnDate,
                    ActualReturnDate = @ActualReturnDate, AvailabilityStatus = @AvailabilityStatus
                WHERE AllocationId = @AllocationId";

            var affectedRows = await connection.ExecuteAsync(sql, allocation);

            if (affectedRows == 0)
            {
                return NotFound();
            }

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAllocation(int id)
        {
            using var connection = _context.CreateConnection();
            var sql = "DELETE FROM Allocation WHERE AllocationId = @Id";
            var affectedRows = await connection.ExecuteAsync(sql, new { Id = id });

            if (affectedRows == 0)
            {
                return NotFound();
            }

            return NoContent();
        }
    }
}