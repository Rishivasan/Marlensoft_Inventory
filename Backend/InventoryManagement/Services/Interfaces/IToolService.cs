
using InventoryManagement.Models.DTOs;
using InventoryManagement.Models.Entities;

namespace InventoryManagement.Services.Interfaces
{


public interface IToolService
    {
        Task<IEnumerable<ToolDto>> GetToolsAsync();
        Task<bool> CreateToolAsync(ToolEntity tool);
        Task<bool> UpdateToolAsync(ToolEntity tool);
    }


}


