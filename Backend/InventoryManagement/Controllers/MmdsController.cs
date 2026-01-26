using InventoryManagement.Models.Entities;
using InventoryManagement.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace InventoryManagement.Controllers
{
    [ApiController]
    public class MmdsController : ControllerBase
    {
        private readonly IMmdsService _service;

        public MmdsController(IMmdsService service)
        {
            _service = service;
        }

        [HttpGet("api/mmds")]
        public async Task<IActionResult> GetMmds()
        {
            return Ok(await _service.GetMmdsAsync());
        }

        [HttpPost("api/addmmds")]
        public async Task<IActionResult> CreateMmds([FromBody] MmdsEntity mmds)
        {
            try
            {
                var success = await _service.CreateMmdsAsync(mmds);
                if (!success) return BadRequest("Insert failed");

                return Ok("MMDS created successfully");
            }
            catch (Exception ex)
            {
                return BadRequest($"Error creating MMD: {ex.Message}");
            }
        }

        [HttpPut("api/updatemmds")]
        public async Task<IActionResult> UpdateMmds([FromBody] MmdsEntity mmds)
        {
            var success = await _service.UpdateMmdsAsync(mmds);
            if (!success) return BadRequest("Update failed");

            return Ok("MMDS updated successfully");
        }

        [HttpDelete("api/Mmds/{id}")]
        public async Task<IActionResult> DeleteMmds(string id)
        {
            var success = await _service.DeleteMmdsAsync(id);
            if (!success) return NotFound("MMD not found or delete failed");

            return Ok("MMD deleted successfully");
        }
    }
}
