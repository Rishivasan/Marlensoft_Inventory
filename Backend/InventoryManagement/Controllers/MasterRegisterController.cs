using InventoryManagement.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace InventoryManagement.Controllers
{
    [Route("api")]
    [ApiController]
    public class MasterRegisterController : ControllerBase
    {
        private readonly IMasterRegisterService _service;

        public MasterRegisterController(IMasterRegisterService service)
        {
            _service = service;
        }

        // GET: api/master-list
        [HttpGet("master-list")]
        public async Task<IActionResult> GetMasterList()
        {
            var data = await _service.GetMasterListAsync();
            return Ok(data);
        }

        // GET: api/enhanced-master-list
        [HttpGet("enhanced-master-list")]
        public async Task<IActionResult> GetEnhancedMasterList()
        {
            try
            {
                // Add cache-busting headers to ensure fresh data
                Response.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate");
                Response.Headers.Add("Pragma", "no-cache");
                Response.Headers.Add("Expires", "0");
                
                var data = await _service.GetEnhancedMasterListAsync();
                return Ok(data);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Database connection failed: {ex.Message}");
                return StatusCode(500, new { error = "Database connection failed", message = ex.Message });
            }
        }

        // GET: api/enhanced-master-list/paginated
        [HttpGet("enhanced-master-list/paginated")]
        public async Task<IActionResult> GetEnhancedMasterListPaginated(
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? searchText = null,
            [FromQuery] string? sortColumn = null,
            [FromQuery] string? sortDirection = null)
        {
            try
            {
                // Add cache-busting headers to ensure fresh data
                Response.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate");
                Response.Headers.Add("Pragma", "no-cache");
                Response.Headers.Add("Expires", "0");
                
                if (pageNumber < 1) pageNumber = 1;
                if (pageSize < 1) pageSize = 10;
                if (pageSize > 100) pageSize = 100; // Max page size limit

                var data = await _service.GetEnhancedMasterListPaginatedAsync(pageNumber, pageSize, searchText, sortColumn, sortDirection);
                return Ok(data);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Pagination failed: {ex.Message}");
                return StatusCode(500, new { error = "Pagination failed", message = ex.Message });
            }
        }

        // GET: api/debug-next-service
        [HttpGet("debug-next-service")]
        public async Task<IActionResult> DebugNextService()
        {
            try
            {
                var data = await _service.GetEnhancedMasterListAsync();
                
                var debugInfo = data.Take(5).Select(item => new
                {
                    ItemID = item.ItemID,
                    ItemName = item.ItemName,
                    Type = item.Type,
                    CreatedDate = item.CreatedDate,
                    NextServiceDue = item.NextServiceDue,
                    DaysDifference = item.NextServiceDue.HasValue ? 
                        (item.NextServiceDue.Value - item.CreatedDate).Days : (int?)null,
                    IsCalculated = item.NextServiceDue.HasValue && item.NextServiceDue != item.CreatedDate
                }).ToList();

                return Ok(new { 
                    TotalItems = data.Count,
                    DebugSample = debugInfo,
                    Message = "Debug information for next service date calculation"
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Debug endpoint failed: {ex.Message}");
                return StatusCode(500, new { error = "Debug failed", message = ex.Message });
            }
        }
    }
}
