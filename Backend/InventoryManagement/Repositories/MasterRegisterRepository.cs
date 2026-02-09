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

    -- Maintenance Frequency based on type
    CASE
        WHEN m.ItemType = 'Tool' THEN ISNULL(tm.MaintainanceFrequency, '')
        WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.MaintenanceFrequency, '')
        WHEN m.ItemType = 'MMD' THEN ISNULL(mm.CalibrationFrequency, '')
        ELSE ''
    END AS MaintenanceFrequency,

    -- Next Service Due from individual tables (direct from database)
    CASE
        WHEN m.ItemType = 'Tool' THEN tm.NextServiceDue
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.NextServiceDue
        WHEN m.ItemType = 'MMD' THEN mm.NextCalibration
        ELSE NULL
    END AS DirectNextServiceDue,

    -- Latest Service Date from Maintenance table (to calculate next service due)
    maint.ServiceDate AS LatestServiceDate,

    -- Next Service Due from Maintenance table (stored value, may be outdated)
    maint.NextServiceDue AS MaintenanceNextServiceDue,

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

-- LEFT JOIN to get the LATEST maintenance record with ServiceDate for each item
-- Order by ServiceDate DESC to get the absolute latest service, then by CreatedDate DESC
LEFT JOIN (
    SELECT 
        AssetId,
        NextServiceDue,
        ServiceDate,
        CreatedDate,
        ROW_NUMBER() OVER (PARTITION BY AssetId ORDER BY 
            ServiceDate DESC,
            CreatedDate DESC
        ) as rn
    FROM Maintenance 
    WHERE ServiceDate IS NOT NULL
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
    tm.MaintainanceFrequency,
    tm.NextServiceDue,
    ac.AssetName,
    ac.Vendor,
    ac.ResponsibleTeam,
    ac.StorageLocation,
    ac.MaintenanceFrequency,
    ac.NextServiceDue,
    mm.ModelNumber,
    mm.Vendor,
    mm.ResponsibleTeam,
    mm.StorageLocation,
    mm.CalibrationFrequency,
    mm.NextCalibration,
    maint.ServiceDate,
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
                        AvailabilityStatus = row.AvailabilityStatus ?? "Available"
                    };

                    // Calculate Next Service Due with CORRECT FLOW
                    DateTime? nextServiceDue = null;
                    
                    // Check if maintenance frequency exists
                    if (!string.IsNullOrEmpty(row.MaintenanceFrequency))
                    {
                        // RULE 1: If maintenance history exists (LatestServiceDate), calculate from Latest Service Date
                        if (row.LatestServiceDate != null)
                        {
                            nextServiceDue = CalculateNextServiceDate(row.LatestServiceDate, row.MaintenanceFrequency);
                            Console.WriteLine($"DEBUG: Calculated from Latest Service Date for {row.ItemID}: ServiceDate={row.LatestServiceDate:yyyy-MM-dd}, Frequency={row.MaintenanceFrequency}, NextService={nextServiceDue:yyyy-MM-dd}");
                        }
                        // RULE 2: If NO maintenance history, calculate from Created Date
                        else
                        {
                            nextServiceDue = CalculateNextServiceDate(row.CreatedDate, row.MaintenanceFrequency);
                            Console.WriteLine($"DEBUG: Calculated from Created Date for {row.ItemID}: Created={row.CreatedDate:yyyy-MM-dd}, Frequency={row.MaintenanceFrequency}, NextService={nextServiceDue:yyyy-MM-dd}");
                        }
                    }
                    // FALLBACK: Use stored NextServiceDue if no frequency
                    else if (row.DirectNextServiceDue != null)
                    {
                        nextServiceDue = row.DirectNextServiceDue;
                        Console.WriteLine($"DEBUG: Using stored NextServiceDue for {row.ItemID}: {nextServiceDue:yyyy-MM-dd}");
                    }
                    
                    dto.NextServiceDue = nextServiceDue;

                    list.Add(dto);
                }

                Console.WriteLine($" Enhanced Master List: Successfully fetched {list.Count} items with real maintenance/allocation data");
                
                // Log some statistics about the data
                var itemsWithNextServiceDue = list.Count(x => x.NextServiceDue != null);
                var itemsAllocated = list.Count(x => x.AvailabilityStatus != "Available");
                Console.WriteLine($"  - Items with Next Service Due: {itemsWithNextServiceDue}");
                Console.WriteLine($"  - Items currently allocated: {itemsAllocated}");

                return list;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"  Enhanced query failed: {ex.Message}");
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

    -- Maintenance Frequency based on type
    CASE
        WHEN m.ItemType = 'Tool' THEN ISNULL(tm.MaintainanceFrequency, '')
        WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.MaintenanceFrequency, '')
        WHEN m.ItemType = 'MMD' THEN ISNULL(mm.CalibrationFrequency, '')
        ELSE ''
    END AS MaintenanceFrequency,

    -- Next Service Due from individual tables (direct from database)
    CASE
        WHEN m.ItemType = 'Tool' THEN tm.NextServiceDue
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.NextServiceDue
        WHEN m.ItemType = 'MMD' THEN mm.NextCalibration
        ELSE NULL
    END AS DirectNextServiceDue,

    -- Fallback values when maintenance/allocation tables are not available
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
    tm.MaintainanceFrequency,
    tm.NextServiceDue,
    ac.AssetName,
    ac.Vendor,
    ac.ResponsibleTeam,
    ac.StorageLocation,
    ac.MaintenanceFrequency,
    ac.NextServiceDue,
    mm.ModelNumber,
    mm.Vendor,
    mm.ResponsibleTeam,
    mm.StorageLocation,
    mm.CalibrationFrequency,
    mm.NextCalibration

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
                            AvailabilityStatus = row.AvailabilityStatus ?? "Available"
                        };

                        // Calculate Next Service Due with CORRECT FLOW (Fallback mode - no maintenance table)
                        DateTime? nextServiceDue = null;
                        
                        // Check if maintenance frequency exists
                        if (!string.IsNullOrEmpty(row.MaintenanceFrequency))
                        {
                            // In fallback mode, always calculate from Created Date (no maintenance table available)
                            nextServiceDue = CalculateNextServiceDate(row.CreatedDate, row.MaintenanceFrequency);
                            Console.WriteLine($"DEBUG: Fallback - Calculated from Created Date for {row.ItemID}: Created={row.CreatedDate:yyyy-MM-dd}, Frequency={row.MaintenanceFrequency}, NextService={nextServiceDue:yyyy-MM-dd}");
                        }
                        // FALLBACK: Use stored NextServiceDue if no frequency
                        else if (row.DirectNextServiceDue != null)
                        {
                            nextServiceDue = row.DirectNextServiceDue;
                            Console.WriteLine($"DEBUG: Fallback - Using stored NextServiceDue for {row.ItemID}: {nextServiceDue:yyyy-MM-dd}");
                        }
                        dto.NextServiceDue = nextServiceDue;

                        fallbackList.Add(dto);
                    }

                    Console.WriteLine($" Fallback query successful: {fallbackList.Count} items (calculated next service dates from created date + frequency)");
                    return fallbackList;
                }
                catch (Exception fallbackEx)
                {
                    Console.WriteLine($" Fallback query also failed: {fallbackEx.Message}");
                    Console.WriteLine($"Stack trace: {fallbackEx.StackTrace}");
                    return new List<EnhancedMasterListDto>();
                }
            }
        }

        // Helper method to calculate next service date based on frequency
        private DateTime? CalculateNextServiceDate(DateTime createdDate, string maintenanceFrequency)
        {
            if (string.IsNullOrEmpty(maintenanceFrequency))
                return null;

            var frequency = maintenanceFrequency.ToLower().Trim();
            
            return frequency switch
            {
                "daily" => createdDate.AddDays(1),
                "weekly" => createdDate.AddDays(7),
                "monthly" => createdDate.AddMonths(1),
                "quarterly" => createdDate.AddMonths(3),
                "half-yearly" or "halfyearly" => createdDate.AddMonths(6),
                "yearly" or "annual" => createdDate.AddYears(1),
                "2nd year" => createdDate.AddYears(2),
                "3rd year" => createdDate.AddYears(3),
                _ => createdDate.AddYears(1) // Default to yearly
            };
        }

        public async Task<PaginationDto<EnhancedMasterListDto>> GetEnhancedMasterListPaginatedAsync(int pageNumber, int pageSize, string? searchText = null, string? sortColumn = null, string? sortDirection = null)
        {
            var query = @"
WITH MasterData AS (
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

        -- Maintenance Frequency based on type
        CASE
            WHEN m.ItemType = 'Tool' THEN ISNULL(tm.MaintainanceFrequency, '')
            WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.MaintenanceFrequency, '')
            WHEN m.ItemType = 'MMD' THEN ISNULL(mm.CalibrationFrequency, '')
            ELSE ''
        END AS MaintenanceFrequency,

        -- Next Service Due from individual tables
        CASE
            WHEN m.ItemType = 'Tool' THEN tm.NextServiceDue
            WHEN m.ItemType IN ('Asset','Consumable') THEN ac.NextServiceDue
            WHEN m.ItemType = 'MMD' THEN mm.NextCalibration
            ELSE NULL
        END AS DirectNextServiceDue,

        maint.NextServiceDue AS MaintenanceNextServiceDue,

        CASE 
            WHEN alloc.AvailabilityStatus IS NOT NULL THEN alloc.AvailabilityStatus
            WHEN alloc.AssetId IS NOT NULL AND alloc.ActualReturnDate IS NULL THEN 'Allocated'
            ELSE 'Available'
        END AS AvailabilityStatus

    FROM MasterRegister m

    LEFT JOIN ToolsMaster tm ON m.ItemType = 'Tool' AND m.RefId = tm.ToolsId AND tm.Status = 1
    LEFT JOIN AssetsConsumablesMaster ac ON m.ItemType IN ('Asset','Consumable') AND m.RefId = ac.AssetId AND ac.Status = 1
    LEFT JOIN MmdsMaster mm ON m.ItemType = 'MMD' AND m.RefId = mm.MmdId AND mm.Status = 1

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
    AND (@SearchText IS NULL OR @SearchText = '' OR
        m.RefId LIKE '%' + @SearchText + '%' OR
        m.ItemType LIKE '%' + @SearchText + '%' OR
        CASE 
            WHEN m.ItemType = 'Tool' THEN tm.ToolName
            WHEN m.ItemType IN ('Asset','Consumable') THEN ac.AssetName
            WHEN m.ItemType = 'MMD' THEN mm.ModelNumber
            ELSE ''
        END LIKE '%' + @SearchText + '%' OR
        CASE
            WHEN m.ItemType = 'Tool' THEN tm.Vendor
            WHEN m.ItemType IN ('Asset','Consumable') THEN ac.Vendor
            WHEN m.ItemType = 'MMD' THEN mm.Vendor
            ELSE ''
        END LIKE '%' + @SearchText + '%' OR
        CASE
            WHEN m.ItemType = 'Tool' THEN tm.ResponsibleTeam
            WHEN m.ItemType IN ('Asset','Consumable') THEN ac.ResponsibleTeam
            WHEN m.ItemType = 'MMD' THEN mm.ResponsibleTeam
            ELSE ''
        END LIKE '%' + @SearchText + '%' OR
        CASE
            WHEN m.ItemType = 'Tool' THEN tm.StorageLocation
            WHEN m.ItemType IN ('Asset','Consumable') THEN ac.StorageLocation
            WHEN m.ItemType = 'MMD' THEN mm.StorageLocation
            ELSE ''
        END LIKE '%' + @SearchText + '%' OR
        CASE 
            WHEN alloc.AvailabilityStatus IS NOT NULL THEN alloc.AvailabilityStatus
            WHEN alloc.AssetId IS NOT NULL AND alloc.ActualReturnDate IS NULL THEN 'Allocated'
            ELSE 'Available'
        END LIKE '%' + @SearchText + '%' OR
        CONVERT(VARCHAR, CASE
            WHEN m.ItemType = 'Tool' THEN tm.NextServiceDue
            WHEN m.ItemType IN ('Asset','Consumable') THEN ac.NextServiceDue
            WHEN m.ItemType = 'MMD' THEN mm.NextCalibration
            ELSE NULL
        END, 120) LIKE '%' + @SearchText + '%' OR
        CONVERT(VARCHAR, maint.NextServiceDue, 120) LIKE '%' + @SearchText + '%'
    )

    GROUP BY 
        m.RefId, 
        m.ItemType,
        tm.ToolName,
        tm.Vendor,
        tm.ResponsibleTeam,
        tm.StorageLocation,
        tm.MaintainanceFrequency,
        tm.NextServiceDue,
        ac.AssetName,
        ac.Vendor,
        ac.ResponsibleTeam,
        ac.StorageLocation,
        ac.MaintenanceFrequency,
        ac.NextServiceDue,
        mm.ModelNumber,
        mm.Vendor,
        mm.ResponsibleTeam,
        mm.StorageLocation,
        mm.CalibrationFrequency,
        mm.NextCalibration,
        maint.NextServiceDue,
        alloc.AvailabilityStatus,
        alloc.AssetId,
        alloc.ActualReturnDate
)
SELECT 
    ItemID,
    Type,
    ItemName,
    Vendor,
    CreatedDate,
    ResponsibleTeam,
    StorageLocation,
    MaintenanceFrequency,
    DirectNextServiceDue,
    MaintenanceNextServiceDue,
    AvailabilityStatus,
    COUNT(*) OVER() AS TotalCount
FROM MasterData
{ORDER_BY_CLAUSE}
OFFSET @Offset ROWS
FETCH NEXT @PageSize ROWS ONLY;
";

            // Build dynamic ORDER BY clause
            var orderByClause = "ORDER BY CreatedDate DESC"; // Default
            
            if (!string.IsNullOrEmpty(sortColumn))
            {
                var direction = sortDirection?.ToUpper() == "DESC" ? "DESC" : "ASC";
                
                // Map frontend column names to database column names
                var columnMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
                {
                    { "itemId", "ItemID" },
                    { "type", "Type" },
                    { "itemName", "ItemName" },
                    { "vendor", "Vendor" },
                    { "storageLocation", "StorageLocation" },
                    { "responsibleTeam", "ResponsibleTeam" },
                    { "nextServiceDue", "COALESCE(MaintenanceNextServiceDue, DirectNextServiceDue)" },
                    { "availabilityStatus", "AvailabilityStatus" }
                };
                
                if (columnMap.TryGetValue(sortColumn, out var dbColumn))
                {
                    orderByClause = $"ORDER BY {dbColumn} {direction}";
                }
            }
            
            query = query.Replace("{ORDER_BY_CLAUSE}", orderByClause);

            using var connection = _context.CreateConnection();

            try
            {
                var offset = (pageNumber - 1) * pageSize;
                var parameters = new { SearchText = searchText, Offset = offset, PageSize = pageSize };

                var result = await connection.QueryAsync(query, parameters);
                var resultList = result.ToList();

                var totalCount = resultList.FirstOrDefault()?.TotalCount ?? 0;
                var totalPages = (int)Math.Ceiling((double)totalCount / pageSize);

                var items = new List<EnhancedMasterListDto>();

                foreach (var row in resultList)
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
                        AvailabilityStatus = row.AvailabilityStatus ?? "Available"
                    };

                    // Calculate Next Service Due
                    DateTime? nextServiceDue = null;
                    
                    if (!string.IsNullOrEmpty(row.MaintenanceFrequency))
                    {
                        nextServiceDue = CalculateNextServiceDate(row.CreatedDate, row.MaintenanceFrequency);
                    }
                    else if (row.MaintenanceNextServiceDue != null)
                    {
                        nextServiceDue = row.MaintenanceNextServiceDue;
                    }
                    else if (row.DirectNextServiceDue != null)
                    {
                        nextServiceDue = row.DirectNextServiceDue;
                    }
                    
                    dto.NextServiceDue = nextServiceDue;
                    items.Add(dto);
                }

                Console.WriteLine($"✓ Paginated Master List: Page {pageNumber}, Size {pageSize}, Total {totalCount} items");

                return new PaginationDto<EnhancedMasterListDto>
                {
                    TotalCount = totalCount,
                    PageNumber = pageNumber,
                    PageSize = pageSize,
                    TotalPages = totalPages,
                    Items = items
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"⚠️ Pagination query failed: {ex.Message}");
                throw;
            }
        }
    }
}
