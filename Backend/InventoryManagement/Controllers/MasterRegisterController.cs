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
                var data = await _service.GetEnhancedMasterListAsync();
                return Ok(data);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Database connection failed: {ex.Message}");
                return StatusCode(500, new { error = "Database connection failed", message = ex.Message });
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
