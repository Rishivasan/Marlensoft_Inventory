using InventoryManagement.Models.Entities;
using InventoryManagement.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace InventoryManagement.Controllers
{
    [ApiController]
    public class AssetsConsumablesController : ControllerBase
    { 
        private readonly IAssetsConsumablesService _service;

        public AssetsConsumablesController(IAssetsConsumablesService service)
        {
            _service = service;
        }

        [HttpGet("api/assets-consumables")]
        public async Task<IActionResult> Get()
        {
            return Ok(await _service.GetAsync());
        }

        [HttpPost("api/add-assets-consumables")]
        public async Task<IActionResult> Create([FromBody] AssetsConsumablesEntity asset)
        {
            var success = await _service.CreateAsync(asset);
            if (!success) return BadRequest("Insert failed");

            return Ok("Asset / Consumable created successfully");
        }
        [HttpGet("api/asset-full-details")]
        public async Task<IActionResult> GetAssetFullDetails(
        [FromQuery] string assetId,
        [FromQuery] string assetType)
        {
            var result = await _service.GetAssetFullDetailsAsync(assetId, assetType);

            if (result?.MasterDetails == null)
                return NotFound("Asset not found");

            return Ok(result);
        }


        [HttpPut("api/update-assets-consumables")]
        public async Task<IActionResult> Update([FromBody] AssetsConsumablesEntity asset)
        {
            var success = await _service.UpdateAsync(asset);
            if (!success) return BadRequest("Update failed");

            return Ok("Asset / Consumable updated successfully");
        }
    }
}
