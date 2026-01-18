namespace InventoryManagement.Models.DTOs
{
    public class MmdsDto
    {
        public string MmdId { get; set; }
        public string AccuracyClass { get; set; }
        public string Vendor { get; set; }
        public string ModelNumber { get; set; }
        public string SerialNumber { get; set; }
        public int Quantity { get; set; }
        public string CalibrationStatus { get; set; }
        public DateTime? NextCalibration { get; set; }
        public string Location { get; set; }
        public bool Status { get; set; }
    }
}
