using InventoryManagement.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace InventoryManagement.Controllers
{
    [ApiController]
    public class ItemDetailsV2Controller : ControllerBase
    {
        private readonly IMasterRegisterService _masterService;
        private readonly IMmdsService _mmdsService;
        private readonly IToolService _toolService;
        private readonly IAssetsConsumablesService _assetsService;

        public ItemDetailsV2Controller(
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

        [HttpGet("api/v2/item-details/{itemId}/{itemType}")]
        public async Task<IActionResult> GetCompleteItemDetails(string itemId, string itemType)
        {
            try
            {
                Console.WriteLine($"DEBUG: Getting complete details for itemId: {itemId}, itemType: {itemType}");

                // Get master data first
                var masterItems = await _masterService.GetEnhancedMasterListAsync();
                var masterItem = masterItems.FirstOrDefault(x => x.ItemID == itemId);

                if (masterItem == null)
                {
                    return NotFound($"Item with ID {itemId} not found in master list");
                }

                // Based on item type, fetch detailed data from specific table
                object detailedData = null;
                string actualItemType = itemType.ToLower();

                switch (actualItemType)
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
                        return BadRequest($"Unknown item type: {itemType}");
                }

                if (detailedData == null)
                {
                    Console.WriteLine($"DEBUG: No detailed data found for {actualItemType} with ID {itemId}");
                    // Return master data only if detailed data not found
                    return Ok(new
                    {
                        ItemType = actualItemType,
                        MasterData = masterItem,
                        DetailedData = new { }, // Empty object
                        HasDetailedData = false
                    });
                }

                Console.WriteLine($"DEBUG: Successfully found detailed data for {actualItemType} with ID {itemId}");

                return Ok(new
                {
                    ItemType = actualItemType,
                    MasterData = masterItem,
                    DetailedData = detailedData,
                    HasDetailedData = true
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ERROR: Error fetching item details: {ex.Message}");
                return StatusCode(500, $"Error fetching item details: {ex.Message}");
            }
        }

        [HttpPut("api/v2/item-details/{itemId}/{itemType}")]
        public async Task<IActionResult> UpdateCompleteItemDetails(string itemId, string itemType, [FromBody] JsonElement updateData)
        {
            try
            {
                Console.WriteLine($"DEBUG: Updating item details for itemId: {itemId}, itemType: {itemType}");

                bool success = false;
                string actualItemType = itemType.ToLower();

                // Based on item type, update data in specific table
                switch (actualItemType)
                {
                    case "mmd":
                        var mmdData = JsonSerializer.Deserialize<Models.Entities.MmdsEntity>(updateData.GetRawText());
                        if (mmdData != null)
                        {
                            mmdData.MmdId = itemId; // Ensure ID is set
                            success = await _mmdsService.UpdateMmdsAsync(mmdData);
                        }
                        break;

                    case "tool":
                        var toolData = JsonSerializer.Deserialize<Models.Entities.ToolEntity>(updateData.GetRawText());
                        if (toolData != null)
                        {
                            toolData.ToolsId = itemId; // Ensure ID is set
                            success = await _toolService.UpdateToolAsync(toolData);
                        }
                        break;

                    case "asset":
                    case "consumable":
                        var assetData = JsonSerializer.Deserialize<Models.Entities.AssetsConsumablesEntity>(updateData.GetRawText());
                        if (assetData != null)
                        {
                            assetData.AssetId = itemId; // Ensure ID is set
                            success = await _assetsService.UpdateAsync(assetData);
                        }
                        break;

                    default:
                        return BadRequest($"Unknown item type: {itemType}");
                }

                if (!success)
                {
                    return BadRequest("Update failed");
                }

                Console.WriteLine($"DEBUG: Successfully updated {actualItemType} with ID {itemId}");
                return Ok($"{actualItemType} with ID {itemId} updated successfully");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ERROR: Error updating item: {ex.Message}");
                return StatusCode(500, $"Error updating item: {ex.Message}");
            }
        }

        [HttpGet("api/v2/item-details/{itemId}/{itemType}/fields")]
        public async Task<IActionResult> GetItemFieldStructure(string itemId, string itemType)
        {
            try
            {
                string actualItemType = itemType.ToLower();
                
                // Return field structure based on item type
                switch (actualItemType)
                {
                    case "tool":
                        return Ok(new
                        {
                            ItemType = "tool",
                            Fields = new
                            {
                                Basic = new[] { "ToolsId", "ToolName", "ToolType", "ArticleCode", "AssociatedProduct", "Vendor", "StorageLocation", "Specifications" },
                                Purchase = new[] { "PoNumber", "PoDate", "InvoiceNumber", "InvoiceDate", "ToolCost", "ExtraCharges" },
                                Maintenance = new[] { "Lifespan", "AuditInterval", "MaintainanceFrequency", "HandlingCertificate", "LastAuditDate", "LastAuditNotes", "MaxOutput" },
                                Management = new[] { "Status", "ResponsibleTeam", "MsiAsset", "KernAsset", "Notes" }
                            }
                        });

                    case "mmd":
                        return Ok(new
                        {
                            ItemType = "mmd",
                            Fields = new
                            {
                                Basic = new[] { "MmdId", "MmdName", "MmdType", "ArticleCode", "AssociatedProduct", "Vendor", "StorageLocation", "Specifications" },
                                Purchase = new[] { "PoNumber", "PoDate", "InvoiceNumber", "InvoiceDate", "MmdCost", "ExtraCharges" },
                                Calibration = new[] { "CalibrationFrequency", "LastCalibrationDate", "NextCalibrationDue", "CalibrationCertificate", "CalibrationNotes" },
                                Technical = new[] { "MeasurementRange", "Accuracy", "Resolution", "OperatingConditions" },
                                Management = new[] { "Status", "ResponsibleTeam", "MsiAsset", "KernAsset", "Notes" }
                            }
                        });

                    case "asset":
                    case "consumable":
                        return Ok(new
                        {
                            ItemType = actualItemType,
                            Fields = new
                            {
                                Basic = new[] { "AssetId", "AssetName", "AssetType", "Category", "Vendor", "StorageLocation", "Specifications" },
                                Purchase = new[] { "PoNumber", "PoDate", "InvoiceNumber", "InvoiceDate", "AssetCost", "ExtraCharges" },
                                Inventory = new[] { "CurrentStock", "MinimumStock", "MaximumStock", "ReorderLevel" },
                                Management = new[] { "Status", "ResponsibleTeam", "MsiAsset", "KernAsset", "Notes" }
                            }
                        });

                    default:
                        return BadRequest($"Unknown item type: {itemType}");
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error getting field structure: {ex.Message}");
            }
        }
    }
}