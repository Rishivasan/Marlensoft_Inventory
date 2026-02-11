

namespace InventoryManagement.Repositories
{
    using Dapper;
    using InventoryManagement.Models;
    using Microsoft.Data.SqlClient;
    using System.Data;

    public class QualityRepository : IQualityRepository
    {
        private readonly string _connectionString;

        public QualityRepository(IConfiguration config)
        {
            _connectionString = config.GetConnectionString("DefaultConnection");
        }

        private IDbConnection Connection => new SqlConnection(_connectionString);

        public async Task<IEnumerable<FinalProductDto>> GetFinalProducts()
        {
            using var db = Connection;
            return await db.QueryAsync<FinalProductDto>(
                "sp_GetFinalProducts",
                commandType: CommandType.StoredProcedure);
        }

        #region GetMaterialsByProduct
        /// <summary>
        /// 
        /// </summary>
        /// <param name="finalProductId"></param>
        /// <returns></returns>
        public async Task<IEnumerable<MaterialDto>> GetMaterialsByProduct(int finalProductId)
        {
            using var db = Connection;
            return await db.QueryAsync<MaterialDto>(
                "sp_GetMaterialsByFinalProduct",
                new { FinalProductId = finalProductId },
                commandType: CommandType.StoredProcedure);
        }
        #endregion

        public async Task<IEnumerable<ValidationTypeDto>> GetValidationTypes()
        {
            using var db = Connection;
            return await db.QueryAsync<ValidationTypeDto>(
                "sp_GetValidationTypes",
                commandType: CommandType.StoredProcedure);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="templateName"></param>
        /// <param name="validationTypeId"></param>
        /// <param name="finalProductId"></param>
        /// <param name="materialId"></param>
        /// <param name="toolsToQualityCheck"></param>
        /// <returns></returns>
        public async Task<int> CreateQCTemplate(string templateName, int validationTypeId, int finalProductId, int? materialId = null, string? toolsToQualityCheck = null)
        {
            using var db = Connection;

            var parameters = new DynamicParameters();
            parameters.Add("@TemplateName", templateName);
            parameters.Add("@ValidationTypeId", validationTypeId);
            parameters.Add("@FinalProductId", finalProductId);
            parameters.Add("@MaterialId", materialId);
            parameters.Add("@ToolsToQualityCheck", toolsToQualityCheck);
            parameters.Add("@NewTemplateId", dbType: DbType.Int32, direction: ParameterDirection.Output);

            // Execute the stored procedure
            await db.ExecuteAsync(
                "sp_CreateQCTemplate",
                parameters,
                commandType: CommandType.StoredProcedure);

            // Get the output parameter value
            var newTemplateId = parameters.Get<int>("@NewTemplateId");
            
            return newTemplateId;
        }

        public async Task<IEnumerable<QCControlPointDto>> GetControlPoints(int templateId)
        {
            using var db = Connection;
            return await db.QueryAsync<QCControlPointDto>(
                "sp_GetQCControlPointsByTemplate",
                new { QCTemplateId = templateId },
                commandType: CommandType.StoredProcedure);
        }

        public async Task AddControlPoint(QCControlPointDto dto)
        {
            using var db = Connection;

            await db.ExecuteAsync(
                "sp_AddQCControlPoint",
                new
                {
                    dto.QCTemplateId,
                    dto.ControlPointTypeId,
                    dto.ControlPointName,
                    dto.TargetValue,
                    dto.Unit,
                    dto.Tolerance,
                    dto.Instructions,
                    dto.ImagePath,
                    dto.SequenceOrder
                },
                commandType: CommandType.StoredProcedure);
        }

        public async Task DeleteControlPoint(int controlPointId)
        {
            using var db = Connection;

            await db.ExecuteAsync(
                "sp_DeleteQCControlPoint",
                new { QCControlPointId = controlPointId },
                commandType: CommandType.StoredProcedure);
        }
        public async Task<IEnumerable<QCTemplateDto>> GetAllTemplates()
        {
            using var db = Connection;
            return await db.QueryAsync<QCTemplateDto>(
                "sp_GetAllQCTemplates",
                commandType: CommandType.StoredProcedure);
        }

        public async Task<IEnumerable<string>> GetUnits()
        {
            using var db = Connection;
            var units = await db.QueryAsync<UnitDto>(
                "sp_GetUnits",
                commandType: CommandType.StoredProcedure);
            
            // Return only the UnitName values
            return units.Select(u => u.UnitName).Where(name => !string.IsNullOrEmpty(name));
        }

        public async Task<IEnumerable<ControlPointTypeDto>> GetControlPointTypes()
        {
            using var db = Connection;
            return await db.QueryAsync<ControlPointTypeDto>(
                "sp_GetQCControlPointTypes",
                commandType: CommandType.StoredProcedure);
        }


    }

}
