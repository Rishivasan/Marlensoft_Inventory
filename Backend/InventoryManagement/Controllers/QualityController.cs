namespace InventoryManagement.Controllers
{
    using InventoryManagement.Models;
    using InventoryManagement.Services;
    using Microsoft.AspNetCore.Mvc;

    [Route("api/quality")]
    [ApiController]
    public class QualityController : ControllerBase
    {
        private readonly IQualityService _service;

        public QualityController(IQualityService service)
        {
            _service = service;
        }

        [HttpGet("final-products")]
        public async Task<IActionResult> GetFinalProducts()
        {
            var data = await _service.GetFinalProducts();
            return Ok(data);
        }

        [HttpGet("materials/{productId}")]
        public async Task<IActionResult> GetMaterials(int productId)
        {
            var data = await _service.GetMaterialsByProduct(productId);
            return Ok(data);
        }

        [HttpGet("validation-types")]
        public async Task<IActionResult> GetValidationTypes()
        {
            var data = await _service.GetValidationTypes();
            return Ok(data);
        }

        [HttpPost("template")]
        public async Task<IActionResult> CreateTemplate([FromBody] QCTemplateDto dto)
        {
            int templateId = await _service.CreateTemplate(dto);
            return Ok(new { templateId });
        }

        [HttpPost("control-point")]
        public async Task<IActionResult> AddControlPoint([FromBody] QCControlPointDto dto)
        {
            await _service.AddControlPoint(dto);
            return Ok("Control point added");
        }

        [HttpGet("control-points/{templateId}")]
        public async Task<IActionResult> GetControlPoints(int templateId)
        {
            var data = await _service.GetControlPoints(templateId);
            return Ok(data);
        }

        [HttpDelete("control-point/{id}")]
        public async Task<IActionResult> DeleteControlPoint(int id)
        {
            await _service.DeleteControlPoint(id);
            return Ok("Deleted");
        }

        [HttpGet("templates")]
        public async Task<IActionResult> GetTemplates()
        {
            var data = await _service.GetAllTemplates();
            return Ok(data);
        }

        [HttpGet("units")]
        public async Task<IActionResult> GetUnits()
        {
            var data = await _service.GetUnits();
            return Ok(data);
        }

        [HttpGet("control-point-types")]
        public async Task<IActionResult> GetControlPointTypes()
        {
            var data = await _service.GetControlPointTypes();
            return Ok(data);
        }


    }

}
