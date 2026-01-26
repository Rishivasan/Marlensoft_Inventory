using InventoryManagement.Models.DTOs;

namespace InventoryManagement.Repositories.Interfaces
{
    public interface IMasterRegisterRepository
    {
        Task<List<MasterListDto>> GetMasterListAsync();
        Task<List<EnhancedMasterListDto>> GetEnhancedMasterListAsync();
    }
}
