using Dapper;
using InventoryManagement.Data;
using InventoryManagement.Models.Entities;
using InventoryManagement.Repositories.Interfaces;

namespace InventoryManagement.Repositories
{
    public class ToolRepository : IToolRepository
    {
        private readonly DapperContext _context;

        public ToolRepository(DapperContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<ToolEntity>> GetAllToolsAsync()
        {
            var query = @"
SELECT *
FROM ToolsMaster
WHERE Status = 1;";

            using var connection = _context.CreateConnection();
            var result = await connection.QueryAsync<ToolEntity>(query);
            return result;
        }

        public async Task<int> CreateToolAsync(ToolEntity tool)
        {
            var query = @"
INSERT INTO ToolsMaster
(
    ToolsId, ToolName, ToolType, AssociatedProduct, ArticleCode,
    Vendor, Specifications, StorageLocation, PoNumber, PoDate,
    InvoiceNumber, InvoiceDate, ToolCost, ExtraCharges, TotalCost,
    Lifespan, MaintainanceFrequency, HandlingCertificate, AuditInterval,
    MaxOutput, LastAuditDate, LastAuditNotes, ResponsibleTeam, Notes,
    MsiAsset, KernAsset, CreatedBy, CreatedDate, Status
)
VALUES
(
    @ToolsId, @ToolName, @ToolType, @AssociatedProduct, @ArticleCode,
    @Vendor, @Specifications, @StorageLocation, @PoNumber, @PoDate,
    @InvoiceNumber, @InvoiceDate, @ToolCost, @ExtraCharges, @TotalCost,
    @Lifespan, @MaintainanceFrequency, @HandlingCertificate, @AuditInterval,
    @MaxOutput, @LastAuditDate, @LastAuditNotes, @ResponsibleTeam, @Notes,
    @MsiAsset, @KernAsset, @CreatedBy, GETDATE(), @Status
);";

            using var connection = _context.CreateConnection();
            return await connection.ExecuteAsync(query, tool);
        }

        public async Task<int> UpdateToolAsync(ToolEntity tool)
        {
            var query = @"
UPDATE ToolsMaster
SET
    ToolName = @ToolName,
    ToolType = @ToolType,
    AssociatedProduct = @AssociatedProduct,
    ArticleCode = @ArticleCode,
    VendorName = @VendorName,
    Specifications = @Specifications,
    StorageLocation = @StorageLocation,
    ToolCost = @ToolCost,
    ExtraCharges = @ExtraCharges,
    TotalCost = @TotalCost,
    Lifespan = @Lifespan,
    MaintainanceFrequency = @MaintainanceFrequency,
    HandlingCertificate = @HandlingCertificate,
    AuditInterval = @AuditInterval,
    MaxOutput = @MaxOutput,
    LastAuditDate = @LastAuditDate,
    LastAuditNotes = @LastAuditNotes,
    ResponsibleTeam = @ResponsibleTeam,
    Notes = @Notes,
    MsiAsset = @MsiAsset,
    KernAsset = @KernAsset,
    UpdatedBy = @UpdatedBy,
    UpdatedDate = GETDATE()
WHERE ToolsId = @ToolsId;";

            using var connection = _context.CreateConnection();
            return await connection.ExecuteAsync(query, tool);
        }

        public async Task<int> DeleteToolAsync(string toolId)
        {
            var query = @"
UPDATE ToolsMaster 
SET Status = 0, UpdatedDate = GETDATE() 
WHERE ToolsId = @ToolsId;

UPDATE MasterRegister 
SET IsActive = 0 
WHERE RefId = @ToolsId AND ItemType = 'Tool';";

            using var connection = _context.CreateConnection();
            return await connection.ExecuteAsync(query, new { ToolsId = toolId });
        }
    }
}


