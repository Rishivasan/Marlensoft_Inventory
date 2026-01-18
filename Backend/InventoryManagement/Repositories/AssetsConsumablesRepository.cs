using Dapper;
using InventoryManagement.Data;
using InventoryManagement.Models.DTOs;
using InventoryManagement.Models.Entities;
using InventoryManagement.Repositories.Interfaces;
using System.Data;

namespace InventoryManagement.Repositories
{
    public class AssetsConsumablesRepository : IAssetsConsumablesRepository
    {
        private readonly DapperContext _context;

        public AssetsConsumablesRepository(DapperContext context)
        {
            _context = context;
        }
        public async Task<AssetFullDetailDto> GetAssetFullDetailsAsync(string assetId, string assetType)
        {
            using var connection = _context.CreateConnection();

            using var multi = await connection.QueryMultipleAsync(
                "GetAssetFullDetails",
                new { AssetId = assetId, AssetType = assetType },
                commandType: CommandType.StoredProcedure
            );

            var master = await multi.ReadFirstOrDefaultAsync<dynamic>();
            var maintenance = (await multi.ReadAsync<MaintenanceEntity>()).ToList();
            var allocation = (await multi.ReadAsync<AllocationEntity>()).ToList();

            return new AssetFullDetailDto
            {
                MasterDetails = master,
                MaintenanceRecords = maintenance,
                AllocationRecords = allocation
            };
        }


        public async Task<IEnumerable<AssetsConsumablesEntity>> GetAllAsync()
        {
            var query = @"SELECT * FROM AssetsConsumablesMaster WHERE Status = 1";

            using var connection = _context.CreateConnection();
            return await connection.QueryAsync<AssetsConsumablesEntity>(query);
        }

        public async Task<int> CreateAsync(AssetsConsumablesEntity asset)
        {
            var query = @"
INSERT INTO AssetsConsumablesMaster
(
    AssetId, Category, AssetName, Product, Vendor, Specifications,
    Quantity, StorageLocation, PoNumber, PoDate,
    InvoiceNumber, InvoiceDate, AssetCost, ExtraCharges, TotalCost,
    DepreciationPeriod, MaintenanceFrequency, ResponsibleTeam, MsiTeam,
    Remarks, ItemTypeKey,
    CreatedBy, CreatedDate, Status
)
VALUES
(
    @AssetId, @Category, @AssetName, @Product, @Vendor, @Specifications,
    @Quantity, @StorageLocation, @PoNumber, @PoDate,
    @InvoiceNumber, @InvoiceDate, @AssetCost, @ExtraCharges, @TotalCost,
    @DepreciationPeriod, @MaintenanceFrequency, @ResponsibleTeam, @MsiTeam,
    @Remarks, @ItemTypeKey,
    @CreatedBy, GETDATE(), @Status
)";
            using var connection = _context.CreateConnection();
            return await connection.ExecuteAsync(query, asset);
        }

        public async Task<int> UpdateAsync(AssetsConsumablesEntity asset)
        {
            var query = @"
UPDATE AssetsConsumablesMaster
SET
    Category = @Category,
    AssetName = @AssetName,
    Product = @Product,
    Vendor = @Vendor,
    Specifications = @Specifications,
    Quantity = @Quantity,
    StorageLocation = @StorageLocation,
    AssetCost = @AssetCost,
    ExtraCharges = @ExtraCharges,
    TotalCost = @TotalCost,
    DepreciationPeriod = @DepreciationPeriod,
    MaintenanceFrequency = @MaintenanceFrequency,
    ResponsibleTeam = @ResponsibleTeam,
    MsiTeam = @MsiTeam,
    Remarks = @Remarks,
    ItemTypeKey = @ItemTypeKey,
    UpdatedBy = @UpdatedBy,
    UpdatedDate = GETDATE()
WHERE AssetId = @AssetId";
            using var connection = _context.CreateConnection();
            return await connection.ExecuteAsync(query, asset);
        }
    }
}
