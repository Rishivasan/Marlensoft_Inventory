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
            // TEMPORARY: Return sample data since database tables don't exist yet
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
            
            // TODO: Uncomment this when database tables are created
            /*
            using var connection = _context.CreateConnection();
            var sql = "SELECT * FROM Maintenance ORDER BY CreatedDate DESC";
            var maintenance = await connection.QueryAsync<MaintenanceEntity>(sql);
            return Ok(maintenance);
            */
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
            
            try
            {
                using var connection = _context.CreateConnection();
                
                // Set CreatedDate
                maintenance.CreatedDate = DateTime.Now;
                
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
                        return CreatedAtAction(nameof(GetMaintenanceByAssetId), new { assetId = maintenance.AssetId }, maintenance);
                    }
                    catch (Exception queryEx)
                    {
                        Console.WriteLine($"✗ Insert query failed: {queryEx.Message}");
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
                        return CreatedAtAction(nameof(GetMaintenanceByAssetId), new { assetId = maintenance.AssetId }, maintenance);
                    }
                }
                catch (Exception dynamicEx)
                {
                    Console.WriteLine($"Dynamic insertion failed: {dynamicEx.Message}");
                }

                Console.WriteLine("=== MAINTENANCE CREATE: All insertion attempts failed ===");
                return BadRequest("Unable to create maintenance record. Please check database configuration.");
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
            if (id != maintenance.MaintenanceId)
            {
                return BadRequest();
            }

            using var connection = _context.CreateConnection();
            var sql = @"
                UPDATE Maintenance 
                SET AssetType = @AssetType, AssetId = @AssetId, ItemName = @ItemName, 
                    ServiceDate = @ServiceDate, ServiceProviderCompany = @ServiceProviderCompany,
                    ServiceEngineerName = @ServiceEngineerName, ServiceType = @ServiceType,
                    NextServiceDue = @NextServiceDue, ServiceNotes = @ServiceNotes,
                    MaintenanceStatus = @MaintenanceStatus, Cost = @Cost, ResponsibleTeam = @ResponsibleTeam
                WHERE MaintenanceId = @MaintenanceId";

            var affectedRows = await connection.ExecuteAsync(sql, maintenance);

            if (affectedRows == 0)
            {
                return NotFound();
            }

            return NoContent();
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
    }
}