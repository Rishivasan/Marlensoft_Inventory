using Microsoft.AspNetCore.Mvc;
using InventoryManagement.Data;
using System.Data;
using Dapper;

namespace InventoryManagement.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NextServiceController : ControllerBase
    {
        private readonly DapperContext _context;

        public NextServiceController(DapperContext context)
        {
            _context = context;
        }

        [HttpGet("GetLastServiceDate/{assetId}/{assetType}")]
        public async Task<IActionResult> GetLastServiceDate(string assetId, string assetType)
        {
            try
            {
                using var connection = _context.CreateConnection();
                
                var query = @"
                    SELECT TOP 1 ServiceDate as LastServiceDate
                    FROM Maintenance 
                    WHERE AssetId = @AssetId AND AssetType = @AssetType 
                    AND ServiceDate IS NOT NULL
                    ORDER BY ServiceDate DESC";

                var result = await connection.QueryFirstOrDefaultAsync<DateTime?>(query, new { AssetId = assetId, AssetType = assetType });

                return Ok(new { lastServiceDate = result?.ToString("yyyy-MM-ddTHH:mm:ss.fffZ") });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error retrieving last service date", error = ex.Message });
            }
        }

        [HttpPost("UpdateNextServiceDate")]
        public async Task<IActionResult> UpdateNextServiceDate([FromBody] UpdateNextServiceDateRequest request)
        {
            try
            {
                using var connection = _context.CreateConnection();
                
                // Update the appropriate table based on asset type
                string updateQuery = request.AssetType.ToLower() switch
                {
                    "tool" => "UPDATE ToolsMaster SET NextServiceDue = @NextServiceDate WHERE ToolsId = @AssetId",
                    "mmd" => "UPDATE MmdsMaster SET NextCalibration = @NextServiceDate WHERE MmdId = @AssetId",
                    "asset" => "UPDATE AssetsConsumablesMaster SET NextServiceDue = @NextServiceDate WHERE AssetId = @AssetId AND ItemTypeKey = 1",
                    "consumable" => "UPDATE AssetsConsumablesMaster SET NextServiceDue = @NextServiceDate WHERE AssetId = @AssetId AND ItemTypeKey = 2",
                    _ => throw new ArgumentException("Invalid asset type")
                };

                var rowsAffected = await connection.ExecuteAsync(updateQuery, new 
                { 
                    AssetId = request.AssetId, 
                    NextServiceDate = request.NextServiceDate 
                });

                if (rowsAffected > 0)
                {
                    return Ok(new { message = "Next service date updated successfully" });
                }
                else
                {
                    return NotFound(new { message = "Asset not found" });
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error updating next service date", error = ex.Message });
            }
        }

        [HttpGet("GetMaintenanceFrequency/{assetId}/{assetType}")]
        public async Task<IActionResult> GetMaintenanceFrequency(string assetId, string assetType)
        {
            try
            {
                Console.WriteLine($"DEBUG: GetMaintenanceFrequency called - AssetId={assetId}, AssetType={assetType}");
                
                using var connection = _context.CreateConnection();
                
                string query = assetType.ToLower() switch
                {
                    "tool" => "SELECT MaintainanceFrequency as MaintenanceFrequency FROM ToolsMaster WHERE ToolsId = @AssetId",
                    "mmd" => "SELECT CalibrationFrequency as MaintenanceFrequency FROM MmdsMaster WHERE MmdId = @AssetId",
                    "asset" => "SELECT MaintenanceFrequency FROM AssetsConsumablesMaster WHERE AssetId = @AssetId AND ItemTypeKey = 1",
                    "consumable" => "SELECT MaintenanceFrequency FROM AssetsConsumablesMaster WHERE AssetId = @AssetId AND ItemTypeKey = 2",
                    _ => throw new ArgumentException("Invalid asset type")
                };

                Console.WriteLine($"DEBUG: Executing query: {query}");
                
                var result = await connection.QueryFirstOrDefaultAsync<string>(query, new { AssetId = assetId });

                Console.WriteLine($"DEBUG: Query result: {result ?? "NULL"}");
                
                return Ok(new { maintenanceFrequency = result });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ERROR: GetMaintenanceFrequency failed - {ex.Message}");
                Console.WriteLine($"ERROR: Stack trace - {ex.StackTrace}");
                return StatusCode(500, new { message = "Error retrieving maintenance frequency", error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        [HttpPost("CalculateNextServiceDate")]
        public IActionResult CalculateNextServiceDate([FromBody] CalculateNextServiceDateRequest request)
        {
            try
            {
                var baseDate = request.LastServiceDate ?? request.CreatedDate;
                var nextServiceDate = CalculateNextServiceDateFromFrequency(baseDate, request.MaintenanceFrequency);

                return Ok(new { nextServiceDate = nextServiceDate.ToString("yyyy-MM-ddTHH:mm:ss.fffZ") });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error calculating next service date", error = ex.Message });
            }
        }

        private DateTime CalculateNextServiceDateFromFrequency(DateTime baseDate, string maintenanceFrequency)
        {
            return maintenanceFrequency.ToLower() switch
            {
                "daily" => baseDate.AddDays(1),
                "weekly" => baseDate.AddDays(7),
                "monthly" => baseDate.AddMonths(1),
                "quarterly" => baseDate.AddMonths(3),
                "half-yearly" or "halfyearly" => baseDate.AddMonths(6),
                "yearly" => baseDate.AddYears(1),
                "2nd year" => baseDate.AddYears(2),
                "3rd year" => baseDate.AddYears(3),
                _ => baseDate.AddYears(1) // Default to yearly
            };
        }
    }

    public class UpdateNextServiceDateRequest
    {
        public string AssetId { get; set; }
        public string AssetType { get; set; }
        public DateTime NextServiceDate { get; set; }
    }

    public class CalculateNextServiceDateRequest
    {
        public DateTime CreatedDate { get; set; }
        public DateTime? LastServiceDate { get; set; }
        public string MaintenanceFrequency { get; set; }
    }
}