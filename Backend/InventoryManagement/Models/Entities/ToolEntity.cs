namespace InventoryManagement.Models.Entities
{
    
        public class ToolEntity
        {
        public string ToolsId { get; set; }
        public string ToolName { get; set; }
        public string ToolType { get; set; }
        public string AssociatedProduct { get; set; }
        public string ArticleCode { get; set; }
        public string Vendor { get; set; }
        public string Specifications { get; set; }
        public string StorageLocation { get; set; }
        public string PoNumber { get; set; }
        public DateTime PoDate { get; set; }
        public string InvoiceNumber { get; set; }
        public DateTime InvoiceDate { get; set; }
        public decimal ToolCost { get; set; }
        public decimal ExtraCharges { get; set; }
        public decimal TotalCost { get; set; }
        public string Lifespan { get; set; }
        public string MaintainanceFrequency { get; set; }
        public bool HandlingCertificate { get; set; }
        public string AuditInterval { get; set; }
        public int MaxOutput { get; set; }
        public DateTime LastAuditDate { get; set; }
        public string LastAuditNotes { get; set; }
        public string ResponsibleTeam { get; set; }
        public string Notes { get; set; }
        public string MsiAsset { get; set; }
        public string KernAsset { get; set; }
        public string CreatedBy { get; set; }
        public string UpdatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public DateTime? NextServiceDue { get; set; }
        public bool Status { get; set; }
    }
    


}
