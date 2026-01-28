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
            using var connection = _context.CreateConnection();
            connection.Open();
            using var transaction = connection.BeginTransaction();

            try
            {
                // Check if MmdId already exists to prevent duplicates
                var existsQuery = @"SELECT COUNT(1) FROM MmdsMaster WHERE MmdId = @MmdId";
                var exists = await connection.QuerySingleAsync<int>(existsQuery, new { MmdId = mmds.MmdId }, transaction);
                
                if (exists > 0)
                {
                    throw new InvalidOperationException($"MMD with ID '{mmds.MmdId}' already exists.");
                }

                // First, insert into MmdsMaster
                var mmdQuery = @"
INSERT INTO MmdsMaster
(
    MmdId, AccuracyClass, Vendor, CalibratedBy, Specifications,
    ModelNumber, SerialNumber, Quantity, CalibrationCertNo,
    StorageLocation, PoNumber, PoDate, InvoiceNumber, InvoiceDate,
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

                var mmdResult = await connection.ExecuteAsync(mmdQuery, mmds, transaction);

                // Then, insert into MasterRegister
                var masterQuery = @"
INSERT INTO MasterRegister
(
    RefId, ItemType, CreatedDate, IsActive
)
VALUES
(
    @RefId, @ItemType, GETDATE(), 1
)";

                var masterParams = new
                {
                    RefId = mmds.MmdId,
                    ItemType = "MMD"
                };

                await connection.ExecuteAsync(masterQuery, masterParams, transaction);

                transaction.Commit();
                return mmdResult;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
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
    StorageLocation = @Location,
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

        public async Task<int> DeleteMmdsAsync(string mmdId)
        {
            var query = @"
UPDATE MmdsMaster 
SET Status = 0, UpdatedDate = GETDATE() 
WHERE MmdId = @MmdId;

UPDATE MasterRegister 
SET IsActive = 0 
WHERE RefId = @MmdId AND ItemType = 'MMD';";

            using var connection = _context.CreateConnection();
            return await connection.ExecuteAsync(query, new { MmdId = mmdId });
        }
    }
}
