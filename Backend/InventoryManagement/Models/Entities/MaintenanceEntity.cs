namespace InventoryManagement.Models.Entities
{
    public class MaintenanceEntity
    {
        public int MaintenanceId { get; set; }
        public string AssetType { get; set; }
        public string AssetId { get; set; }
        public string ItemName { get; set; }
        public DateTime? ServiceDate { get; set; }
        public string ServiceProviderCompany { get; set; }
        public string ServiceEngineerName { get; set; }
        public string ServiceType { get; set; }
        public DateTime? NextServiceDue { get; set; }
        public string ServiceNotes { get; set; }
        public string MaintenanceStatus { get; set; }
        public decimal Cost { get; set; }
        public string ResponsibleTeam { get; set; }
        public DateTime CreatedDate { get; set; }
    }
}
