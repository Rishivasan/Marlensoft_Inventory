using InventoryManagement.Models.Entities;

namespace InventoryManagement.Repositories.Interfaces
{
    public interface IMmdsRepository
    {
        Task<IEnumerable<MmdsEntity>> GetAllMmdsAsync();
        Task<int> CreateMmdsAsync(MmdsEntity mmds);
        Task<int> UpdateMmdsAsync(MmdsEntity mmds);
    }
}
