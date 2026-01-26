
    using InventoryManagement.Services.Interfaces;
    using Microsoft.AspNetCore.Mvc;
    using InventoryManagement.Models.Entities;
 

namespace InventoryManagement.Controllers
{
    [ApiController]
        public class ToolsController : ControllerBase
        {
            private readonly IToolService _service;

            public ToolsController(IToolService service)
            {
                _service = service;
            }

            [HttpGet("api/tools")]
     
        public async Task<IActionResult> GetTools()
            {
                return Ok(await _service.GetToolsAsync());
            
            }

        [HttpPost("api/addtools")]
        public async Task<IActionResult> CreateTool([FromBody] ToolEntity tool)
        {
            var success = await _service.CreateToolAsync(tool);
            if (!success) return BadRequest("Insert failed");

            return Ok("Tool created successfully");
        }

        [HttpDelete("api/Tools/{id}")]
        public async Task<IActionResult> DeleteTool(string id)
        {
            var success = await _service.DeleteToolAsync(id);
            if (!success) return NotFound("Tool not found or delete failed");

            return Ok("Tool deleted successfully");
        }

        //// PUT: api/tools/{id}
        //[HttpPut("{id}")("api/updatetools")]
       
        //public async Task<IActionResult> UpdateTool(string id, [FromBody] ToolEntity tool)
        //{
        //    tool.ToolsId = id;

        //    var success = await _service.UpdateToolAsync(tool);
        //    if (!success) return NotFound("Tool not found");

        //    return Ok("Tool updated successfully");
        //}
    }
    }


