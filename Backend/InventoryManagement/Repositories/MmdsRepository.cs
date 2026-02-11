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
            using var connection = _context.CreateConnection();
            
            // First check if BrandName column exists
            var columnCheckQuery = @"
                SELECT COUNT(*) 
                FROM INFORMATION_SCHEMA.COLUMNS 
                WHERE TABLE_NAME = 'MmdsMaster' 
                AND COLUMN_NAME = 'BrandName'";
            
            var brandNameExists = await connection.QuerySingleAsync<int>(columnCheckQuery) > 0;
            
            string query;
            if (brandNameExists)
            {
                // Use BrandName column if it exists
                query = @"
                    SELECT 
                        MmdId,
                        ISNULL(BrandName, '') as BrandName,
                        AccuracyClass,
                        Vendor,
                        CalibratedBy,
                        Specifications,
                        ModelNumber,
                        SerialNumber,
                        Quantity,
                        CalibrationCertNo,
                        StorageLocation as Location,
                        PoNumber,
                        PoDate,
                        InvoiceNumber,
                        InvoiceDate,
                        TotalCost,
                        CalibrationFrequency,
                        LastCalibration,
                        NextCalibration,
                        WarrantyYears,
                        CalibrationStatus,
                        ResponsibleTeam,
                        ManualLink,
                        StockMsi,
                        Remarks,
                        CreatedBy,
                        UpdatedBy,
                        CreatedDate,
                        UpdatedDate,
                        Status
                    FROM MmdsMaster 
                    WHERE Status = 1";
            }
            else
            {
                // Use empty string for BrandName if column doesn't exist
                query = @"
                    SELECT 
                        MmdId,
                        '' as BrandName,
                        AccuracyClass,
                        Vendor,
                        CalibratedBy,
                        Specifications,
                        ModelNumber,
                        SerialNumber,
                        Quantity,
                        CalibrationCertNo,
                        StorageLocation as Location,
                        PoNumber,
                        PoDate,
                        InvoiceNumber,
                        InvoiceDate,
                        TotalCost,
                        CalibrationFrequency,
                        LastCalibration,
                        NextCalibration,
                        WarrantyYears,
                        CalibrationStatus,
                        ResponsibleTeam,
                        ManualLink,
                        StockMsi,
                        Remarks,
                        CreatedBy,
                        UpdatedBy,
                        CreatedDate,
                        UpdatedDate,
                        Status
                    FROM MmdsMaster 
                    WHERE Status = 1";
                
                Console.WriteLine("INFO: BrandName column not found in MmdsMaster table, using empty string");
            }
            
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

                // Check if BrandName column exists
                var columnCheckQuery = @"
                    SELECT COUNT(*) 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_NAME = 'MmdsMaster' 
                    AND COLUMN_NAME = 'BrandName'";
                
                var brandNameExists = await connection.QuerySingleAsync<int>(columnCheckQuery, transaction: transaction) > 0;

                string mmdQuery;
                object mmdParams;

                if (brandNameExists)
                {
                    // Insert with BrandName column
                    mmdQuery = @"
INSERT INTO MmdsMaster
(
    MmdId, BrandName, AccuracyClass, Vendor, CalibratedBy, Specifications,
    ModelNumber, SerialNumber, Quantity, CalibrationCertNo,
    StorageLocation, PoNumber, PoDate, InvoiceNumber, InvoiceDate,
    TotalCost, CalibrationFrequency, LastCalibration, NextCalibration,
    WarrantyYears, CalibrationStatus, ResponsibleTeam,
    ManualLink, StockMsi, Remarks,
    CreatedBy, CreatedDate, Status
)
VALUES
(
    @MmdId, @BrandName, @AccuracyClass, @Vendor, @CalibratedBy, @Specifications,
    @ModelNumber, @SerialNumber, @Quantity, @CalibrationCertNo,
    @Location, @PoNumber, @PoDate, @InvoiceNumber, @InvoiceDate,
    @TotalCost, @CalibrationFrequency, @LastCalibration, @NextCalibration,
    @WarrantyYears, @CalibrationStatus, @ResponsibleTeam,
    @ManualLink, @StockMsi, @Remarks,
    @CreatedBy, GETDATE(), @Status
)";
                    mmdParams = mmds;
                }
                else
                {
                    // Insert without BrandName column
                    mmdQuery = @"
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
                    mmdParams = mmds;
                    Console.WriteLine("INFO: Creating MMD without BrandName column (column doesn't exist)");
                }

                var mmdResult = await connection.ExecuteAsync(mmdQuery, mmdParams, transaction);

                // Then, insert into MasterRegister
                var masterQuery = @"
INSERT INTO MasterRegister
(
    RefId, ItemType, CreatedDate
)
VALUES
(
    @RefId, @ItemType, GETDATE()
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
            using var connection = _context.CreateConnection();
            
            //// Check if BrandName column exists
            //var columnCheckQuery = @"
            //    SELECT COUNT(*) 
            //    FROM INFORMATION_SCHEMA.COLUMNS 
            //    WHERE TABLE_NAME = 'MmdsMaster' 
            //    AND COLUMN_NAME = 'BrandName'";
            
         //   var brandNameExists = await connection.QuerySingleAsync<int>(columnCheckQuery) > 0;

            string query;
            //if (brandNameExists)
            //{
                // Update with BrandName column - COMPLETE field mapping
                query = @"
UPDATE MmdsMaster
SET
    BrandName = @BrandName,
    AccuracyClass = @AccuracyClass,
    Vendor = @Vendor,
    CalibratedBy = @CalibratedBy,
    Specifications = @Specifications,
    ModelNumber = @ModelNumber,
    SerialNumber = @SerialNumber,
    Quantity = @Quantity,
    CalibrationCertNo = @CalibrationCertNo,
    StorageLocation = @Location,
    PoNumber = @PoNumber,
    PoDate = @PoDate,
    InvoiceNumber = @InvoiceNumber,
    InvoiceDate = @InvoiceDate,
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
    UpdatedDate = GETDATE(),
    Status = @Status
WHERE MmdId = @MmdId";
//            }
//            else
//            {
//                // Update without BrandName column - COMPLETE field mapping
//                query = @"
//UPDATE MmdsMaster
//SET
//    AccuracyClass = @AccuracyClass,
//    Vendor = @Vendor,
//    CalibratedBy = @CalibratedBy,
//    Specifications = @Specifications,
//    ModelNumber = @ModelNumber,
//    SerialNumber = @SerialNumber,
//    Quantity = @Quantity,
//    CalibrationCertNo = @CalibrationCertNo,
//    StorageLocation = @Location,
//    PoNumber = @PoNumber,
//    PoDate = @PoDate,
//    InvoiceNumber = @InvoiceNumber,
//    InvoiceDate = @InvoiceDate,
//    TotalCost = @TotalCost,
//    CalibrationFrequency = @CalibrationFrequency,
//    LastCalibration = @LastCalibration,
//    NextCalibration = @NextCalibration,
//    WarrantyYears = @WarrantyYears,
//    CalibrationStatus = @CalibrationStatus,
//    ResponsibleTeam = @ResponsibleTeam,
//    ManualLink = @ManualLink,
//    StockMsi = @StockMsi,
//    Remarks = @Remarks,
//    UpdatedBy = @UpdatedBy,
//    UpdatedDate = GETDATE(),
//    Status = @Status
//WHERE MmdId = @MmdId";
                
//                Console.WriteLine("INFO: Updating MMD without BrandName column (column doesn't exist)");
//            }
            
            return await connection.ExecuteAsync(query, mmds);
        }

        public async Task<int> DeleteMmdsAsync(string mmdId)
        {
            var query = @"
UPDATE MmdsMaster 
SET Status = 0, UpdatedDate = GETDATE() 
WHERE MmdId = @MmdId;

UPDATE MasterRegister 
SET RefId = 'DELETED_' + RefId + '_' + CONVERT(VARCHAR, GETDATE(), 112)
WHERE RefId = @MmdId AND ItemType = 'MMD';";

            using var connection = _context.CreateConnection();
            return await connection.ExecuteAsync(query, new { MmdId = mmdId });
        }
    }
}
