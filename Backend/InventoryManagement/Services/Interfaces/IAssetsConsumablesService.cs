using InventoryManagement.Models.DTOs;
using InventoryManagement.Models.Entities;

namespace InventoryManagement.Services.Interfaces
{
    public interface IAssetsConsumablesService
    {
        Task<IEnumerable<AssetsConsumablesDto>> GetAsync();
        Task<bool> CreateAsync(AssetsConsumablesEntity asset);
        Task<bool> UpdateAsync(AssetsConsumablesEntity asset);
        Task<AssetFullDetailDto> GetAssetFullDetailsAsync(string assetId, string assetType);
        Task<bool> DeleteAsync(string assetId);
    }
}
