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
            using var connection = _context.CreateConnection();
            var sql = @"
                INSERT INTO Maintenance (AssetType, AssetId, ItemName, ServiceDate, ServiceProviderCompany, 
                                       ServiceEngineerName, ServiceType, NextServiceDue, ServiceNotes, 
                                       MaintenanceStatus, Cost, ResponsibleTeam, CreatedDate)
                VALUES (@AssetType, @AssetId, @ItemName, @ServiceDate, @ServiceProviderCompany, 
                        @ServiceEngineerName, @ServiceType, @NextServiceDue, @ServiceNotes, 
                        @MaintenanceStatus, @Cost, @ResponsibleTeam, @CreatedDate);
                SELECT CAST(SCOPE_IDENTITY() as int)";

            maintenance.CreatedDate = DateTime.Now;
            var id = await connection.QuerySingleAsync<int>(sql, maintenance);
            maintenance.MaintenanceId = id;

            return CreatedAtAction(nameof(GetMaintenanceByAssetId), new { assetId = maintenance.AssetId }, maintenance);
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