namespace InventoryManagement.Models
{
    public class QCControlPointDto
    {
        public int QCControlPointId { get; set; }
        public int QCTemplateId { get; set; }
        public int ControlPointTypeId { get; set; }
        public string ControlPointName { get; set; }
        public decimal? TargetValue { get; set; }
        public string Unit { get; set; }
        public decimal? Tolerance { get; set; }
        public string Instructions { get; set; }
        public string ImagePath { get; set; }
        public int SequenceOrder { get; set; }
    }

}
