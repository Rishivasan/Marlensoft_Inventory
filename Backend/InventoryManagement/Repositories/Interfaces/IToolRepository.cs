using InventoryManagement.Models.Entities;

namespace InventoryManagement.Repositories.Interfaces
{
    public interface IToolRepository
    {
        Task<IEnumerable<ToolEntity>> GetAllToolsAsync();
        Task<int> CreateToolAsync(ToolEntity tool);
        Task<int> UpdateToolAsync(ToolEntity tool);
        Task<int> DeleteToolAsync(string toolId);
    }
}
