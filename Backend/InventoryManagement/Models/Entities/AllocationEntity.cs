namespace InventoryManagement.Models.Entities
{
    public class AllocationEntity
    {
        public int AllocationId { get; set; }
        public string AssetType { get; set; }
        public string AssetId { get; set; }
        public string ItemName { get; set; }
        public string EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public string TeamName { get; set; }
        public string Purpose { get; set; }
        public DateTime? IssuedDate { get; set; }
        public DateTime? ExpectedReturnDate { get; set; }
        public DateTime? ActualReturnDate { get; set; }
        public string AvailabilityStatus { get; set; }
        public DateTime CreatedDate { get; set; }
    }
}
