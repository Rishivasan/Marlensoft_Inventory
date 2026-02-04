using InventoryManagement.Models;

namespace InventoryManagement.Services
{
    public interface IQualityService
    {
        Task<IEnumerable<FinalProductDto>> GetFinalProducts();
        Task<IEnumerable<MaterialDto>> GetMaterialsByProduct(int productId);
        Task<IEnumerable<ValidationTypeDto>> GetValidationTypes();
        Task<int> CreateTemplate(QCTemplateDto dto);
        Task<IEnumerable<QCControlPointDto>> GetControlPoints(int templateId);
        Task AddControlPoint(QCControlPointDto dto);
        Task DeleteControlPoint(int id);
        Task<IEnumerable<QCTemplateDto>> GetAllTemplates();
        Task<IEnumerable<string>> GetUnits();
        Task<IEnumerable<ControlPointTypeDto>> GetControlPointTypes();


    }

}
