using InventoryManagement.Models.DTOs;

namespace InventoryManagement.Services.Interfaces
{
    public interface IMasterRegisterService
    {
        Task<List<MasterListDto>> GetMasterListAsync();
        Task<List<EnhancedMasterListDto>> GetEnhancedMasterListAsync();
        Task<PaginationDto<EnhancedMasterListDto>> GetEnhancedMasterListPaginatedAsync(int pageNumber, int pageSize, string? searchText = null);
    }
}
