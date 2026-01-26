namespace InventoryManagement.Models.DTOs
{
    public class MasterListDto
    {
        public int SNo { get; set; }
        public string ItemType { get; set; } = string.Empty;
        public string RefId { get; set; } = string.Empty;
        public DateTime? CreatedDate { get; set; }



        // Common fields to show in master list table
        public string? DisplayId { get; set; }     // ToolId / AssetId / MmdId
        public string? Name { get; set; }          // ToolName / AssetName / etc
        public string? Type { get; set; }          // ToolType / Category / etc
        public string? Supplier { get; set; }      // VendorName / Vendor / etc
        public string? Location { get; set; }      // StorageLocation / Location
    }
}
