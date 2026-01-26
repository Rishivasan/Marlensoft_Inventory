namespace InventoryManagement.Models.DTOs
{
    public class EnhancedMasterListDto
    {
        public string ItemID { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public string ItemName { get; set; } = string.Empty;
        public string Vendor { get; set; } = string.Empty;
        public DateTime CreatedDate { get; set; }
        public string ResponsibleTeam { get; set; } = string.Empty;
        public string StorageLocation { get; set; } = string.Empty;
        public DateTime? NextServiceDue { get; set; }
        public string AvailabilityStatus { get; set; } = string.Empty;
    }
}