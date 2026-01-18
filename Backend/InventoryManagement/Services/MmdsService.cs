using InventoryManagement.Models.DTOs;
using InventoryManagement.Models.Entities;
using InventoryManagement.Repositories.Interfaces;
using InventoryManagement.Services.Interfaces;

namespace InventoryManagement.Services
{
    public class MmdsService : IMmdsService
    {
        private readonly IMmdsRepository _repository;

        public MmdsService(IMmdsRepository repository)
        {
            _repository = repository;
        }

        public async Task<IEnumerable<MmdsDto>> GetMmdsAsync()
        {
            var list = await _repository.GetAllMmdsAsync();

            return list.Select(x => new MmdsDto
            {
                MmdId = x.MmdId,
                AccuracyClass = x.AccuracyClass,
                Vendor = x.Vendor,
                ModelNumber = x.ModelNumber,
                SerialNumber = x.SerialNumber,
                Quantity = x.Quantity,
                CalibrationStatus = x.CalibrationStatus,
                NextCalibration = x.NextCalibration,
                Location = x.Location,
                Status = x.Status
            });
        }

        public async Task<bool> CreateMmdsAsync(MmdsEntity mmds)
        {
            return await _repository.CreateMmdsAsync(mmds) > 0;
        }

        public async Task<bool> UpdateMmdsAsync(MmdsEntity mmds)
        {
            return await _repository.UpdateMmdsAsync(mmds) > 0;
        }
    }
}
