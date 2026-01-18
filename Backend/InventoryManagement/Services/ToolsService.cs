
    using InventoryManagement.Models.DTOs;
    using InventoryManagement.Repositories.Interfaces;
    using InventoryManagement.Services.Interfaces;
    using InventoryManagement.Models.Entities;


namespace InventoryManagement.Services
{
    public class ToolService : IToolService
        {
            private readonly IToolRepository _repository;

            public ToolService(IToolRepository repository)
            {
                _repository = repository;
            }
        public async Task<bool> CreateToolAsync(ToolEntity tool)
        {
            var result = await _repository.CreateToolAsync(tool);
            return result > 0;
        }

        public async Task<bool> UpdateToolAsync(ToolEntity tool)
        {
            var result = await _repository.UpdateToolAsync(tool);
            return result > 0;
        }

        public async Task<IEnumerable<ToolDto>> GetToolsAsync()
            {
                var tools = await _repository.GetAllToolsAsync();

            return tools.Select(x => new ToolDto
            {
                ToolsId = x.ToolsId,
                ToolName = x.ToolName,
                ToolType = x.ToolType,
                AssociatedProduct = x.AssociatedProduct,
                ArticleCode = x.ArticleCode,
                VendorName = x.VendorName,
                Specifications = x.Specifications,
                StorageLocation = x.StorageLocation,
                PoNumber = x.PoNumber,
                PoDate = x.PoDate,
                InvoiceNumber = x.InvoiceNumber,
                InvoiceDate = x.InvoiceDate,
                ToolCost = x.ToolCost,
                ExtraCharges = x.ExtraCharges,
                TotalCost = x.TotalCost,
                Lifespan = x.Lifespan,
                MaintainanceFrequency = x.MaintainanceFrequency,
                HandlingCertificate = x.HandlingCertificate,
                AuditInterval = x.AuditInterval,
                MaxOutput = x.MaxOutput,
                LastAuditDate = x.LastAuditDate,
                LastAuditNotes = x.LastAuditNotes,
                ResponsibleTeam = x.ResponsibleTeam,
                Notes = x.Notes,
                MsiAsset = x.MsiAsset,
                KernAsset = x.KernAsset,
                CreatedBy = x.CreatedBy,
                UpdatedBy = x.UpdatedBy,
                CreatedDate = x.CreatedDate,
                UpdatedDate = x.UpdatedDate,
                Status = x.Status
            }
);
            }
        }
    }


