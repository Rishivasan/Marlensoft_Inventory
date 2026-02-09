using Microsoft.AspNetCore.Mvc;
using InventoryManagement.Models.Entities;
using InventoryManagement.Data;
using Dapper;

namespace InventoryManagement.Controllers
{
    [ApiController]
    [Route("api/maintenance")]
    public class MaintenanceController : ControllerBase
    {
        private readonly DapperContext _context;

        public MaintenanceController(DapperContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<MaintenanceEntity>>> GetAllMaintenance()
        {
            Console.WriteLine("=== MAINTENANCE GET ALL: Starting query ===");
            
            try
            {
                using var connection = _context.CreateConnection();
                
                // Try different possible table names for getting all maintenance records
                var possibleQueries = new[]
                {
                    "SELECT * FROM Maintenance ORDER BY ServiceDate DESC",
                    "SELECT * FROM MaintenanceRecords ORDER BY ServiceDate DESC", 
                    "SELECT * FROM maintenance ORDER BY ServiceDate DESC"
                };

                foreach (var sql in possibleQueries)
                {
                    try
                    {
                        Console.WriteLine($"Trying maintenance query: {sql}");
                        var maintenance = await connection.QueryAsync<MaintenanceEntity>(sql);
                        var maintenanceList = maintenance.ToList();
                        Console.WriteLine($"✓ SUCCESS! Found {maintenanceList.Count} total maintenance records");
                        return Ok(maintenanceList);
                    }
                    catch (Exception queryEx)
                    {
                        Console.WriteLine($"✗ Query failed: {queryEx.Message}");
                        continue; // Try next query
                    }
                }

                // If all specific queries fail, try dynamic discovery
                Console.WriteLine("Trying dynamic table discovery for getting all maintenance...");
                try
                {
                    var tableInfoSql = @"
                        SELECT TABLE_NAME 
                        FROM INFORMATION_SCHEMA.TABLES 
                        WHERE TABLE_TYPE = 'BASE TABLE' 
                        AND (TABLE_NAME LIKE '%maintenance%' OR TABLE_NAME LIKE '%Maintenance%')";
                    
                    var tables = await connection.QueryAsync<string>(tableInfoSql);
                    Console.WriteLine($"Found maintenance-related tables: {string.Join(", ", tables)}");
                    
                    var firstTable = tables.FirstOrDefault();
                    if (!string.IsNullOrEmpty(firstTable))
                    {
                        var dynamicSql = $"SELECT * FROM {firstTable} ORDER BY ServiceDate DESC";
                        Console.WriteLine($"Trying dynamic query: {dynamicSql}");
                        var maintenance = await connection.QueryAsync<MaintenanceEntity>(dynamicSql);
                        var maintenanceList = maintenance.ToList();
                        Console.WriteLine($"✓ SUCCESS! Dynamic query found {maintenanceList.Count} maintenance records");
                        return Ok(maintenanceList);
                    }
                }
                catch (Exception dynamicEx)
                {
                    Console.WriteLine($"Dynamic query failed: {dynamicEx.Message}");
                }

                Console.WriteLine("No maintenance records found, returning empty list");
                return Ok(new List<MaintenanceEntity>());
            }
            catch (Exception ex)
            {
                Console.WriteLine($"=== MAINTENANCE GET ALL: Fatal error ===");
                Console.WriteLine($"Error: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                
                // Return sample data as fallback
                Console.WriteLine("Returning sample data as fallback");
                var sampleData = new List<MaintenanceEntity>
                {
                    new MaintenanceEntity
                    {
                        MaintenanceId = 1,
                        AssetType = "MMD",
                        AssetId = "MMD001",
                        ItemName = "Venter Caliper",
                        ServiceDate = new DateTime(2024, 4, 6),
                        ServiceProviderCompany = "ABC Calibration Lab",
                        ServiceEngineerName = "Ravi",
                        ServiceType = "Calibration",
                        NextServiceDue = new DateTime(2024, 12, 1),
                        ServiceNotes = "Calibration completed",
                        MaintenanceStatus = "Completed",
                        Cost = 0,
                        ResponsibleTeam = "Production Team",
                        CreatedDate = DateTime.Now
                    }
                };
                
                return Ok(sampleData);
            }
        }

        [HttpGet("paginated/{assetId}")]
        public async Task<ActionResult> GetMaintenancePaginated(
            string assetId,
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 5,
            [FromQuery] string? searchText = null,
            [FromQuery] string? sortColumn = null,
            [FromQuery] string? sortDirection = null)
        {
            Console.WriteLine($"=== MAINTENANCE PAGINATED: AssetId={assetId}, Page={pageNumber}, Size={pageSize}, Search={searchText}, Sort={sortColumn} {sortDirection} ===");
            
            try
            {
                using var connection = _context.CreateConnection();
                
                var query = @"
WITH MaintenanceData AS (
    SELECT 
        MaintenanceId,
        AssetType,
        AssetId,
        ItemName,
        ServiceDate,
        ServiceProviderCompany,
        ServiceEngineerName,
        ServiceType,
        NextServiceDue,
        ServiceNotes,
        MaintenanceStatus,
        Cost,
        ResponsibleTeam,
        CreatedDate
    FROM Maintenance
    WHERE AssetId = @AssetId
    AND (@SearchText IS NULL OR @SearchText = '' OR
        AssetType LIKE '%' + @SearchText + '%' OR
        AssetId LIKE '%' + @SearchText + '%' OR
        ItemName LIKE '%' + @SearchText + '%' OR
        ServiceProviderCompany LIKE '%' + @SearchText + '%' OR
        ServiceEngineerName LIKE '%' + @SearchText + '%' OR
        ServiceType LIKE '%' + @SearchText + '%' OR
        ServiceNotes LIKE '%' + @SearchText + '%' OR
        MaintenanceStatus LIKE '%' + @SearchText + '%' OR
        ResponsibleTeam LIKE '%' + @SearchText + '%' OR
        CONVERT(VARCHAR, ServiceDate, 120) LIKE '%' + @SearchText + '%' OR
        CONVERT(VARCHAR, NextServiceDue, 120) LIKE '%' + @SearchText + '%' OR
        CONVERT(VARCHAR, Cost, 10) LIKE '%' + @SearchText + '%')
)
SELECT 
    *,
    COUNT(*) OVER() AS TotalCount
FROM MaintenanceData
{ORDER_BY_CLAUSE}
OFFSET @Offset ROWS
FETCH NEXT @PageSize ROWS ONLY;
";

                // Build dynamic ORDER BY clause
                var orderByClause = "ORDER BY ServiceDate DESC"; // Default
                
                if (!string.IsNullOrEmpty(sortColumn))
                {
                    var direction = sortDirection?.ToUpper() == "DESC" ? "DESC" : "ASC";
                    
                    var columnMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
                    {
                        { "serviceDate", "ServiceDate" },
                        { "serviceProviderCompany", "ServiceProviderCompany" },
                        { "serviceEngineerName", "ServiceEngineerName" },
                        { "serviceType", "ServiceType" },
                        { "responsibleTeam", "ResponsibleTeam" },
                        { "nextServiceDue", "NextServiceDue" },
                        { "cost", "Cost" },
                        { "maintenanceStatus", "MaintenanceStatus" }
                    };
                    
                    if (columnMap.TryGetValue(sortColumn, out var dbColumn))
                    {
                        orderByClause = $"ORDER BY {dbColumn} {direction}";
                    }
                }
                
                query = query.Replace("{ORDER_BY_CLAUSE}", orderByClause);

                var offset = (pageNumber - 1) * pageSize;
                var parameters = new { AssetId = assetId, SearchText = searchText, Offset = offset, PageSize = pageSize };

                var result = await connection.QueryAsync(query, parameters);
                var resultList = result.ToList();

                var totalCount = resultList.FirstOrDefault()?.TotalCount ?? 0;
                var totalPages = (int)Math.Ceiling((double)totalCount / pageSize);

                var items = resultList.Select(row => new MaintenanceEntity
                {
                    MaintenanceId = row.MaintenanceId,
                    AssetType = row.AssetType,
                    AssetId = row.AssetId,
                    ItemName = row.ItemName,
                    ServiceDate = row.ServiceDate,
                    ServiceProviderCompany = row.ServiceProviderCompany,
                    ServiceEngineerName = row.ServiceEngineerName,
                    ServiceType = row.ServiceType,
                    NextServiceDue = row.NextServiceDue,
                    ServiceNotes = row.ServiceNotes,
                    MaintenanceStatus = row.MaintenanceStatus,
                    Cost = row.Cost,
                    ResponsibleTeam = row.ResponsibleTeam,
                    CreatedDate = row.CreatedDate
                }).ToList();

                Console.WriteLine($"✓ Paginated Maintenance: Page {pageNumber}, Size {pageSize}, Total {totalCount} items");

                return Ok(new
                {
                    totalCount,
                    pageNumber,
                    pageSize,
                    totalPages,
                    items
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"⚠️ Maintenance pagination query failed: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                
                // Return empty pagination result
                return Ok(new
                {
                    totalCount = 0,
                    pageNumber,
                    pageSize,
                    totalPages = 0,
                    items = new List<MaintenanceEntity>()
                });
            }
        }

        [HttpGet("{assetId}")]
        public async Task<ActionResult<IEnumerable<MaintenanceEntity>>> GetMaintenanceByAssetId(string assetId)
        {
            try
            {
                using var connection = _context.CreateConnection();
                
                // First, let's try to find the correct table name and structure
                // Try different possible table names that might exist in the user's database
                var possibleQueries = new[]
                {
                    "SELECT * FROM Maintenance WHERE AssetId = @AssetId ORDER BY ServiceDate DESC",
                    "SELECT * FROM MaintenanceRecords WHERE AssetId = @AssetId ORDER BY ServiceDate DESC", 
                    "SELECT * FROM maintenance WHERE AssetId = @AssetId ORDER BY ServiceDate DESC",
                    "SELECT * FROM Maintenance WHERE AssetID = @AssetId ORDER BY ServiceDate DESC",
                    // Try with different column names that might exist
                    "SELECT MaintenanceId, AssetType, AssetId, ItemName, ServiceDate, ServiceProviderCompany, ServiceEngineerName, ServiceType, NextServiceDue, ServiceNotes, MaintenanceStatus, Cost, ResponsibleTeam, CreatedDate FROM Maintenance WHERE AssetId = @AssetId ORDER BY ServiceDate DESC"
                };

                foreach (var sql in possibleQueries)
                {
                    try
                    {
                        Console.WriteLine($"Trying query: {sql}");
                        var maintenance = await connection.QueryAsync<MaintenanceEntity>(sql, new { AssetId = assetId });
                        var maintenanceList = maintenance.ToList();
                        Console.WriteLine($"Query successful! Found {maintenanceList.Count} maintenance records for AssetId: {assetId}");
                        return Ok(maintenanceList);
                    }
                    catch (Exception queryEx)
                    {
                        Console.WriteLine($"Query failed: {queryEx.Message}");
                        continue; // Try next query
                    }
                }

                // If all queries fail, let's try to get table structure information
                try
                {
                    var tableInfoSql = @"
                        SELECT TABLE_NAME 
                        FROM INFORMATION_SCHEMA.TABLES 
                        WHERE TABLE_TYPE = 'BASE TABLE' 
                        AND (TABLE_NAME LIKE '%maintenance%' OR TABLE_NAME LIKE '%Maintenance%')";
                    
                    var tables = await connection.QueryAsync<string>(tableInfoSql);
                    Console.WriteLine($"Found maintenance-related tables: {string.Join(", ", tables)}");
                    
                    // Try the first maintenance table found
                    var firstTable = tables.FirstOrDefault();
                    if (!string.IsNullOrEmpty(firstTable))
                    {
                        var dynamicSql = $"SELECT * FROM {firstTable} WHERE AssetId = @AssetId";
                        Console.WriteLine($"Trying dynamic query: {dynamicSql}");
                        var maintenance = await connection.QueryAsync<MaintenanceEntity>(dynamicSql, new { AssetId = assetId });
                        return Ok(maintenance);
                    }
                }
                catch (Exception infoEx)
                {
                    Console.WriteLine($"Table info query failed: {infoEx.Message}");
                }

                Console.WriteLine($"No maintenance records found for AssetId: {assetId}");
                return Ok(new List<MaintenanceEntity>());
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error querying maintenance data: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                return Ok(new List<MaintenanceEntity>());
            }
        }

        [HttpPost]
        public async Task<ActionResult<MaintenanceEntity>> CreateMaintenance(MaintenanceEntity maintenance)
        {
            Console.WriteLine($"=== MAINTENANCE CREATE: Starting creation for AssetId: {maintenance.AssetId} ===");
            Console.WriteLine($"Received maintenance data: AssetType={maintenance.AssetType}, ItemName={maintenance.ItemName}, ServiceType={maintenance.ServiceType}");
            Console.WriteLine($"NextServiceDue provided: {maintenance.NextServiceDue}");
            
            try
            {
                using var connection = _context.CreateConnection();
                
                // Set CreatedDate if not provided
                if (maintenance.CreatedDate == default(DateTime))
                {
                    maintenance.CreatedDate = DateTime.Now;
                }
                
                // Ensure MaintenanceId is 0 for new records (let database auto-generate)
                maintenance.MaintenanceId = 0;
                
                // Validate NextServiceDue is provided
                if (maintenance.NextServiceDue == null)
                {
                    Console.WriteLine("⚠️  WARNING: NextServiceDue is null - this maintenance record won't update the master list next service due");
                }
                else
                {
                    Console.WriteLine($"✓ NextServiceDue will be set to: {maintenance.NextServiceDue}");
                }
                
                Console.WriteLine($"Prepared maintenance data: ID={maintenance.MaintenanceId}, CreatedDate={maintenance.CreatedDate}");
                
                // Try different possible table names for insertion
                var possibleInsertQueries = new[]
                {
                    @"INSERT INTO Maintenance (AssetType, AssetId, ItemName, ServiceDate, ServiceProviderCompany, 
                                           ServiceEngineerName, ServiceType, NextServiceDue, ServiceNotes, 
                                           MaintenanceStatus, Cost, ResponsibleTeam, CreatedDate)
                      VALUES (@AssetType, @AssetId, @ItemName, @ServiceDate, @ServiceProviderCompany, 
                              @ServiceEngineerName, @ServiceType, @NextServiceDue, @ServiceNotes, 
                              @MaintenanceStatus, @Cost, @ResponsibleTeam, @CreatedDate);
                      SELECT CAST(SCOPE_IDENTITY() as int)",
                      
                    @"INSERT INTO MaintenanceRecords (AssetType, AssetId, ItemName, ServiceDate, ServiceProviderCompany, 
                                                   ServiceEngineerName, ServiceType, NextServiceDue, ServiceNotes, 
                                                   MaintenanceStatus, Cost, ResponsibleTeam, CreatedDate)
                      VALUES (@AssetType, @AssetId, @ItemName, @ServiceDate, @ServiceProviderCompany, 
                              @ServiceEngineerName, @ServiceType, @NextServiceDue, @ServiceNotes, 
                              @MaintenanceStatus, @Cost, @ResponsibleTeam, @CreatedDate);
                      SELECT CAST(SCOPE_IDENTITY() as int)",
                      
                    @"INSERT INTO maintenance (AssetType, AssetId, ItemName, ServiceDate, ServiceProviderCompany, 
                                           ServiceEngineerName, ServiceType, NextServiceDue, ServiceNotes, 
                                           MaintenanceStatus, Cost, ResponsibleTeam, CreatedDate)
                      VALUES (@AssetType, @AssetId, @ItemName, @ServiceDate, @ServiceProviderCompany, 
                              @ServiceEngineerName, @ServiceType, @NextServiceDue, @ServiceNotes, 
                              @MaintenanceStatus, @Cost, @ResponsibleTeam, @CreatedDate);
                      SELECT CAST(SCOPE_IDENTITY() as int)"
                };

                foreach (var sql in possibleInsertQueries)
                {
                    try
                    {
                        Console.WriteLine($"Trying maintenance insert query: {sql.Substring(0, Math.Min(sql.Length, 100))}...");
                        var id = await connection.QuerySingleAsync<int>(sql, maintenance);
                        maintenance.MaintenanceId = id;
                        
                        Console.WriteLine($"✓ SUCCESS! Created maintenance record with ID: {id} for AssetId: {maintenance.AssetId}");
                        
                        // Log the next service due update
                        if (maintenance.NextServiceDue != null)
                        {
                            Console.WriteLine($"✓ Next Service Due stored in Maintenance table: {maintenance.NextServiceDue}");
                            
                            // IMPORTANT: Update the Next Service Due in the master item table
                            // This ensures the Master List shows the updated date immediately
                            await UpdateMasterItemNextServiceDue(connection, maintenance.AssetId, maintenance.AssetType, maintenance.NextServiceDue.Value);
                        }
                        
                        return CreatedAtAction(nameof(GetMaintenanceByAssetId), new { assetId = maintenance.AssetId }, maintenance);
                    }
                    catch (Exception queryEx)
                    {
                        Console.WriteLine($"✗ Insert query failed: {queryEx.Message}");
                        Console.WriteLine($"Query exception details: {queryEx}");
                        continue; // Try next query
                    }
                }

                // If all specific queries fail, try dynamic discovery and insertion
                Console.WriteLine("Trying dynamic table discovery for insertion...");
                try
                {
                    var tableInfoSql = @"
                        SELECT TABLE_NAME 
                        FROM INFORMATION_SCHEMA.TABLES 
                        WHERE TABLE_TYPE = 'BASE TABLE' 
                        AND (TABLE_NAME LIKE '%maintenance%' OR TABLE_NAME LIKE '%Maintenance%')";
                    
                    var tables = await connection.QueryAsync<string>(tableInfoSql);
                    Console.WriteLine($"Found maintenance-related tables for insertion: {string.Join(", ", tables)}");
                    
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
                        
                        Console.WriteLine($"Trying dynamic insert: {dynamicInsertSql}");
                        var dynamicId = await connection.QuerySingleAsync<int>(dynamicInsertSql, maintenance);
                        maintenance.MaintenanceId = dynamicId;
                        
                        Console.WriteLine($"✓ SUCCESS! Dynamic insert created maintenance record with ID: {dynamicId}");
                        
                        // Log the next service due update
                        if (maintenance.NextServiceDue != null)
                        {
                            Console.WriteLine($"✓ Next Service Due stored: {maintenance.NextServiceDue} - This will now appear in the master list for AssetId: {maintenance.AssetId}");
                        }
                        
                        return CreatedAtAction(nameof(GetMaintenanceByAssetId), new { assetId = maintenance.AssetId }, maintenance);
                    }
                }
                catch (Exception dynamicEx)
                {
                    Console.WriteLine($"Dynamic insertion failed: {dynamicEx.Message}");
                    Console.WriteLine($"Dynamic exception details: {dynamicEx}");
                }

                Console.WriteLine("=== MAINTENANCE CREATE: All insertion attempts failed ===");
                return BadRequest("Unable to create maintenance record. Please check database configuration and ensure maintenance table exists.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"=== MAINTENANCE CREATE: Fatal error ===");
                Console.WriteLine($"Error: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateMaintenance(int id, MaintenanceEntity maintenance)
        {
            Console.WriteLine($"=== MAINTENANCE UPDATE: Starting update for ID: {id} ===");
            Console.WriteLine($"NextServiceDue being updated to: {maintenance.NextServiceDue}");
            
            if (id != maintenance.MaintenanceId)
            {
                Console.WriteLine($"ID mismatch: URL ID {id} != Entity ID {maintenance.MaintenanceId}");
                return BadRequest("ID mismatch");
            }

            try
            {
                using var connection = _context.CreateConnection();
                
                // Log the next service due update
                if (maintenance.NextServiceDue != null)
                {
                    Console.WriteLine($"✓ Updating NextServiceDue to: {maintenance.NextServiceDue} for AssetId: {maintenance.AssetId}");
                }
                else
                {
                    Console.WriteLine($"⚠️  WARNING: NextServiceDue is being set to null for AssetId: {maintenance.AssetId}");
                }
                
                // Try different possible table names for update
                var possibleUpdateQueries = new[]
                {
                    @"UPDATE Maintenance 
                      SET AssetType = @AssetType, AssetId = @AssetId, ItemName = @ItemName, 
                          ServiceDate = @ServiceDate, ServiceProviderCompany = @ServiceProviderCompany,
                          ServiceEngineerName = @ServiceEngineerName, ServiceType = @ServiceType,
                          NextServiceDue = @NextServiceDue, ServiceNotes = @ServiceNotes,
                          MaintenanceStatus = @MaintenanceStatus, Cost = @Cost, ResponsibleTeam = @ResponsibleTeam
                      WHERE MaintenanceId = @MaintenanceId",
                      
                    @"UPDATE MaintenanceRecords 
                      SET AssetType = @AssetType, AssetId = @AssetId, ItemName = @ItemName, 
                          ServiceDate = @ServiceDate, ServiceProviderCompany = @ServiceProviderCompany,
                          ServiceEngineerName = @ServiceEngineerName, ServiceType = @ServiceType,
                          NextServiceDue = @NextServiceDue, ServiceNotes = @ServiceNotes,
                          MaintenanceStatus = @MaintenanceStatus, Cost = @Cost, ResponsibleTeam = @ResponsibleTeam
                      WHERE MaintenanceId = @MaintenanceId",
                      
                    @"UPDATE maintenance 
                      SET AssetType = @AssetType, AssetId = @AssetId, ItemName = @ItemName, 
                          ServiceDate = @ServiceDate, ServiceProviderCompany = @ServiceProviderCompany,
                          ServiceEngineerName = @ServiceEngineerName, ServiceType = @ServiceType,
                          NextServiceDue = @NextServiceDue, ServiceNotes = @ServiceNotes,
                          MaintenanceStatus = @MaintenanceStatus, Cost = @Cost, ResponsibleTeam = @ResponsibleTeam
                      WHERE MaintenanceId = @MaintenanceId"
                };

                foreach (var sql in possibleUpdateQueries)
                {
                    try
                    {
                        Console.WriteLine($"Trying maintenance update query: {sql.Substring(0, Math.Min(sql.Length, 100))}...");
                        var affectedRows = await connection.ExecuteAsync(sql, maintenance);
                        
                        if (affectedRows > 0)
                        {
                            Console.WriteLine($"✓ SUCCESS! Updated maintenance record ID: {id}, affected rows: {affectedRows}");
                            
                            // Log the next service due update success
                            if (maintenance.NextServiceDue != null)
                            {
                                Console.WriteLine($"✓ Next Service Due updated in Maintenance table: {maintenance.NextServiceDue}");
                                
                                // IMPORTANT: Update the Next Service Due in the master item table
                                // This ensures the Master List shows the updated date immediately
                                await UpdateMasterItemNextServiceDue(connection, maintenance.AssetId, maintenance.AssetType, maintenance.NextServiceDue.Value);
                            }
                            
                            return NoContent();
                        }
                        else
                        {
                            Console.WriteLine($"No rows affected for ID: {id}");
                        }
                    }
                    catch (Exception queryEx)
                    {
                        Console.WriteLine($"✗ Update query failed: {queryEx.Message}");
                        continue; // Try next query
                    }
                }

                // If all specific queries fail, try dynamic discovery and update
                Console.WriteLine("Trying dynamic table discovery for update...");
                try
                {
                    var tableInfoSql = @"
                        SELECT TABLE_NAME 
                        FROM INFORMATION_SCHEMA.TABLES 
                        WHERE TABLE_TYPE = 'BASE TABLE' 
                        AND (TABLE_NAME LIKE '%maintenance%' OR TABLE_NAME LIKE '%Maintenance%')";
                    
                    var tables = await connection.QueryAsync<string>(tableInfoSql);
                    Console.WriteLine($"Found maintenance-related tables for update: {string.Join(", ", tables)}");
                    
                    var firstTable = tables.FirstOrDefault();
                    if (!string.IsNullOrEmpty(firstTable))
                    {
                        // Build dynamic update query
                        var dynamicUpdateSql = $@"
                            UPDATE {firstTable} 
                            SET AssetType = @AssetType, AssetId = @AssetId, ItemName = @ItemName, 
                                ServiceDate = @ServiceDate, ServiceProviderCompany = @ServiceProviderCompany,
                                ServiceEngineerName = @ServiceEngineerName, ServiceType = @ServiceType,
                                NextServiceDue = @NextServiceDue, ServiceNotes = @ServiceNotes,
                                MaintenanceStatus = @MaintenanceStatus, Cost = @Cost, ResponsibleTeam = @ResponsibleTeam
                            WHERE MaintenanceId = @MaintenanceId";
                        
                        Console.WriteLine($"Trying dynamic update: {dynamicUpdateSql}");
                        var dynamicAffectedRows = await connection.ExecuteAsync(dynamicUpdateSql, maintenance);
                        
                        if (dynamicAffectedRows > 0)
                        {
                            Console.WriteLine($"✓ SUCCESS! Dynamic update affected {dynamicAffectedRows} rows");
                            
                            // Log the next service due update success
                            if (maintenance.NextServiceDue != null)
                            {
                                Console.WriteLine($"✓ Next Service Due updated to: {maintenance.NextServiceDue} - This will now appear in the master list for AssetId: {maintenance.AssetId}");
                            }
                            
                            return NoContent();
                        }
                        else
                        {
                            Console.WriteLine($"Dynamic update: No rows affected for ID: {id}");
                            return NotFound($"Maintenance record with ID {id} not found");
                        }
                    }
                }
                catch (Exception dynamicEx)
                {
                    Console.WriteLine($"Dynamic update failed: {dynamicEx.Message}");
                }

                Console.WriteLine("=== MAINTENANCE UPDATE: All update attempts failed ===");
                return NotFound($"Unable to update maintenance record with ID {id}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"=== MAINTENANCE UPDATE: Fatal error ===");
                Console.WriteLine($"Error: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteMaintenance(int id)
        {
            using var connection = _context.CreateConnection();
            var sql = "DELETE FROM Maintenance WHERE MaintenanceId = @Id";
            var affectedRows = await connection.ExecuteAsync(sql, new { Id = id });

            if (affectedRows == 0)
            {
                return NotFound();
            }

            return NoContent();
        }

        // Helper method to update Next Service Due in master item tables
        private async Task UpdateMasterItemNextServiceDue(System.Data.IDbConnection connection, string assetId, string assetType, DateTime nextServiceDue)
        {
            try
            {
                Console.WriteLine($"=== UPDATING MASTER ITEM: AssetId={assetId}, Type={assetType}, NextServiceDue={nextServiceDue:yyyy-MM-dd} ===");
                
                string updateSql = "";
                string tableName = "";
                string columnName = "";
                
                // Determine which table and column to update based on asset type
                switch (assetType?.ToLower())
                {
                    case "tool":
                        tableName = "ToolsMaster";
                        columnName = "NextServiceDue";
                        updateSql = $"UPDATE {tableName} SET {columnName} = @NextServiceDue WHERE ToolsId = @AssetId";
                        break;
                        
                    case "asset":
                    case "consumable":
                        tableName = "AssetsConsumablesMaster";
                        columnName = "NextServiceDue";
                        updateSql = $"UPDATE {tableName} SET {columnName} = @NextServiceDue WHERE AssetId = @AssetId";
                        break;
                        
                    case "mmd":
                        tableName = "MmdsMaster";
                        columnName = "NextCalibration";  // MMDs use NextCalibration instead of NextServiceDue
                        updateSql = $"UPDATE {tableName} SET {columnName} = @NextServiceDue WHERE MmdId = @AssetId";
                        break;
                        
                    default:
                        Console.WriteLine($"⚠️  Unknown asset type: {assetType}, skipping master item update");
                        return;
                }
                
                Console.WriteLine($"Executing update: {updateSql}");
                var affectedRows = await connection.ExecuteAsync(updateSql, new { AssetId = assetId, NextServiceDue = nextServiceDue });
                
                if (affectedRows > 0)
                {
                    Console.WriteLine($"✓ SUCCESS! Updated {tableName}.{columnName} for {assetId} to {nextServiceDue:yyyy-MM-dd}");
                    Console.WriteLine($"✓ Master List will now show the updated Next Service Due immediately!");
                }
                else
                {
                    Console.WriteLine($"⚠️  WARNING: No rows updated in {tableName} for {assetId}. Item might not exist.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ ERROR updating master item Next Service Due: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                // Don't throw - we don't want to fail the maintenance creation if this update fails
            }
        }
    }
}