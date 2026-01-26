using InventoryManagement.Models.DTOs;
using InventoryManagement.Repositories.Interfaces;
using InventoryManagement.Services.Interfaces;

namespace InventoryManagement.Services
{
    public class MasterRegisterService : IMasterRegisterService
    {
        private readonly IMasterRegisterRepository _repo;

        public MasterRegisterService(IMasterRegisterRepository repo)
        {
            _repo = repo;
        }

        public async Task<List<MasterListDto>> GetMasterListAsync()
        {
            return await _repo.GetMasterListAsync();
        }

        public async Task<List<EnhancedMasterListDto>> GetEnhancedMasterListAsync()
        {
            return await _repo.GetEnhancedMasterListAsync();
        }
    }
}
