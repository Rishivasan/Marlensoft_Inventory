using Dapper;
using InventoryManagement.Data;
using InventoryManagement.Models.Entities;
using InventoryManagement.Repositories.Interfaces;

namespace InventoryManagement.Repositories
{
    public class MmdsRepository : IMmdsRepository
    {
        private readonly DapperContext _context;

        public MmdsRepository(DapperContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<MmdsEntity>> GetAllMmdsAsync()
        {
            var query = @"SELECT * FROM MmdsMaster WHERE Status = 1";

            using var connection = _context.CreateConnection();
            return await connection.QueryAsync<MmdsEntity>(query);
        }

        public async Task<int> CreateMmdsAsync(MmdsEntity mmds)
        {
            var query = @"
INSERT INTO MmdsMaster
(
    MmdId, AccuracyClass, Vendor, CalibratedBy, Specifications,
    ModelNumber, SerialNumber, Quantity, CalibrationCertNo,
    Location, PoNumber, PoDate, InvoiceNumber, InvoiceDate,
    TotalCost, CalibrationFrequency, LastCalibration, NextCalibration,
    WarrantyYears, CalibrationStatus, ResponsibleTeam,
    ManualLink, StockMsi, Remarks,
    CreatedBy, CreatedDate, Status
)
VALUES
(
    @MmdId, @AccuracyClass, @Vendor, @CalibratedBy, @Specifications,
    @ModelNumber, @SerialNumber, @Quantity, @CalibrationCertNo,
    @Location, @PoNumber, @PoDate, @InvoiceNumber, @InvoiceDate,
    @TotalCost, @CalibrationFrequency, @LastCalibration, @NextCalibration,
    @WarrantyYears, @CalibrationStatus, @ResponsibleTeam,
    @ManualLink, @StockMsi, @Remarks,
    @CreatedBy, GETDATE(), @Status
)";
            using var connection = _context.CreateConnection();
            return await connection.ExecuteAsync(query, mmds);
        }

        public async Task<int> UpdateMmdsAsync(MmdsEntity mmds)
        {
            var query = @"
UPDATE MmdsMaster
SET
    AccuracyClass = @AccuracyClass,
    Vendor = @Vendor,
    CalibratedBy = @CalibratedBy,
    Specifications = @Specifications,
    ModelNumber = @ModelNumber,
    Quantity = @Quantity,
    CalibrationCertNo = @CalibrationCertNo,
    Location = @Location,
    TotalCost = @TotalCost,
    CalibrationFrequency = @CalibrationFrequency,
    LastCalibration = @LastCalibration,
    NextCalibration = @NextCalibration,
    WarrantyYears = @WarrantyYears,
    CalibrationStatus = @CalibrationStatus,
    ResponsibleTeam = @ResponsibleTeam,
    ManualLink = @ManualLink,
    StockMsi = @StockMsi,
    Remarks = @Remarks,
    UpdatedBy = @UpdatedBy,
    UpdatedDate = GETDATE()
WHERE MmdId = @MmdId";
            using var connection = _context.CreateConnection();
            return await connection.ExecuteAsync(query, mmds);
        }
    }
}
