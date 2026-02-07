using InventoryManagement.Models;

namespace InventoryManagement.Repositories
{
    public interface IQualityRepository
    {
        Task<IEnumerable<FinalProductDto>> GetFinalProducts();
        Task<IEnumerable<MaterialDto>> GetMaterialsByProduct(int finalProductId);
        Task<IEnumerable<ValidationTypeDto>> GetValidationTypes();

        Task<int> CreateQCTemplate(string templateName, int validationTypeId, int finalProductId, int? materialId = null, string? toolsToQualityCheck = null);

        Task<IEnumerable<QCControlPointDto>> GetControlPoints(int templateId);

        Task AddControlPoint(QCControlPointDto dto);

        Task DeleteControlPoint(int controlPointId);

        Task<IEnumerable<QCTemplateDto>> GetAllTemplates();
        Task<IEnumerable<string>> GetUnits();
        Task<IEnumerable<ControlPointTypeDto>> GetControlPointTypes();

    }

}
