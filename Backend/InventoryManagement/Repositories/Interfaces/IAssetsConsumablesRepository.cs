using InventoryManagement.Models.DTOs;
using InventoryManagement.Models.Entities;

namespace InventoryManagement.Repositories.Interfaces
{
    public interface IAssetsConsumablesRepository
    {
        Task<IEnumerable<AssetsConsumablesEntity>> GetAllAsync();
        Task<int> CreateAsync(AssetsConsumablesEntity asset);
        Task<int> UpdateAsync(AssetsConsumablesEntity asset);

        Task<AssetFullDetailDto> GetAssetFullDetailsAsync(
        string assetId,
        string assetType
);

    }
}


