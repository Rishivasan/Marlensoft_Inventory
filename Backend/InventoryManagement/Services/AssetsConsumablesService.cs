using InventoryManagement.Models.DTOs;
using InventoryManagement.Models.Entities;
using InventoryManagement.Repositories.Interfaces;
using InventoryManagement.Services.Interfaces;

namespace InventoryManagement.Services
{
    public class AssetsConsumablesService : IAssetsConsumablesService
    {
        private readonly IAssetsConsumablesRepository _repository;

        public AssetsConsumablesService(IAssetsConsumablesRepository repository)
        {
            _repository = repository;
        }

        public async Task<AssetFullDetailDto> GetAssetFullDetailsAsync(
    string assetId,
    string assetType)
        {
            if (string.IsNullOrWhiteSpace(assetId))
                throw new ArgumentException("AssetId is required");

            if (string.IsNullOrWhiteSpace(assetType))
                throw new ArgumentException("AssetType is required");

            return await _repository.GetAssetFullDetailsAsync(assetId, assetType);
        }


        public async Task<IEnumerable<AssetsConsumablesDto>> GetAsync()
        {
            var list = await _repository.GetAllAsync();

            return list.Select(x => new AssetsConsumablesDto
            {
                AssetId = x.AssetId,
                Category = x.Category,
                AssetName = x.AssetName,
                Vendor = x.Vendor,
                Quantity = x.Quantity,
                StorageLocation = x.StorageLocation,
                TotalCost = x.TotalCost,
                Status = x.Status
            });
        }

        public async Task<bool> CreateAsync(AssetsConsumablesEntity asset)
        {
            return await _repository.CreateAsync(asset) > 0;
        }

        public async Task<bool> UpdateAsync(AssetsConsumablesEntity asset)
        {
            return await _repository.UpdateAsync(asset) > 0;
        }

        public async Task<bool> DeleteAsync(string assetId)
        {
            return await _repository.DeleteAsync(assetId) > 0;
        }
    }
}
