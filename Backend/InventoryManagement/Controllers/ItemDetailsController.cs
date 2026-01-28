 using InventoryManagement.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace InventoryManagement.Controllers
{
    [ApiController]
    public class ItemDetailsController : ControllerBase
    {
        private readonly IMasterRegisterService _masterService;
        private readonly IMmdsService _mmdsService;
        private readonly IToolService _toolService;
        private readonly IAssetsConsumablesService _assetsService;

        public ItemDetailsController(
            IMasterRegisterService masterService,
            IMmdsService mmdsService,
            IToolService toolService,
            IAssetsConsumablesService assetsService)
        {
            _masterService = masterService;
            _mmdsService = mmdsService;
            _toolService = toolService;
            _assetsService = assetsService;
        }

        [HttpGet("api/item-details/{itemId}")]
        public async Task<IActionResult> GetItemDetails(string itemId)
        {
            try
            {
                // First, get the item from master list to determine type
                var masterItems = await _masterService.GetEnhancedMasterListAsync();
                var masterItem = masterItems.FirstOrDefault(x => x.ItemID == itemId);

                if (masterItem == null)
                {
                    return NotFound($"Item with ID {itemId} not found in master list");
                }

                // Based on item type, fetch detailed data from specific table
                object detailedData = null;
                
                switch (masterItem.Type.ToLower())
                {
                    case "mmd":
                        var mmds = await _mmdsService.GetMmdsAsync();
                        detailedData = mmds.FirstOrDefault(x => x.MmdId == itemId);
                        break;
                        
                    case "tool":
                        var tools = await _toolService.GetToolsAsync();
                        detailedData = tools.FirstOrDefault(x => x.ToolsId == itemId);
                        break;
                        
                    case "asset":
                    case "consumable":
                        var assets = await _assetsService.GetAsync();
                        detailedData = assets.FirstOrDefault(x => x.AssetId == itemId);
                        break;
                        
                    default:
                        return BadRequest($"Unknown item type: {masterItem.Type}");
                }

                if (detailedData == null)
                {
                    return NotFound($"Detailed data not found for {masterItem.Type} with ID {itemId}");
                }

                return Ok(new
                {
                    ItemType = masterItem.Type,
                    MasterData = masterItem,
                    DetailedData = detailedData
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error fetching item details: {ex.Message}");
            }
        }

        [HttpPut("api/item-details/{itemId}")]
        public async Task<IActionResult> UpdateItemDetails(string itemId, [FromBody] JsonElement updateData)
        {
            try
            {
                // First, get the item from master list to determine type
                var masterItems = await _masterService.GetEnhancedMasterListAsync();
                var masterItem = masterItems.FirstOrDefault(x => x.ItemID == itemId);

                if (masterItem == null)
                {
                    return NotFound($"Item with ID {itemId} not found in master list");
                }

                bool success = false;

                // Based on item type, update data in specific table
                switch (masterItem.Type.ToLower())
                {
                    case "mmd":
                        // Convert JsonElement to MmdsEntity and update
                        var mmdData = JsonSerializer.Deserialize<Models.Entities.MmdsEntity>(updateData.GetRawText());
                        if (mmdData != null)
                        {
                            success = await _mmdsService.UpdateMmdsAsync(mmdData);
                        }
                        break;
                        
                    case "tool":
                        // Convert JsonElement to ToolEntity and update
                        var toolData = JsonSerializer.Deserialize<Models.Entities.ToolEntity>(updateData.GetRawText());
                        if (toolData != null)
                        {
                            success = await _toolService.UpdateToolAsync(toolData);
                        }
                        break;
                        
                    case "asset":
                    case "consumable":
                        // Convert JsonElement to AssetsConsumablesEntity and update
                        var assetData = JsonSerializer.Deserialize<Models.Entities.AssetsConsumablesEntity>(updateData.GetRawText());
                        if (assetData != null)
                        {
                            success = await _assetsService.UpdateAsync(assetData);
                        }
                        break;
                        
                    default:
                        return BadRequest($"Unknown item type: {masterItem.Type}");
                }

                if (!success)
                {
                    return BadRequest("Update failed");
                }

                return Ok($"{masterItem.Type} with ID {itemId} updated successfully");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error updating item: {ex.Message}");
            }
        }
    }
}