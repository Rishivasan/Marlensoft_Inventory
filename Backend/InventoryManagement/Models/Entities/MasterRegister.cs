namespace InventoryManagement.Models.Entities
{
    public class MasterRegister
    {
        public int SNo { get; set; }
        public string ItemType { get; set; } = string.Empty;
        public string RefId { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }
    }
}
