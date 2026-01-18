using InventoryManagement.Models.Entities;

namespace InventoryManagement.Models.DTOs
{
    public class AssetFullDetailDto
    {
        public object MasterDetails { get; set; }
        public List<MaintenanceEntity> MaintenanceRecords { get; set; }
        public List<AllocationEntity> AllocationRecords { get; set; }
    }
}
