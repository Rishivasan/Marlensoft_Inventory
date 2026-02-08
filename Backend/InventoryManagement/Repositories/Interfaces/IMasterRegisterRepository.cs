using InventoryManagement.Models.DTOs;

namespace InventoryManagement.Repositories.Interfaces
{
    public interface IMasterRegisterRepository
    {
        Task<List<MasterListDto>> GetMasterListAsync();
        Task<List<EnhancedMasterListDto>> GetEnhancedMasterListAsync();
        Task<PaginationDto<EnhancedMasterListDto>> GetEnhancedMasterListPaginatedAsync(int pageNumber, int pageSize, string? searchText = null, string? sortColumn = null, string? sortDirection = null);
    }
}
