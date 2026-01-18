namespace InventoryManagement.Models.DTOs
{
    public class AssetsConsumablesDto
    {
        public string AssetId { get; set; }
        public string Category { get; set; }
        public string AssetName { get; set; }
        public string Vendor { get; set; }
        public int Quantity { get; set; }
        public string StorageLocation { get; set; }
        public decimal TotalCost { get; set; }
        public bool Status { get; set; }
    }
}
