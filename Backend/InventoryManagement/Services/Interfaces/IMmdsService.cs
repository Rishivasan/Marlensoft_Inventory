using InventoryManagement.Models.DTOs;
using InventoryManagement.Models.Entities;

namespace InventoryManagement.Services.Interfaces
{
    public interface IMmdsService
    {
        Task<IEnumerable<MmdsDto>> GetMmdsAsync();
        Task<bool> CreateMmdsAsync(MmdsEntity mmds);
        Task<bool> UpdateMmdsAsync(MmdsEntity mmds);
    }
}
