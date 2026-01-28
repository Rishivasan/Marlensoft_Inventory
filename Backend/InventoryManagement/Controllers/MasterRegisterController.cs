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
    }
}
