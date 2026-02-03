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
            using var connection = _context.CreateConnection();
            connection.Open();
            using var transaction = connection.BeginTransaction();

            try
            {
                // Check if ToolsId already exists to prevent duplicates
                var existsQuery = @"SELECT COUNT(1) FROM ToolsMaster WHERE ToolsId = @ToolsId";
                var exists = await connection.QuerySingleAsync<int>(existsQuery, new { ToolsId = tool.ToolsId }, transaction);
                
                if (exists > 0)
                {
                    throw new InvalidOperationException($"Tool with ID '{tool.ToolsId}' already exists.");
                }

                // First, insert into ToolsMaster
                var toolQuery = @"
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

                var toolResult = await connection.ExecuteAsync(toolQuery, tool, transaction);

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
                    RefId = tool.ToolsId,
                    ItemType = "Tool"
                };

                await connection.ExecuteAsync(masterQuery, masterParams, transaction);

                transaction.Commit();
                return toolResult;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
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
    Vendor = @Vendor,
    Specifications = @Specifications,
    StorageLocation = @StorageLocation,
    PoNumber = @PoNumber,
    PoDate = @PoDate,
    InvoiceNumber = @InvoiceNumber,
    InvoiceDate = @InvoiceDate,
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
    UpdatedDate = GETDATE(),
    Status = @Status
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
SET RefId = 'DELETED_' + RefId + '_' + CONVERT(VARCHAR, GETDATE(), 112)
WHERE RefId = @ToolsId AND ItemType = 'Tool';";

            using var connection = _context.CreateConnection();
            return await connection.ExecuteAsync(query, new { ToolsId = toolId });
        }
    }
}


