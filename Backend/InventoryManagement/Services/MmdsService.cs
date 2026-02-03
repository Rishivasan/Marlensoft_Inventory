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
                BrandName = x.BrandName,  // Added BrandName mapping
                AccuracyClass = x.AccuracyClass,
                Vendor = x.Vendor,
                CalibratedBy = x.CalibratedBy,
                Specifications = x.Specifications,
                ModelNumber = x.ModelNumber,
                SerialNumber = x.SerialNumber,
                Quantity = x.Quantity,
                CalibrationCertNo = x.CalibrationCertNo,
                Location = x.Location,
                PoNumber = x.PoNumber,
                PoDate = x.PoDate,
                InvoiceNumber = x.InvoiceNumber,
                InvoiceDate = x.InvoiceDate,
                TotalCost = x.TotalCost,
                CalibrationFrequency = x.CalibrationFrequency,
                LastCalibration = x.LastCalibration,
                NextCalibration = x.NextCalibration,
                WarrantyYears = x.WarrantyYears,
                CalibrationStatus = x.CalibrationStatus,
                ResponsibleTeam = x.ResponsibleTeam,
                ManualLink = x.ManualLink,
                StockMsi = x.StockMsi,
                Remarks = x.Remarks,
                CreatedBy = x.CreatedBy,
                UpdatedBy = x.UpdatedBy,
                CreatedDate = x.CreatedDate,
                UpdatedDate = x.UpdatedDate,
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

        public async Task<bool> DeleteMmdsAsync(string mmdId)
        {
            return await _repository.DeleteMmdsAsync(mmdId) > 0;
        }
    }
}
