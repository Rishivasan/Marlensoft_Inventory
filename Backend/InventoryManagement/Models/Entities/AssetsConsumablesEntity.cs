namespace InventoryManagement.Models.Entities
{
    public class AssetsConsumablesEntity
    {
        public string AssetId { get; set; }
        public string Category { get; set; }
        public string AssetName { get; set; }
        public string Product { get; set; }
        public string Vendor { get; set; }
        public string Specifications { get; set; }
        public int Quantity { get; set; }
        public string StorageLocation { get; set; }
        public string PoNumber { get; set; }
        public DateTime? PoDate { get; set; }
        public string InvoiceNumber { get; set; }
        public DateTime? InvoiceDate { get; set; }
        public decimal AssetCost { get; set; }
        public decimal ExtraCharges { get; set; }
        public decimal TotalCost { get; set; }
        public string DepreciationPeriod { get; set; }
        public string MaintenanceFrequency { get; set; }
        public string ResponsibleTeam { get; set; }
        public string MsiTeam { get; set; }
        public string Remarks { get; set; }
        public int ItemTypeKey { get; set; }
        public string CreatedBy { get; set; }
        public string UpdatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public DateTime? NextServiceDue { get; set; }
        public bool Status { get; set; }
    }
}
