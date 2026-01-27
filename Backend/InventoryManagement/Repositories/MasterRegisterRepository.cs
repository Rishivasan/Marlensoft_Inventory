//using Dapper;
//using InventoryManagement.Data;
//using InventoryManagement.Models.DTOs;
//using InventoryManagement.Repositories.Interfaces;

//namespace InventoryManagement.Repositories
//{
//    public class MasterRegisterRepository : IMasterRegisterRepository
//    {
//        private readonly DapperContext _context;

//        public MasterRegisterRepository(DapperContext context)
//        {
//            _context = context;
//        }

//        public async Task<List<MasterListDto>> GetMasterListAsync()
//        {
//            var query = @"
//SELECT
//    m.SNo,
//    m.ItemType,
//    m.RefId,
//    m.CreatedDate,

//    -- Tool fields
//    tm.ToolsId       AS ToolId,
//    tm.ToolName      AS ToolName,
//    tm.ToolType      AS ToolType,
//    tm.VendorName    AS ToolVendor,
//    tm.StorageLocation AS ToolLocation,

//    -- Asset / Consumable fields
//    ac.AssetId       AS AssetId,
//    ac.AssetName     AS AssetName,
//    ac.Category      AS AssetCategory,
//    ac.Vendor        AS AssetVendor,
//    ac.StorageLocation AS AssetLocation,

//    -- MMD fields
//    mm.MmdId         AS MmdId,
//    mm.Specifications AS MmdType,
//    mm.Vendor        AS MmdVendor,
//    mm.Location      AS MmdLocation

//FROM MasterRegister m

//LEFT JOIN ToolsMaster tm
//    ON m.ItemType = 'Tool' AND m.RefId = tm.ToolsId

//LEFT JOIN AssetsConsumablesMaster ac
//    ON m.ItemType IN ('Asset','Consumable') AND m.RefId = ac.AssetId

//LEFT JOIN MmdsMaster mm
//    ON m.ItemType = 'MMD' AND m.RefId = mm.MmdId

//WHERE m.IsActive = 1
//ORDER BY m.SNo DESC;



//";

//            using var connection = _context.CreateConnection();

//            var result = await connection.QueryAsync(query);

//            var list = new List<MasterListDto>();

//            foreach (var row in result)
//            {
//                var dto = new MasterListDto
//                {
//                    SNo = row.SNo,
//                    ItemType = row.ItemType,
//                    RefId = row.RefId,
//                    CreatedDate = row.CreatedDate,

//                    DisplayId = row.RefId,
//                    Name = "",
//                    Type = row.ItemType,
//                    Supplier = "",
//                    Location = ""
//                };

//                if (row.ItemType == "Tool")
//                {
//                    dto.Name = row.ToolName ?? "";
//                    dto.Type = row.ToolType ?? "Tool";
//                    dto.Supplier = row.VendorName ?? "";
//                    dto.Location = row.StorageLocation ?? "";
//                }
//                else if (row.ItemType == "Asset")
//                {
//                    dto.Name = row.AssetName ?? "";
//                    dto.Type = row.Category ?? "Asset";
//                    dto.Supplier = row.Vendor ?? "";
//                    dto.Location = row.StorageLocation ?? "";
//                }
//                else if (row.ItemType == "Consumable")
//                {
//                    dto.Name = row.AssetName ?? "";
//                    dto.Type = "Consumable";
//                    dto.Supplier = row.Vendor ?? "";
//                    dto.Location = row.StorageLocation ?? "";
//                }
//                else if (row.ItemType == "MMD")
//                {
//                    dto.Name = row.ModelNumber ?? "";
//                    dto.Type = "MMD";
//                    dto.Supplier = row.Vendor ?? "";
//                    dto.Location = row.Location ?? "";
//                }

//                list.Add(dto);
//            }

//            return list;

//        } 
//    }
//   }


using Dapper;
using InventoryManagement.Data;
using InventoryManagement.Models.DTOs;
using InventoryManagement.Repositories.Interfaces;

namespace InventoryManagement.Repositories
{
    public class MasterRegisterRepository : IMasterRegisterRepository
    {
        private readonly DapperContext _context;

        public MasterRegisterRepository(DapperContext context)
        {
            _context = context;
        }

        public async Task<List<MasterListDto>> GetMasterListAsync()
        {
            var query = @"
SELECT
    m.SNo,
    m.ItemType,
    m.RefId,
    m.CreatedDate,

    -- FINAL DISPLAY FIELDS
    CASE 
        WHEN m.ItemType = 'Tool' THEN tm.ToolName
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.AssetName
        WHEN m.ItemType = 'MMD' THEN mm.ModelNumber
        ELSE ''
    END AS Name,

    CASE
        WHEN m.ItemType = 'Tool' THEN tm.ToolType
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.Category
        WHEN m.ItemType = 'MMD' THEN mm.Specifications
        ELSE m.ItemType
    END AS Type,

    CASE
        WHEN m.ItemType = 'Tool' THEN tm.Vendor
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.Vendor
        WHEN m.ItemType = 'MMD' THEN mm.Vendor
        ELSE ''
    END AS Supplier,

    CASE
        WHEN m.ItemType = 'Tool' THEN tm.StorageLocation
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.StorageLocation
        WHEN m.ItemType = 'MMD' THEN mm.StorageLocation
        ELSE ''
    END AS Location

FROM MasterRegister m

LEFT JOIN ToolsMaster tm
    ON m.ItemType = 'Tool' AND m.RefId = tm.ToolsId

LEFT JOIN AssetsConsumablesMaster ac
    ON m.ItemType IN ('Asset','Consumable') AND m.RefId = ac.AssetId

LEFT JOIN MmdsMaster mm
    ON m.ItemType = 'MMD' AND m.RefId = mm.MmdId

WHERE m.IsActive = 1
ORDER BY m.SNo DESC;

";

            using var connection = _context.CreateConnection();

            // dynamic result
            var result = await connection.QueryAsync(query);

            var list = new List<MasterListDto>();

            foreach (var row in result)
            {
                var dto = new MasterListDto
                {
                    SNo = row.SNo,
                    ItemType = row.ItemType,
                    RefId = row.RefId,
                    CreatedDate = row.CreatedDate,

                    DisplayId = row.RefId,
                    Name = "",
                    Type = row.ItemType,
                    Supplier = "",
                    Location = ""
                };

                // TOOL
                if (row.ItemType == "Tool")
                {
                    dto.Name = row.ToolName ?? "";
                    dto.Type = row.ToolType ?? "Tool";
                    dto.Supplier = row.ToolVendor ?? "";
                    dto.Location = row.ToolLocation ?? "";
                }
                // ASSET
                else if (row.ItemType == "Asset")
                {
                    dto.Name = row.AssetName ?? "";
                    dto.Type = row.AssetCategory ?? "Asset";
                    dto.Supplier = row.AssetVendor ?? "";
                    dto.Location = row.AssetLocation ?? "";
                }
                // CONSUMABLE
                else if (row.ItemType == "Consumable")
                {
                    dto.Name = row.AssetName ?? "";
                    dto.Type = "Consumable";
                    dto.Supplier = row.AssetVendor ?? "";
                    dto.Location = row.AssetLocation ?? "";
                }
                // MMD
                else if (row.ItemType == "MMD")
                {
                    dto.Name = row.MmdModelNumber ?? "";
                    dto.Type = row.MmdType ?? "MMD";
                    dto.Supplier = row.MmdVendor ?? "";
                    dto.Location = row.MmdLocation ?? "";
                }

                list.Add(dto);
            }

            return list;
        }

        public async Task<List<EnhancedMasterListDto>> GetEnhancedMasterListAsync()
        {
            var query = @"
SELECT
    m.RefId AS ItemID,
    m.ItemType AS Type,
    
    -- Item Name based on type
    CASE 
        WHEN m.ItemType = 'Tool' THEN tm.ToolName
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.AssetName
        WHEN m.ItemType = 'MMD' THEN mm.ModelNumber
        ELSE ''
    END AS ItemName,

    -- Vendor based on type
    CASE
        WHEN m.ItemType = 'Tool' THEN tm.Vendor
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.Vendor
        WHEN m.ItemType = 'MMD' THEN mm.Vendor
        ELSE ''
    END AS Vendor,

    m.CreatedDate,

    -- Responsible Team based on type
    CASE
        WHEN m.ItemType = 'Tool' THEN tm.ResponsibleTeam
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.ResponsibleTeam
        WHEN m.ItemType = 'MMD' THEN mm.ResponsibleTeam
        ELSE ''
    END AS ResponsibleTeam,

    -- Storage Location based on type
    CASE
        WHEN m.ItemType = 'Tool' THEN tm.StorageLocation
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.StorageLocation
        WHEN m.ItemType = 'MMD' THEN mm.StorageLocation
        ELSE ''
    END AS StorageLocation,

    -- Next Service Due from latest maintenance record
    maint.NextServiceDue,

    -- Availability Status from latest allocation record
    COALESCE(alloc.AvailabilityStatus, 'Available') AS AvailabilityStatus

FROM MasterRegister m

LEFT JOIN ToolsMaster tm
    ON m.ItemType = 'Tool' AND m.RefId = tm.ToolsId

LEFT JOIN AssetsConsumablesMaster ac
    ON m.ItemType IN ('Asset','Consumable') AND m.RefId = ac.AssetId

LEFT JOIN MmdsMaster mm
    ON m.ItemType = 'MMD' AND m.RefId = mm.MmdId

-- Get latest maintenance record for NextServiceDue
LEFT JOIN (
    SELECT 
        AssetType,
        AssetId,
        NextServiceDue,
        ROW_NUMBER() OVER (PARTITION BY AssetType, AssetId ORDER BY ServiceDate DESC) as rn
    FROM MaintenanceRecords
    WHERE Status = 1 AND NextServiceDue IS NOT NULL
) maint ON maint.AssetType = m.ItemType AND maint.AssetId = m.RefId AND maint.rn = 1

-- Get latest allocation record for AvailabilityStatus
LEFT JOIN (
    SELECT 
        AssetType,
        AssetId,
        AvailabilityStatus,
        ROW_NUMBER() OVER (PARTITION BY AssetType, AssetId ORDER BY IssuedDate DESC) as rn
    FROM AllocationRecords
    WHERE Status = 1
) alloc ON alloc.AssetType = m.ItemType AND alloc.AssetId = m.RefId AND alloc.rn = 1

WHERE m.IsActive = 1
ORDER BY m.SNo DESC;
";

            using var connection = _context.CreateConnection();
            var result = await connection.QueryAsync(query);

            var list = new List<EnhancedMasterListDto>();

            foreach (var row in result)
            {
                var dto = new EnhancedMasterListDto
                {
                    ItemID = row.ItemID ?? "",
                    Type = row.Type ?? "",
                    ItemName = row.ItemName ?? "",
                    Vendor = row.Vendor ?? "",
                    CreatedDate = row.CreatedDate,
                    ResponsibleTeam = row.ResponsibleTeam ?? "",
                    StorageLocation = row.StorageLocation ?? "",
                    NextServiceDue = row.NextServiceDue,
                    AvailabilityStatus = row.AvailabilityStatus ?? "Available"
                };

                list.Add(dto);
            }

            return list;
        }
    }
}
