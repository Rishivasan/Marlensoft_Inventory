namespace InventoryManagement.Models
{
    public class QCTemplateDto
    {
        public int QCTemplateId { get; set; }
        public string TemplateName { get; set; }
        public int ValidationTypeId { get; set; }
        public string ProductName { get; set; }
        public int FinalProductId { get; set; }
        public int? MaterialId { get; set; }
        public string? ToolsToQualityCheck { get; set; }
    }

}
