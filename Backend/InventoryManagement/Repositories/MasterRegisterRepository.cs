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
    ON m.ItemType = 'Tool' AND m.RefId = tm.ToolsId AND tm.Status = 1

LEFT JOIN AssetsConsumablesMaster ac
    ON m.ItemType IN ('Asset','Consumable') AND m.RefId = ac.AssetId AND ac.Status = 1

LEFT JOIN MmdsMaster mm
    ON m.ItemType = 'MMD' AND m.RefId = mm.MmdId AND mm.Status = 1

WHERE (
    (m.ItemType = 'Tool' AND tm.ToolsId IS NOT NULL) OR
    (m.ItemType IN ('Asset','Consumable') AND ac.AssetId IS NOT NULL) OR
    (m.ItemType = 'MMD' AND mm.MmdId IS NOT NULL)
)
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
            // Enhanced query to fetch real maintenance and allocation data
            var query = @"
SELECT DISTINCT
    m.RefId AS ItemID,
    m.ItemType AS Type,
    
    -- Item Name based on type
    CASE 
        WHEN m.ItemType = 'Tool' THEN ISNULL(tm.ToolName, 'Tool-' + m.RefId)
        WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.AssetName, 'Asset-' + m.RefId)
        WHEN m.ItemType = 'MMD' THEN ISNULL(mm.ModelNumber, 'MMD-' + m.RefId)
        ELSE m.RefId
    END AS ItemName,

    -- Vendor based on type
    CASE
        WHEN m.ItemType = 'Tool' THEN ISNULL(tm.Vendor, '')
        WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.Vendor, '')
        WHEN m.ItemType = 'MMD' THEN ISNULL(mm.Vendor, '')
        ELSE ''
    END AS Vendor,

    -- Use MAX to get the latest CreatedDate for duplicates
    MAX(m.CreatedDate) AS CreatedDate,

    -- Responsible Team based on type
    CASE
        WHEN m.ItemType = 'Tool' THEN ISNULL(tm.ResponsibleTeam, '')
        WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.ResponsibleTeam, '')
        WHEN m.ItemType = 'MMD' THEN ISNULL(mm.ResponsibleTeam, '')
        ELSE ''
    END AS ResponsibleTeam,

    -- Storage Location based on type
    CASE
        WHEN m.ItemType = 'Tool' THEN ISNULL(tm.StorageLocation, '')
        WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.StorageLocation, '')
        WHEN m.ItemType = 'MMD' THEN ISNULL(mm.StorageLocation, '')
        ELSE ''
    END AS StorageLocation,

    -- REAL Next Service Due from Maintenance table (get the latest/most recent NextServiceDue for each item)
    maint.NextServiceDue,

    -- REAL Availability Status from Allocation table (determine current status based on allocation records)
    CASE 
        WHEN alloc.AvailabilityStatus IS NOT NULL THEN alloc.AvailabilityStatus
        WHEN alloc.AssetId IS NOT NULL AND alloc.ActualReturnDate IS NULL THEN 'Allocated'
        ELSE 'Available'
    END AS AvailabilityStatus

FROM MasterRegister m

LEFT JOIN ToolsMaster tm ON m.ItemType = 'Tool' AND m.RefId = tm.ToolsId AND tm.Status = 1
LEFT JOIN AssetsConsumablesMaster ac ON m.ItemType IN ('Asset','Consumable') AND m.RefId = ac.AssetId AND ac.Status = 1
LEFT JOIN MmdsMaster mm ON m.ItemType = 'MMD' AND m.RefId = mm.MmdId AND mm.Status = 1

-- LEFT JOIN to get the LATEST maintenance record with NextServiceDue for each item
-- Order by CreatedDate DESC to get the absolute latest record, then by ServiceDate DESC
LEFT JOIN (
    SELECT 
        AssetId,
        NextServiceDue,
        ServiceDate,
        CreatedDate,
        ROW_NUMBER() OVER (PARTITION BY AssetId ORDER BY 
            CreatedDate DESC,
            ServiceDate DESC,
            CASE WHEN NextServiceDue IS NOT NULL THEN 1 ELSE 0 END DESC
        ) as rn
    FROM Maintenance 
) maint ON m.RefId = maint.AssetId AND maint.rn = 1

-- LEFT JOIN to get the CURRENT allocation status for each item
-- Order by CreatedDate DESC to get the absolute latest record, then by IssuedDate DESC
LEFT JOIN (
    SELECT 
        AssetId,
        AvailabilityStatus,
        ActualReturnDate,
        IssuedDate,
        CreatedDate,
        ROW_NUMBER() OVER (PARTITION BY AssetId ORDER BY 
            CreatedDate DESC,
            IssuedDate DESC
        ) as rn
    FROM Allocation
) alloc ON m.RefId = alloc.AssetId AND alloc.rn = 1

WHERE (
    (m.ItemType = 'Tool' AND tm.ToolsId IS NOT NULL) OR
    (m.ItemType IN ('Asset','Consumable') AND ac.AssetId IS NOT NULL) OR
    (m.ItemType = 'MMD' AND mm.MmdId IS NOT NULL)
  )

GROUP BY 
    m.RefId, 
    m.ItemType,
    tm.ToolName,
    tm.Vendor,
    tm.ResponsibleTeam,
    tm.StorageLocation,
    ac.AssetName,
    ac.Vendor,
    ac.ResponsibleTeam,
    ac.StorageLocation,
    mm.ModelNumber,
    mm.Vendor,
    mm.ResponsibleTeam,
    mm.StorageLocation,
    maint.NextServiceDue,
    alloc.AvailabilityStatus,
    alloc.AssetId,
    alloc.ActualReturnDate

ORDER BY MAX(m.CreatedDate) DESC;
";

            using var connection = _context.CreateConnection();
            
            try
            {
                // Try the enhanced query with real maintenance and allocation data first
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

                Console.WriteLine($"✓ Enhanced Master List: Successfully fetched {list.Count} items with real maintenance/allocation data");
                
                // Log some statistics about the data
                var itemsWithNextServiceDue = list.Count(x => x.NextServiceDue != null);
                var itemsAllocated = list.Count(x => x.AvailabilityStatus != "Available");
                Console.WriteLine($"  - Items with Next Service Due: {itemsWithNextServiceDue}");
                Console.WriteLine($"  - Items currently allocated: {itemsAllocated}");

                return list;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"⚠️  Enhanced query failed: {ex.Message}");
                Console.WriteLine("Falling back to simplified query without maintenance/allocation data...");
                
                // Fallback to simplified query without maintenance/allocation joins
                var fallbackQuery = @"
SELECT DISTINCT
    m.RefId AS ItemID,
    m.ItemType AS Type,
    
    -- Item Name based on type
    CASE 
        WHEN m.ItemType = 'Tool' THEN ISNULL(tm.ToolName, 'Tool-' + m.RefId)
        WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.AssetName, 'Asset-' + m.RefId)
        WHEN m.ItemType = 'MMD' THEN ISNULL(mm.ModelNumber, 'MMD-' + m.RefId)
        ELSE m.RefId
    END AS ItemName,

    -- Vendor based on type
    CASE
        WHEN m.ItemType = 'Tool' THEN ISNULL(tm.Vendor, '')
        WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.Vendor, '')
        WHEN m.ItemType = 'MMD' THEN ISNULL(mm.Vendor, '')
        ELSE ''
    END AS Vendor,

    -- Use MAX to get the latest CreatedDate for duplicates
    MAX(m.CreatedDate) AS CreatedDate,

    -- Responsible Team based on type
    CASE
        WHEN m.ItemType = 'Tool' THEN ISNULL(tm.ResponsibleTeam, '')
        WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.ResponsibleTeam, '')
        WHEN m.ItemType = 'MMD' THEN ISNULL(mm.ResponsibleTeam, '')
        ELSE ''
    END AS ResponsibleTeam,

    -- Storage Location based on type
    CASE
        WHEN m.ItemType = 'Tool' THEN ISNULL(tm.StorageLocation, '')
        WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.StorageLocation, '')
        WHEN m.ItemType = 'MMD' THEN ISNULL(mm.StorageLocation, '')
        ELSE ''
    END AS StorageLocation,

    -- Fallback values when maintenance/allocation tables are not available
    NULL AS NextServiceDue,
    'Available' AS AvailabilityStatus

FROM MasterRegister m

LEFT JOIN ToolsMaster tm ON m.ItemType = 'Tool' AND m.RefId = tm.ToolsId AND tm.Status = 1
LEFT JOIN AssetsConsumablesMaster ac ON m.ItemType IN ('Asset','Consumable') AND m.RefId = ac.AssetId AND ac.Status = 1
LEFT JOIN MmdsMaster mm ON m.ItemType = 'MMD' AND m.RefId = mm.MmdId AND mm.Status = 1

WHERE (
    (m.ItemType = 'Tool' AND tm.ToolsId IS NOT NULL) OR
    (m.ItemType IN ('Asset','Consumable') AND ac.AssetId IS NOT NULL) OR
    (m.ItemType = 'MMD' AND mm.MmdId IS NOT NULL)
  )

GROUP BY 
    m.RefId, 
    m.ItemType,
    tm.ToolName,
    tm.Vendor,
    tm.ResponsibleTeam,
    tm.StorageLocation,
    ac.AssetName,
    ac.Vendor,
    ac.ResponsibleTeam,
    ac.StorageLocation,
    mm.ModelNumber,
    mm.Vendor,
    mm.ResponsibleTeam,
    mm.StorageLocation

ORDER BY MAX(m.CreatedDate) DESC;
";

                try
                {
                    var fallbackResult = await connection.QueryAsync(fallbackQuery);
                    var fallbackList = new List<EnhancedMasterListDto>();

                    foreach (var row in fallbackResult)
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

                        fallbackList.Add(dto);
                    }

                    Console.WriteLine($"✓ Fallback query successful: {fallbackList.Count} items (without maintenance/allocation data)");
                    return fallbackList;
                }
                catch (Exception fallbackEx)
                {
                    Console.WriteLine($"❌ Fallback query also failed: {fallbackEx.Message}");
                    Console.WriteLine($"Stack trace: {fallbackEx.StackTrace}");
                    return new List<EnhancedMasterListDto>();
                }
            }
        }
    }
}
