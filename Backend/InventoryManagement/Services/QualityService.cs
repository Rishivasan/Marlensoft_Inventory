using InventoryManagement.Models;
using InventoryManagement.Repositories;

namespace InventoryManagement.Services
{
    public class QualityService : IQualityService
    {
        private readonly IQualityRepository _repo;

        public QualityService(IQualityRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<FinalProductDto>> GetFinalProducts()
            => _repo.GetFinalProducts();

        public Task<IEnumerable<MaterialDto>> GetMaterialsByProduct(int productId)
            => _repo.GetMaterialsByProduct(productId);

        public Task<IEnumerable<ValidationTypeDto>> GetValidationTypes()
            => _repo.GetValidationTypes();

        public Task<int> CreateTemplate(QCTemplateDto dto)
            => _repo.CreateQCTemplate(dto.TemplateName, dto.ValidationTypeId, dto.FinalProductId, dto.MaterialId);

        public Task<IEnumerable<QCControlPointDto>> GetControlPoints(int templateId)
            => _repo.GetControlPoints(templateId);

        public Task AddControlPoint(QCControlPointDto dto)
            => _repo.AddControlPoint(dto);

        public Task DeleteControlPoint(int id)
            => _repo.DeleteControlPoint(id);

        public Task<IEnumerable<QCTemplateDto>> GetAllTemplates()
            => _repo.GetAllTemplates();

        public Task<IEnumerable<string>> GetUnits()
            => _repo.GetUnits();

        public Task<IEnumerable<ControlPointTypeDto>> GetControlPointTypes()
            => _repo.GetControlPointTypes();


    }

}
