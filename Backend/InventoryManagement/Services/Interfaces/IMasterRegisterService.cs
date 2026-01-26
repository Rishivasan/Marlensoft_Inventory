using InventoryManagement.Models.DTOs;

namespace InventoryManagement.Services.Interfaces
{
    public interface IMasterRegisterService
    {
        Task<List<MasterListDto>> GetMasterListAsync();
        Task<List<EnhancedMasterListDto>> GetEnhancedMasterListAsync();
    }
}
