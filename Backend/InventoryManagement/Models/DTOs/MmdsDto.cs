namespace InventoryManagement.Models.DTOs
{
    public class MmdsDto
    {
        public string MmdId { get; set; }
        public string BrandName { get; set; }  // Added BrandName field
        public string AccuracyClass { get; set; }
        public string Vendor { get; set; }
        public string CalibratedBy { get; set; }
        public string Specifications { get; set; }
        public string ModelNumber { get; set; }
        public string SerialNumber { get; set; }
        public int Quantity { get; set; }
        public string CalibrationCertNo { get; set; }
        public string Location { get; set; }
        public string PoNumber { get; set; }
        public DateTime? PoDate { get; set; }
        public string InvoiceNumber { get; set; }
        public DateTime? InvoiceDate { get; set; }
        public decimal TotalCost { get; set; }
        public string CalibrationFrequency { get; set; }
        public DateTime? LastCalibration { get; set; }
        public DateTime? NextCalibration { get; set; }
        public int WarrantyYears { get; set; }
        public string CalibrationStatus { get; set; }
        public string ResponsibleTeam { get; set; }
        public string ManualLink { get; set; }
        public string StockMsi { get; set; }
        public string Remarks { get; set; }
        public string CreatedBy { get; set; }
        public string UpdatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public bool Status { get; set; }
    }
}
