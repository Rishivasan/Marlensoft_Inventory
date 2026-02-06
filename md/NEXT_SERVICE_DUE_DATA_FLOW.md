# Next Service Due - Complete Data Flow Documentation

## Table of Contents
1. [Flow 1: Creating a New Item](#flow-1-creating-a-new-item)
2. [Flow 2: Viewing Master List](#flow-2-viewing-master-list)
3. [Flow 3: Opening Maintenance Service Form](#flow-3-opening-maintenance-service-form)
4. [Flow 4: Submitting Maintenance Service](#flow-4-submitting-maintenance-service)
5. [Flow 5: Real-time UI Updates](#flow-5-real-time-ui-updates)

---

## Flow 1: Creating a New Item

### Example: Creating a New Tool
**User Action:** User fills out "Add Tool" form and clicks Submit

### Step-by-Step Data Flow

#### Step 1: User Fills Form
**File:** `Frontend/inventory/lib/screens/add_forms/add_tool.dart`

**User Inputs:**
```
Tool Name: "Hydraulic Press"
Tool Type: "Heavy Machinery"
Maintenance Frequency: "Monthly"
Created Date: 2026-02-02
... (other fields)
```

**Method Triggered:** `_submitForm()`

---

#### Step 2: Form Validation
**File:** `Frontend/inventory/lib/screens/add_forms/add_tool.dart`

**Code:**
```dart
if (!_formKey.currentState!.validate()) {
  return; // Stop if validation fails
}
```

**What Happens:**
- Validates all required fields
- Checks data formats
- If validation fails, shows error messages

---

#### Step 3: Prepare Data for API
**File:** `Frontend/inventory/lib/screens/add_forms/add_tool.dart`

**Code:**
```dart
final toolData = {
  'ToolsId': 'T123',
  'ToolName': 'Hydraulic Press',
  'ToolType': 'Heavy Machinery',
  'MaintainanceFrequency': 'Monthly',
  'CreatedDate': '2026-02-02T00:00:00Z',
  'Status': true,
  // ... other fields
};
```

**What Happens:**
- Collects all form data
- Formats dates to ISO 8601
- Creates JSON object


#### Step 4: Send to Backend API
**File:** `Frontend/inventory/lib/services/api_service.dart`

**Method Called:** `addTool(toolData)`

**Code:**
```dart
final response = await _dio.post(
  '/api/Tools',
  data: toolData,
);
```

**HTTP Request:**
```
POST http://localhost:5069/api/Tools
Content-Type: application/json

{
  "ToolsId": "T123",
  "ToolName": "Hydraulic Press",
  "MaintainanceFrequency": "Monthly",
  "CreatedDate": "2026-02-02T00:00:00Z",
  ...
}
```

---

#### Step 5: Backend Receives Request
**File:** `Backend/InventoryManagement/Controllers/ToolsController.cs`

**Method:** `AddTool([FromBody] ToolEntity tool)`

**What Happens:**
1. Receives JSON data
2. Deserializes to ToolEntity object
3. Validates data

---

#### Step 6: Save to Database
**File:** `Backend/InventoryManagement/Repositories/ToolRepository.cs`

**SQL Query Executed:**
```sql
INSERT INTO ToolsMaster (
  ToolsId,
  ToolName,
  ToolType,
  MaintainanceFrequency,
  CreatedDate,
  Status,
  NextServiceDue  -- Initially NULL
  ...
)
VALUES (
  'T123',
  'Hydraulic Press',
  'Heavy Machinery',
  'Monthly',
  '2026-02-02',
  1,
  NULL  -- Will be calculated later
  ...
)
```

**Database State:**
```
ToolsMaster Table:
┌─────────┬──────────────────┬──────────┬─────────────────────┬─────────────┬────────────────┐
│ ToolsId │ ToolName         │ ToolType │ Maintainance...     │ CreatedDate │ NextServiceDue │
├─────────┼──────────────────┼──────────┼─────────────────────┼─────────────┼────────────────┤
│ T123    │ Hydraulic Press  │ Heavy... │ Monthly             │ 2026-02-02  │ NULL           │
└─────────┴──────────────────┴──────────┴─────────────────────┴─────────────┴────────────────┘
```

---

#### Step 7: Calculate Next Service Due (Backend)
**File:** `Backend/InventoryManagement/Repositories/MasterRegisterRepository.cs`

**Method:** `CalculateNextServiceDate(createdDate, maintenanceFrequency)`

**Code:**
```csharp
private DateTime? CalculateNextServiceDate(DateTime createdDate, string maintenanceFrequency)
{
    var frequency = maintenanceFrequency.ToLower().Trim();
    
    return frequency switch
    {
        "monthly" => createdDate.AddMonths(1),  // 2026-02-02 + 1 month = 2026-03-02
        "quarterly" => createdDate.AddMonths(3),
        "yearly" => createdDate.AddYears(1),
        // ... other frequencies
        _ => createdDate.AddYears(1)
    };
}
```

**Calculation:**
```
Input:
  Created Date: 2026-02-02
  Frequency: Monthly

Calculation:
  2026-02-02 + 1 month = 2026-03-02

Output:
  Next Service Due: 2026-03-02
```


#### Step 8: Return Success Response
**File:** `Backend/InventoryManagement/Controllers/ToolsController.cs`

**HTTP Response:**
```
Status: 200 OK
Content-Type: application/json

{
  "message": "Tool added successfully",
  "toolId": "T123"
}
```

---

#### Step 9: Frontend Receives Success
**File:** `Frontend/inventory/lib/screens/add_forms/add_tool.dart`

**Code:**
```dart
if (response.statusCode == 200) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Tool added successfully!')),
  );
  Navigator.of(context).pop(); // Close form
}
```

**What Happens:**
- Shows success message
- Closes the form
- Returns to previous screen

---

### Summary of Flow 1
```
User Input → Form Validation → API Call → Backend Controller → Database Insert
→ Success Response → UI Update → Form Closes
```

**Database State After Creation:**
```
ToolsMaster Table:
┌─────────┬──────────────────┬──────────┬─────────────────────┬─────────────┬────────────────┐
│ ToolsId │ ToolName         │ ToolType │ Maintainance...     │ CreatedDate │ NextServiceDue │
├─────────┼──────────────────┼──────────┼─────────────────────┼─────────────┼────────────────┤
│ T123    │ Hydraulic Press  │ Heavy... │ Monthly             │ 2026-02-02  │ NULL           │
└─────────┴──────────────────┴──────────┴─────────────────────┴─────────────┴────────────────┘

Note: NextServiceDue is NULL initially, will be calculated when Master List loads
```

---

## Flow 2: Viewing Master List

### Example: User Opens Master List Screen
**User Action:** User navigates to Master List screen

### Step-by-Step Data Flow

#### Step 1: Screen Initialization
**File:** `Frontend/inventory/lib/screens/master_list.dart`

**Widget:** `MasterListScreen`

**Code:**
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final masterListAsync = ref.watch(masterListProvider);
  // ...
}
```

**What Happens:**
- Screen builds
- Watches masterListProvider
- Triggers data fetch

---

#### Step 2: Provider Fetches Data
**File:** `Frontend/inventory/lib/providers/master_list_provider.dart`

**Provider:** `masterListProvider`

**Code:**
```dart
final masterListProvider = FutureProvider<List<MasterListModel>>((ref) async {
  final service = MasterListService();
  return await service.fetchEnhancedMasterList();
});
```

**What Happens:**
- Creates MasterListService instance
- Calls fetchEnhancedMasterList()


#### Step 3: Service Makes API Call
**File:** `Frontend/inventory/lib/services/master_list_service.dart`

**Method:** `fetchEnhancedMasterList()`

**Code:**
```dart
Future<List<MasterListModel>> fetchEnhancedMasterList() async {
  final response = await _dio.get('/api/ItemDetailsV2/enhanced-master-list');
  
  List<MasterListModel> items = [];
  for (var item in response.data) {
    items.add(MasterListModel.fromJson(item));
  }
  return items;
}
```

**HTTP Request:**
```
GET http://localhost:5069/api/ItemDetailsV2/enhanced-master-list
```

---

#### Step 4: Backend Receives Request
**File:** `Backend/InventoryManagement/Controllers/ItemDetailsV2Controller.cs`

**Method:** `GetEnhancedMasterList()`

**Code:**
```csharp
[HttpGet("enhanced-master-list")]
public async Task<IActionResult> GetEnhancedMasterList()
{
    var items = await _masterRegisterRepository.GetEnhancedMasterListAsync();
    return Ok(items);
}
```

---

#### Step 5: Repository Executes Query
**File:** `Backend/InventoryManagement/Repositories/MasterRegisterRepository.cs`

**Method:** `GetEnhancedMasterListAsync()`

**SQL Query:**
```sql
SELECT DISTINCT
    m.RefId AS ItemID,
    m.ItemType AS Type,
    
    -- Item Name based on type
    CASE 
        WHEN m.ItemType = 'Tool' THEN ISNULL(tm.ToolName, 'Tool-' + m.RefId)
        WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.AssetName, 'Asset-' + m.RefId)
        WHEN m.ItemType = 'MMD' THEN ISNULL(mm.ModelNumber, 'MMD-' + m.RefId)
    END AS ItemName,
    
    -- Vendor, CreatedDate, ResponsibleTeam, StorageLocation...
    
    -- Maintenance Frequency
    CASE
        WHEN m.ItemType = 'Tool' THEN ISNULL(tm.MaintainanceFrequency, '')
        WHEN m.ItemType IN ('Asset','Consumable') THEN ISNULL(ac.MaintenanceFrequency, '')
        WHEN m.ItemType = 'MMD' THEN ISNULL(mm.CalibrationFrequency, '')
    END AS MaintenanceFrequency,
    
    -- Next Service Due from tables
    CASE
        WHEN m.ItemType = 'Tool' THEN tm.NextServiceDue
        WHEN m.ItemType IN ('Asset','Consumable') THEN ac.NextServiceDue
        WHEN m.ItemType = 'MMD' THEN mm.NextCalibration
    END AS DirectNextServiceDue

FROM MasterRegister m
LEFT JOIN ToolsMaster tm ON m.ItemType = 'Tool' AND m.RefId = tm.ToolsId
LEFT JOIN AssetsConsumablesMaster ac ON m.ItemType IN ('Asset','Consumable') AND m.RefId = ac.AssetId
LEFT JOIN MmdsMaster mm ON m.ItemType = 'MMD' AND m.RefId = mm.MmdId

WHERE (
    (m.ItemType = 'Tool' AND tm.ToolsId IS NOT NULL) OR
    (m.ItemType IN ('Asset','Consumable') AND ac.AssetId IS NOT NULL) OR
    (m.ItemType = 'MMD' AND mm.MmdId IS NOT NULL)
)
ORDER BY MAX(m.CreatedDate) DESC;
```

**Query Result:**
```
┌─────────┬──────┬──────────────────┬─────────────┬─────────────────────┬──────────────────┐
│ ItemID  │ Type │ ItemName         │ CreatedDate │ MaintenanceFreq...  │ DirectNextSer... │
├─────────┼──────┼──────────────────┼─────────────┼─────────────────────┼──────────────────┤
│ T123    │ Tool │ Hydraulic Press  │ 2026-02-02  │ Monthly             │ NULL             │
└─────────┴──────┴──────────────────┴─────────────┴─────────────────────┴──────────────────┘
```


#### Step 6: Calculate Next Service Due (Backend)
**File:** `Backend/InventoryManagement/Repositories/MasterRegisterRepository.cs`

**Code:**
```csharp
foreach (var row in result)
{
    var dto = new EnhancedMasterListDto
    {
        ItemID = row.ItemID ?? "",
        Type = row.Type ?? "",
        ItemName = row.ItemName ?? "",
        CreatedDate = row.CreatedDate,
        // ...
    };

    // ALWAYS recalculate to ensure proper dates
    DateTime? nextServiceDue = null;
    
    if (!string.IsNullOrEmpty(row.MaintenanceFrequency))
    {
        nextServiceDue = CalculateNextServiceDate(row.CreatedDate, row.MaintenanceFrequency);
        Console.WriteLine($"DEBUG: Calculated NextServiceDue for {row.ItemID}: " +
                         $"Created={row.CreatedDate:yyyy-MM-dd}, " +
                         $"Frequency={row.MaintenanceFrequency}, " +
                         $"NextService={nextServiceDue:yyyy-MM-dd}");
    }
    
    dto.NextServiceDue = nextServiceDue;
    list.Add(dto);
}
```

**Calculation for T123:**
```
Input:
  ItemID: T123
  CreatedDate: 2026-02-02
  MaintenanceFrequency: Monthly

Calculation:
  CalculateNextServiceDate(2026-02-02, "Monthly")
  → 2026-02-02 + 1 month
  → 2026-03-02

Output:
  NextServiceDue: 2026-03-02

Console Log:
  "DEBUG: Calculated NextServiceDue for T123: Created=2026-02-02, Frequency=Monthly, NextService=2026-03-02"
```

---

#### Step 7: Return Data to Frontend
**File:** `Backend/InventoryManagement/Controllers/ItemDetailsV2Controller.cs`

**HTTP Response:**
```
Status: 200 OK
Content-Type: application/json

[
  {
    "itemID": "T123",
    "type": "Tool",
    "itemName": "Hydraulic Press",
    "vendor": "ABC Corp",
    "createdDate": "2026-02-02T00:00:00Z",
    "responsibleTeam": "Maintenance Team",
    "storageLocation": "Warehouse A",
    "maintenanceFrequency": "Monthly",
    "nextServiceDue": "2026-03-02T00:00:00Z",  // ← CALCULATED!
    "availabilityStatus": "Available"
  },
  // ... more items
]
```

---

#### Step 8: Frontend Parses Response
**File:** `Frontend/inventory/lib/services/master_list_service.dart`

**Code:**
```dart
List<MasterListModel> items = [];
for (var item in response.data) {
  items.add(MasterListModel.fromJson(item));
}
return items;
```

**File:** `Frontend/inventory/lib/model/master_list_model.dart`

**Method:** `MasterListModel.fromJson(json)`

**Code:**
```dart
factory MasterListModel.fromJson(Map<String, dynamic> json) {
  return MasterListModel(
    assetId: json['itemID'] ?? '',
    type: json['type'] ?? '',
    assetName: json['itemName'] ?? '',
    supplier: json['vendor'] ?? '',
    createdDate: DateTime.parse(json['createdDate']),
    responsibleTeam: json['responsibleTeam'] ?? '',
    location: json['storageLocation'] ?? '',
    nextServiceDue: json['nextServiceDue'] != null 
        ? DateTime.parse(json['nextServiceDue'])  // ← Parse date
        : null,
    availabilityStatus: json['availabilityStatus'] ?? 'Available',
  );
}
```

**Parsed Object:**
```dart
MasterListModel(
  assetId: "T123",
  type: "Tool",
  assetName: "Hydraulic Press",
  createdDate: DateTime(2026, 2, 2),
  nextServiceDue: DateTime(2026, 3, 2),  // ← Parsed!
  // ...
)
```


#### Step 9: Populate NextServiceProvider
**File:** `Frontend/inventory/lib/screens/master_list.dart`

**Code:**
```dart
masterListAsync.when(
  data: (rawItems) {
    // Populate NextServiceProvider with next service dates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nextServiceProvider = Provider.of<NextServiceProvider>(context, listen: false);
      
      for (final item in rawItems) {
        if (item.nextServiceDue != null) {
          nextServiceProvider.updateNextServiceDate(item.assetId, item.nextServiceDue!);
        }
      }
    });
    
    // ... render UI
  }
)
```

**What Happens:**
- Loops through all items
- For each item with nextServiceDue
- Stores in NextServiceProvider

**NextServiceProvider State:**
```dart
_nextServiceDates = {
  "T123": DateTime(2026, 3, 2),  // ← Stored!
  "T124": DateTime(2026, 4, 15),
  "A001": DateTime(2026, 5, 20),
  // ... more items
}
```

---

#### Step 10: Display in UI
**File:** `Frontend/inventory/lib/screens/master_list.dart`

**Code:**
```dart
Container(
  width: 150,
  alignment: Alignment.centerLeft,
  padding: const EdgeInsets.all(8.0),
  child: Consumer(
    builder: (context, ref, child) {
      // Watch for reactive state changes
      final productState = ref.watch(productStateByIdProvider(item.assetId));
      
      // Use reactive state if available, otherwise fall back to item data
      final nextServiceDue = productState?.nextServiceDue ?? 
          (item.nextServiceDue != null
              ? "${item.nextServiceDue!.year}-${item.nextServiceDue!.month.toString().padLeft(2, '0')}-${item.nextServiceDue!.day.toString().padLeft(2, '0')}"
              : null);
      
      return Text(
        nextServiceDue ?? "N/A",
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
          color: Colors.black,
        ),
      );
    },
  ),
)
```

**UI Display:**
```
Master List Table:
┌─────────┬──────┬──────────────────┬─────────────┬──────────────────┐
│ Item ID │ Type │ Item Name        │ Created     │ Next Service Due │
├─────────┼──────┼──────────────────┼─────────────┼──────────────────┤
│ T123    │ Tool │ Hydraulic Press  │ 2026-02-02  │ 2026-03-02       │ ← DISPLAYED!
└─────────┴──────┴──────────────────┴─────────────┴──────────────────┘
```

---

### Summary of Flow 2
```
Screen Opens → Provider Watches → Service Fetches → API Call → Backend Query
→ Calculate Next Service Due → Return JSON → Parse Response → Store in Provider
→ Display in UI
```

**Key Points:**
- Next Service Due calculated on-the-fly by backend
- Stored in NextServiceProvider for quick access
- Displayed using Consumer widget for reactivity


---

## Flow 3: Opening Maintenance Service Form

### Example: User Clicks "Add Maintenance Service" for T123
**User Action:** User opens Product Detail for T123 and clicks "Add new maintenance service"

### Step-by-Step Data Flow

#### Step 1: Open Dialog
**File:** `Frontend/inventory/lib/screens/product_detail_screen.dart`

**Code:**
```dart
ElevatedButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: AddMaintenanceService(
          assetId: 'T123',
          itemName: 'Hydraulic Press',
          assetType: 'Tool',
          onServiceAdded: (nextServiceDue) async {
            // Callback after submission
          },
        ),
      ),
    );
  },
  child: Text('Add new maintenance service'),
)
```

**What Happens:**
- Opens dialog with AddMaintenanceService widget
- Passes assetId, itemName, assetType

---

#### Step 2: Form Initialization
**File:** `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

**Method:** `initState()`

**Code:**
```dart
@override
void initState() {
  super.initState();
  _toolCostController.addListener(_calculateTotal);
  _extraChargesController.addListener(_calculateTotal);
  
  // Fetch current next service due and maintenance frequency
  _loadItemData();  // ← KEY METHOD!
}
```

---

#### Step 3: Load Item Data
**File:** `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

**Method:** `_loadItemData()`

**Code:**
```dart
Future<void> _loadItemData() async {
  try {
    final nextServiceProvider = Provider.of<NextServiceProvider>(context, listen: false);
    final nextServiceCalculationService = NextServiceCalculationService(nextServiceProvider);
    
    // Get current next service due from provider
    final nextServiceDue = nextServiceProvider.getNextServiceDate(widget.assetId);
    
    // Get maintenance frequency from API
    final frequency = await nextServiceCalculationService.getMaintenanceFrequency(
      widget.assetId,
      widget.assetType ?? 'Unknown'
    );
    
    if (mounted) {
      setState(() {
        _currentNextServiceDue = nextServiceDue;
        _maintenanceFrequency = frequency;
        
        // Auto-populate Service Date with current Next Service Due
        if (nextServiceDue != null && widget.existingMaintenance == null) {
          _serviceDateController.text = _formatDateForInput(nextServiceDue);
          // Auto-calculate Next Service Due Date
          _calculateNextServiceDue(nextServiceDue);
        }
      });
      
      print('DEBUG: Loaded item data - NextServiceDue: $nextServiceDue, Frequency: $frequency');
    }
  } catch (e) {
    print('DEBUG: Error loading item data: $e');
  }
}
```

**What Happens:**
1. Gets next service due from NextServiceProvider
2. Fetches maintenance frequency from API
3. Auto-populates Service Date field
4. Auto-calculates Next Service Due Date


#### Step 4: Get Next Service Due from Provider
**File:** `Frontend/inventory/lib/providers/next_service_provider.dart`

**Method:** `getNextServiceDate(assetId)`

**Code:**
```dart
DateTime? getNextServiceDate(String assetId) {
  return _nextServiceDates[assetId];
}
```

**Provider State:**
```dart
_nextServiceDates = {
  "T123": DateTime(2026, 3, 2),  // ← Retrieved!
  // ...
}
```

**Result:**
```dart
nextServiceDue = DateTime(2026, 3, 2)
```

---

#### Step 5: Fetch Maintenance Frequency from API
**File:** `Frontend/inventory/lib/services/next_service_calculation_service.dart`

**Method:** `getMaintenanceFrequency(assetId, assetType)`

**Code:**
```dart
Future<String?> getMaintenanceFrequency(String assetId, String assetType) async {
  try {
    final response = await _dio.get(
      '/api/NextService/GetMaintenanceFrequency/$assetId/$assetType',
    );
    
    if (response.statusCode == 200 && response.data != null) {
      return response.data['maintenanceFrequency'];
    }
    return null;
  } catch (e) {
    print('Error getting maintenance frequency: $e');
    return null;
  }
}
```

**HTTP Request:**
```
GET http://localhost:5069/api/NextService/GetMaintenanceFrequency/T123/Tool
```

---

#### Step 6: Backend Fetches Frequency
**File:** `Backend/InventoryManagement/Controllers/NextServiceController.cs`

**Method:** `GetMaintenanceFrequency(assetId, assetType)`

**Code:**
```csharp
[HttpGet("GetMaintenanceFrequency/{assetId}/{assetType}")]
public async Task<IActionResult> GetMaintenanceFrequency(string assetId, string assetType)
{
    try
    {
        Console.WriteLine($"DEBUG: GetMaintenanceFrequency called - AssetId={assetId}, AssetType={assetType}");
        
        using var connection = _context.CreateConnection();
        
        string query = assetType.ToLower() switch
        {
            "tool" => "SELECT MaintainanceFrequency as MaintenanceFrequency FROM ToolsMaster WHERE ToolsId = @AssetId",
            "mmd" => "SELECT CalibrationFrequency as MaintenanceFrequency FROM MmdsMaster WHERE MmdId = @AssetId",
            "asset" => "SELECT MaintenanceFrequency FROM AssetsConsumablesMaster WHERE AssetId = @AssetId AND ItemTypeKey = 1",
            "consumable" => "SELECT MaintenanceFrequency FROM AssetsConsumablesMaster WHERE AssetId = @AssetId AND ItemTypeKey = 2",
            _ => throw new ArgumentException("Invalid asset type")
        };

        Console.WriteLine($"DEBUG: Executing query: {query}");
        
        var result = await connection.QueryFirstOrDefaultAsync<string>(query, new { AssetId = assetId });

        Console.WriteLine($"DEBUG: Query result: {result ?? "NULL"}");
        
        return Ok(new { maintenanceFrequency = result });
    }
    catch (Exception ex)
    {
        Console.WriteLine($"ERROR: GetMaintenanceFrequency failed - {ex.Message}");
        return StatusCode(500, new { message = "Error retrieving maintenance frequency", error = ex.Message });
    }
}
```

**SQL Query Executed:**
```sql
SELECT MaintainanceFrequency as MaintenanceFrequency 
FROM ToolsMaster 
WHERE ToolsId = 'T123'
```

**Query Result:**
```
MaintenanceFrequency
--------------------
Monthly
```

**HTTP Response:**
```
Status: 200 OK
Content-Type: application/json

{
  "maintenanceFrequency": "Monthly"
}
```

**Console Logs:**
```
DEBUG: GetMaintenanceFrequency called - AssetId=T123, AssetType=Tool
DEBUG: Executing query: SELECT MaintainanceFrequency as MaintenanceFrequency FROM ToolsMaster WHERE ToolsId = @AssetId
DEBUG: Query result: Monthly
```


#### Step 7: Auto-populate Service Date
**File:** `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

**Code:**
```dart
if (nextServiceDue != null && widget.existingMaintenance == null) {
  _serviceDateController.text = _formatDateForInput(nextServiceDue);
  // Auto-calculate Next Service Due Date
  _calculateNextServiceDue(nextServiceDue);
}
```

**Method:** `_formatDateForInput(date)`

**Code:**
```dart
String _formatDateForInput(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}
```

**Calculation:**
```
Input: DateTime(2026, 3, 2)
Output: "2026-03-02"
```

**Form State:**
```dart
_serviceDateController.text = "2026-03-02"  // ← Auto-populated!
```

---

#### Step 8: Auto-calculate Next Service Due Date
**File:** `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

**Method:** `_calculateNextServiceDue(serviceDate)`

**Code:**
```dart
void _calculateNextServiceDue(DateTime serviceDate) {
  if (_maintenanceFrequency == null || _maintenanceFrequency!.isEmpty) {
    print('DEBUG: No maintenance frequency available for calculation');
    return;
  }
  
  final frequency = _maintenanceFrequency!.toLowerCase().trim();
  DateTime? nextServiceDue;
  
  switch (frequency) {
    case 'daily':
      nextServiceDue = serviceDate.add(const Duration(days: 1));
      break;
    case 'weekly':
      nextServiceDue = serviceDate.add(const Duration(days: 7));
      break;
    case 'monthly':
      nextServiceDue = DateTime(serviceDate.year, serviceDate.month + 1, serviceDate.day);
      break;
    case 'quarterly':
      nextServiceDue = DateTime(serviceDate.year, serviceDate.month + 3, serviceDate.day);
      break;
    case 'half-yearly':
    case 'halfyearly':
      nextServiceDue = DateTime(serviceDate.year, serviceDate.month + 6, serviceDate.day);
      break;
    case 'yearly':
    case 'annual':
      nextServiceDue = DateTime(serviceDate.year + 1, serviceDate.month, serviceDate.day);
      break;
    case '2nd year':
      nextServiceDue = DateTime(serviceDate.year + 2, serviceDate.month, serviceDate.day);
      break;
    case '3rd year':
      nextServiceDue = DateTime(serviceDate.year + 3, serviceDate.month, serviceDate.day);
      break;
    default:
      nextServiceDue = DateTime(serviceDate.year + 1, serviceDate.month, serviceDate.day);
  }
  
  if (nextServiceDue != null) {
    setState(() {
      _nextServiceDateController.text = _formatDateForInput(nextServiceDue!);
    });
    print('DEBUG: Calculated NextServiceDue: ServiceDate=$serviceDate, Frequency=$frequency, NextDue=$nextServiceDue');
  }
}
```

**Calculation:**
```
Input:
  Service Date: 2026-03-02
  Frequency: Monthly

Calculation:
  case 'monthly':
    nextServiceDue = DateTime(2026, 3 + 1, 2)
    nextServiceDue = DateTime(2026, 4, 2)

Output:
  Next Service Due: 2026-04-02
```

**Form State:**
```dart
_nextServiceDateController.text = "2026-04-02"  // ← Auto-calculated!
```

**Console Log:**
```
DEBUG: Calculated NextServiceDue: ServiceDate=2026-03-02, Frequency=monthly, NextDue=2026-04-02
```


#### Step 9: Form Displays Auto-populated Data
**File:** `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

**UI Display:**
```
┌─────────────────────────────────────────────────────────────┐
│  Add new maintenance service                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Service Date *                                             │
│  ┌───────────────────────────────────────────────────┐     │
│  │ 2026-03-02                                    📅  │  ← Auto-populated!
│  └───────────────────────────────────────────────────┘     │
│                                                             │
│  Service Provider Company *                                 │
│  ┌───────────────────────────────────────────────────┐     │
│  │                                                   │     │
│  └───────────────────────────────────────────────────┘     │
│                                                             │
│  Service Engineer Name *                                    │
│  ┌───────────────────────────────────────────────────┐     │
│  │                                                   │     │
│  └───────────────────────────────────────────────────┘     │
│                                                             │
│  Next Service Due Date *                                    │
│  ┌───────────────────────────────────────────────────┐     │
│  │ 2026-04-02                                    📅  │  ← Auto-calculated!
│  └───────────────────────────────────────────────────┘     │
│                                                             │
│                                    [Cancel]  [Submit]       │
└─────────────────────────────────────────────────────────────┘
```

---

### Summary of Flow 3
```
User Clicks Button → Dialog Opens → initState() → _loadItemData()
→ Get Next Service Due from Provider → Fetch Frequency from API
→ Auto-populate Service Date → Auto-calculate Next Service Due Date
→ Display in Form
```

**Key Points:**
- Service Date = Current Next Service Due (2026-03-02)
- Next Service Due Date = Service Date + Frequency (2026-04-02)
- Both fields auto-populated, user can edit if needed
- Calculation happens instantly on form load

**Data Flow Visualization:**
```
NextServiceProvider (2026-03-02)
         ↓
Service Date Field (2026-03-02)
         ↓
Calculate (2026-03-02 + Monthly)
         ↓
Next Service Due Field (2026-04-02)
```


---

## Flow 4: Submitting Maintenance Service

### Example: User Fills Form and Clicks Submit
**User Action:** User fills remaining fields and clicks "Submit"

### Step-by-Step Data Flow

#### Step 1: Form Validation
**File:** `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

**Method:** `_submitForm()`

**Code:**
```dart
Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (_selectedServiceType == null || _selectedServiceType!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a service type'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    _isSubmitting = true;
  });
  
  // Continue with submission...
}
```

**What Happens:**
- Validates all required fields
- Checks service type selected
- Sets loading state

---

#### Step 2: Parse Dates
**File:** `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

**Code:**
```dart
// Parse dates (YYYY-MM-DD format)
DateTime? serviceDate;
DateTime? nextServiceDate;

if (_serviceDateController.text.isNotEmpty) {
  final parts = _serviceDateController.text.split('-');
  if (parts.length == 3) {
    serviceDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}

if (_nextServiceDateController.text.isNotEmpty) {
  final parts = _nextServiceDateController.text.split('-');
  if (parts.length == 3) {
    nextServiceDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}
```

**Parsing:**
```
Input: "2026-03-02"
Split: ["2026", "03", "02"]
Parse: DateTime(2026, 3, 2)

Input: "2026-04-02"
Split: ["2026", "04", "02"]
Parse: DateTime(2026, 4, 2)
```

**Result:**
```dart
serviceDate = DateTime(2026, 3, 2)
nextServiceDate = DateTime(2026, 4, 2)
```

---

#### Step 3: Prepare Maintenance Data
**File:** `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

**Code:**
```dart
final maintenanceData = <String, dynamic>{
  'assetId': 'T123',
  'assetType': 'Tool',
  'itemName': 'Hydraulic Press',
  'serviceDate': serviceDate?.toIso8601String(),  // "2026-03-02T00:00:00.000Z"
  'serviceProviderCompany': _serviceProviderController.text,
  'serviceEngineerName': _serviceEngineerController.text,
  'serviceType': _selectedServiceType!,
  'nextServiceDue': nextServiceDate?.toIso8601String(),  // "2026-04-02T00:00:00.000Z"
  'serviceNotes': _serviceNotesController.text,
  'maintenanceStatus': 'Completed',
  'cost': double.tryParse(_totalCostController.text) ?? 0.0,
  'responsibleTeam': _responsibleTeamController.text,
};
```

**JSON Data:**
```json
{
  "assetId": "T123",
  "assetType": "Tool",
  "itemName": "Hydraulic Press",
  "serviceDate": "2026-03-02T00:00:00.000Z",
  "serviceProviderCompany": "ABC Services",
  "serviceEngineerName": "John Doe",
  "serviceType": "Preventive",
  "nextServiceDue": "2026-04-02T00:00:00.000Z",
  "serviceNotes": "Regular maintenance completed",
  "maintenanceStatus": "Completed",
  "cost": 500.00,
  "responsibleTeam": "Maintenance Team"
}
```


#### Step 4: Send to Backend API
**File:** `Frontend/inventory/lib/services/api_service.dart`

**Method:** `addMaintenanceRecord(maintenanceData)`

**HTTP Request:**
```
POST http://localhost:5069/api/Maintenance
Content-Type: application/json

{
  "assetId": "T123",
  "assetType": "Tool",
  "serviceDate": "2026-03-02T00:00:00.000Z",
  "nextServiceDue": "2026-04-02T00:00:00.000Z",
  ...
}
```

---

#### Step 5: Backend Saves Maintenance Record
**File:** `Backend/InventoryManagement/Controllers/MaintenanceController.cs`

**SQL Query:**
```sql
INSERT INTO Maintenance (
  AssetId,
  AssetType,
  ItemName,
  ServiceDate,
  ServiceProviderCompany,
  ServiceEngineerName,
  ServiceType,
  NextServiceDue,
  ServiceNotes,
  MaintenanceStatus,
  Cost,
  ResponsibleTeam,
  CreatedDate
)
VALUES (
  'T123',
  'Tool',
  'Hydraulic Press',
  '2026-03-02',
  'ABC Services',
  'John Doe',
  'Preventive',
  '2026-04-02',  -- ← Next Service Due stored!
  'Regular maintenance completed',
  'Completed',
  500.00,
  'Maintenance Team',
  GETDATE()
)
```

**Database State:**
```
Maintenance Table:
┌──────────────┬─────────┬──────────────────┬─────────────┬──────────────────┬────────┐
│ MaintenanceId│ AssetId │ ItemName         │ ServiceDate │ NextServiceDue   │ Status │
├──────────────┼─────────┼──────────────────┼─────────────┼──────────────────┼────────┤
│ M001         │ T123    │ Hydraulic Press  │ 2026-03-02  │ 2026-04-02       │ Comp.. │
└──────────────┴─────────┴──────────────────┴─────────────┴──────────────────┴────────┘
```

---

#### Step 6: Update NextServiceProvider (Frontend)
**File:** `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

**Code:**
```dart
// After successful maintenance record creation/update
if (nextServiceDate != null && widget.assetType != null) {
  try {
    final nextServiceProvider = Provider.of<NextServiceProvider>(context, listen: false);
    
    // Update the next service date in provider (this will trigger UI updates everywhere)
    nextServiceProvider.updateNextServiceDate(widget.assetId, nextServiceDate);
    
    print('DEBUG: Next service date updated after maintenance: $nextServiceDate');
  } catch (e) {
    print('DEBUG: Error updating next service date after maintenance: $e');
  }
}
```

**Method:** `updateNextServiceDate(assetId, nextServiceDate)`

**File:** `Frontend/inventory/lib/providers/next_service_provider.dart`

**Code:**
```dart
void updateNextServiceDate(String assetId, DateTime nextServiceDate) {
  _nextServiceDates[assetId] = nextServiceDate;
  notifyListeners();  // ← Triggers UI updates!
}
```

**Provider State Update:**
```dart
Before:
_nextServiceDates = {
  "T123": DateTime(2026, 3, 2),  // Old date
  // ...
}

After:
_nextServiceDates = {
  "T123": DateTime(2026, 4, 2),  // ← Updated!
  // ...
}
```

**Console Log:**
```
DEBUG: Next service date updated after maintenance: 2026-04-02 00:00:00.000
```


#### Step 7: Update Database via API
**File:** `Frontend/inventory/lib/services/next_service_calculation_service.dart`

**Code:**
```dart
await nextServiceCalculationService.calculateNextServiceDateAfterMaintenance(
  assetId: widget.assetId,
  assetType: widget.assetType!,
  serviceDate: serviceDate!,
  maintenanceFrequency: _maintenanceFrequency ?? 'Yearly',
);
```

**Method:** `calculateNextServiceDateAfterMaintenance()`

**Code:**
```dart
Future<DateTime?> calculateNextServiceDateAfterMaintenance({
  required String assetId,
  required String assetType,
  required DateTime serviceDate,
  required String maintenanceFrequency,
}) async {
  try {
    // Calculate using provider
    _nextServiceProvider.updateNextServiceDateAfterMaintenance(
      assetId: assetId,
      serviceDate: serviceDate,
      maintenanceFrequency: maintenanceFrequency,
    );
    
    final nextServiceDate = _nextServiceProvider.getNextServiceDate(assetId);
    
    // Update in database
    if (nextServiceDate != null) {
      await _updateItemNextServiceDate(assetId, assetType, nextServiceDate);
    }
    
    return nextServiceDate;
  } catch (e) {
    print('Error calculating next service date after maintenance: $e');
    return null;
  }
}
```

**Method:** `_updateItemNextServiceDate()`

**HTTP Request:**
```
POST http://localhost:5069/api/NextService/UpdateNextServiceDate
Content-Type: application/json

{
  "assetId": "T123",
  "assetType": "Tool",
  "nextServiceDate": "2026-04-02T00:00:00.000Z"
}
```

---

#### Step 8: Backend Updates Master Table
**File:** `Backend/InventoryManagement/Controllers/NextServiceController.cs`

**Method:** `UpdateNextServiceDate()`

**Code:**
```csharp
[HttpPost("UpdateNextServiceDate")]
public async Task<IActionResult> UpdateNextServiceDate([FromBody] UpdateNextServiceDateRequest request)
{
    try
    {
        using var connection = _context.CreateConnection();
        
        string updateQuery = request.AssetType.ToLower() switch
        {
            "tool" => "UPDATE ToolsMaster SET NextServiceDue = @NextServiceDate WHERE ToolsId = @AssetId",
            "mmd" => "UPDATE MmdsMaster SET NextCalibration = @NextServiceDate WHERE MmdId = @AssetId",
            "asset" => "UPDATE AssetsConsumablesMaster SET NextServiceDue = @NextServiceDate WHERE AssetId = @AssetId AND ItemTypeKey = 1",
            "consumable" => "UPDATE AssetsConsumablesMaster SET NextServiceDue = @NextServiceDate WHERE AssetId = @AssetId AND ItemTypeKey = 2",
            _ => throw new ArgumentException("Invalid asset type")
        };

        var rowsAffected = await connection.ExecuteAsync(updateQuery, new 
        { 
            AssetId = request.AssetId, 
            NextServiceDate = request.NextServiceDate 
        });

        if (rowsAffected > 0)
        {
            return Ok(new { message = "Next service date updated successfully" });
        }
        else
        {
            return NotFound(new { message = "Asset not found" });
        }
    }
    catch (Exception ex)
    {
        return StatusCode(500, new { message = "Error updating next service date", error = ex.Message });
    }
}
```

**SQL Query:**
```sql
UPDATE ToolsMaster 
SET NextServiceDue = '2026-04-02' 
WHERE ToolsId = 'T123'
```

**Database State:**
```
ToolsMaster Table:
┌─────────┬──────────────────┬─────────────────────┬─────────────┬────────────────┐
│ ToolsId │ ToolName         │ Maintainance...     │ CreatedDate │ NextServiceDue │
├─────────┼──────────────────┼─────────────────────┼─────────────┼────────────────┤
│ T123    │ Hydraulic Press  │ Monthly             │ 2026-02-02  │ 2026-04-02     │ ← Updated!
└─────────┴──────────────────┴─────────────────────┴─────────────┴────────────────┘
```


#### Step 9: Close Form and Show Success
**File:** `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

**Code:**
```dart
if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Maintenance service added successfully!'),
      backgroundColor: Colors.green,
    ),
  );
  
  Navigator.of(context).pop();  // Close dialog
  widget.onServiceAdded(_nextServiceDateController.text.isNotEmpty 
      ? _nextServiceDateController.text 
      : null);
}
```

**What Happens:**
- Shows success message
- Closes dialog
- Calls onServiceAdded callback

---

#### Step 10: Callback Updates Product Detail
**File:** `Frontend/inventory/lib/screens/product_detail_screen.dart`

**Code:**
```dart
onServiceAdded: (String? nextServiceDue) async {
  print('DEBUG: ProductDetail - Maintenance service added, updating reactive state with Next Service Due: $nextServiceDue');
  
  // Check if widget is still mounted
  if (!mounted) return;
  
  // 1. UPDATE NEXT SERVICE PROVIDER (Global State)
  final nextServiceProvider = provider.Provider.of<NextServiceProvider>(context, listen: false);
  if (nextServiceDue != null) {
    // Parse the date string and update provider
    final parts = nextServiceDue.split('-');
    if (parts.length == 3) {
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      nextServiceProvider.updateNextServiceDate(assetId, date);
    }
  }
  
  // 2. REFRESH MAINTENANCE RECORDS
  setState(() {
    _maintenanceRecordsFuture = _fetchMaintenanceRecords();
  });
  
  // 3. FORCE REFRESH MASTER LIST DATA FROM DATABASE
  print('DEBUG: Force refreshing master list data from database to get latest Next Service Due');
  await _safeRefreshMasterList();
  
  // 4. UPDATE PRODUCT STATE PROVIDER (Item-specific Reactive State)
  if (!mounted) return;
  final updateProductState = ref.read(updateProductStateProvider);
  updateProductState(assetId, nextServiceDue: nextServiceDue);
  
  print('DEBUG: ProductDetail - Maintenance added, refreshed database and updated reactive state');
}
```

**What Happens:**
1. Updates NextServiceProvider (global state)
2. Refreshes maintenance records list
3. Refreshes master list from database
4. Updates ProductStateProvider (item-specific state)

---

### Summary of Flow 4
```
User Submits → Validate → Parse Dates → Prepare Data → API Call
→ Save to Maintenance Table → Update NextServiceProvider
→ Update Database (ToolsMaster) → Close Form → Callback
→ Update ProductStateProvider → Refresh Master List
```

**Database Changes:**
```
Before Submission:
ToolsMaster: NextServiceDue = NULL or 2026-03-02
Maintenance: No record

After Submission:
ToolsMaster: NextServiceDue = 2026-04-02  ← Updated!
Maintenance: New record with ServiceDate=2026-03-02, NextServiceDue=2026-04-02
```

**Provider Changes:**
```
Before:
NextServiceProvider._nextServiceDates["T123"] = DateTime(2026, 3, 2)

After:
NextServiceProvider._nextServiceDates["T123"] = DateTime(2026, 4, 2)  ← Updated!
```


---

## Flow 5: Real-time UI Updates

### Example: After Maintenance Submission, UI Updates Automatically
**Trigger:** Maintenance service submitted successfully

### Step-by-Step Data Flow

#### Step 1: NextServiceProvider Notifies Listeners
**File:** `Frontend/inventory/lib/providers/next_service_provider.dart`

**Code:**
```dart
void updateNextServiceDate(String assetId, DateTime nextServiceDate) {
  _nextServiceDates[assetId] = nextServiceDate;
  notifyListeners();  // ← KEY: Notifies all listeners!
}
```

**What Happens:**
- Updates internal state
- Calls notifyListeners()
- All Consumer widgets watching this provider rebuild

---

#### Step 2: Master List Updates (If Open)
**File:** `Frontend/inventory/lib/screens/master_list.dart`

**Widget:** Consumer watching productStateByIdProvider

**Code:**
```dart
Container(
  width: 150,
  child: Consumer(
    builder: (context, ref, child) {
      // Watch for reactive state changes
      final productState = ref.watch(productStateByIdProvider(item.assetId));
      
      // Use reactive state if available
      final nextServiceDue = productState?.nextServiceDue ?? 
          (item.nextServiceDue != null
              ? "${item.nextServiceDue!.year}-${item.nextServiceDue!.month.toString().padLeft(2, '0')}-${item.nextServiceDue!.day.toString().padLeft(2, '0')}"
              : null);
      
      return Text(
        nextServiceDue ?? "N/A",
        style: TextStyle(color: Colors.black),
      );
    },
  ),
)
```

**What Happens:**
1. Consumer widget detects state change
2. builder() function re-executes
3. Fetches updated nextServiceDue
4. Text widget rebuilds with new date

**UI Update:**
```
Before:
┌─────────┬──────────────────┬──────────────────┐
│ Item ID │ Item Name        │ Next Service Due │
├─────────┼──────────────────┼──────────────────┤
│ T123    │ Hydraulic Press  │ 2026-03-02       │
└─────────┴──────────────────┴──────────────────┘

After (Automatic Update):
┌─────────┬──────────────────┬──────────────────┐
│ Item ID │ Item Name        │ Next Service Due │
├─────────┼──────────────────┼──────────────────┤
│ T123    │ Hydraulic Press  │ 2026-04-02       │ ← Updated!
└─────────┴──────────────────┴──────────────────┘
```

---

#### Step 3: Product Detail Updates
**File:** `Frontend/inventory/lib/screens/product_detail_screen.dart`

**Widget:** Consumer watching productStateByIdProvider

**Code:**
```dart
Expanded(
  child: Consumer(
    builder: (context, ref, child) {
      // Watch for reactive state changes
      final productState = ref.watch(productStateByIdProvider(productData?.assetId ?? widget.id));
      
      // Use reactive state if available
      final nextServiceDue = productState?.nextServiceDue ?? 
          (productData?.nextServiceDue != null
              ? "${productData!.nextServiceDue!.year}-${productData!.nextServiceDue!.month.toString().padLeft(2, '0')}-${productData!.nextServiceDue!.day.toString().padLeft(2, '0')}"
              : null);
      
      return _buildInfoColumn(
        'Next Service Due',
        nextServiceDue ?? 'N/A',
      );
    },
  ),
)
```

**UI Update:**
```
Before:
┌─────────────────────────────────────┐
│ Product Detail - Hydraulic Press    │
├─────────────────────────────────────┤
│ Created Date: 2026-02-02            │
│ Next Service Due: 2026-03-02        │
│ Responsible Team: Maintenance Team  │
└─────────────────────────────────────┘

After (Automatic Update):
┌─────────────────────────────────────┐
│ Product Detail - Hydraulic Press    │
├─────────────────────────────────────┤
│ Created Date: 2026-02-02            │
│ Next Service Due: 2026-04-02        │ ← Updated!
│ Responsible Team: Maintenance Team  │
└─────────────────────────────────────┘
```


#### Step 4: Maintenance Records List Updates
**File:** `Frontend/inventory/lib/screens/product_detail_screen.dart`

**Code:**
```dart
setState(() {
  _maintenanceRecordsFuture = _fetchMaintenanceRecords();
});
```

**What Happens:**
- Triggers re-fetch of maintenance records
- New maintenance record appears in list
- Shows latest service date and next service due

**UI Update:**
```
Before:
┌──────────────────────────────────────────────────────────────┐
│ Maintenance History                                          │
├──────────────────────────────────────────────────────────────┤
│ No maintenance records                                       │
└──────────────────────────────────────────────────────────────┘

After (Automatic Update):
┌──────────────────────────────────────────────────────────────┐
│ Maintenance History                                          │
├──────────────────────────────────────────────────────────────┤
│ Service Date │ Service Type │ Engineer  │ Next Service Due  │
├──────────────┼──────────────┼───────────┼───────────────────┤
│ 2026-03-02   │ Preventive   │ John Doe  │ 2026-04-02        │ ← New!
└──────────────┴──────────────┴───────────┴───────────────────┘
```

---

#### Step 5: Master List Refreshes from Database
**File:** `Frontend/inventory/lib/screens/product_detail_screen.dart`

**Method:** `_safeRefreshMasterList()`

**Code:**
```dart
Future<void> _safeRefreshMasterList() async {
  try {
    if (!mounted) return;
    
    // Force refresh master list provider
    ref.invalidate(masterListProvider);
    
    // Wait a moment for the refresh to complete
    await Future.delayed(const Duration(milliseconds: 500));
  } catch (e) {
    print('DEBUG: Error refreshing master list: $e');
  }
}
```

**What Happens:**
1. Invalidates masterListProvider
2. Triggers new API call to backend
3. Fetches latest data from database
4. Updates all UI components with fresh data

**API Call:**
```
GET http://localhost:5069/api/ItemDetailsV2/enhanced-master-list
```

**Response includes updated data:**
```json
[
  {
    "itemID": "T123",
    "itemName": "Hydraulic Press",
    "nextServiceDue": "2026-04-02T00:00:00Z",  // ← Latest from database
    ...
  }
]
```

---

### Summary of Flow 5
```
notifyListeners() → Consumer Widgets Rebuild → Master List Updates
→ Product Detail Updates → Maintenance List Updates
→ Database Refresh → All UI Components Synchronized
```

**Update Propagation:**
```
NextServiceProvider.updateNextServiceDate()
         ↓
   notifyListeners()
         ↓
    ┌────┴────┬────────────┬──────────────┐
    ↓         ↓            ↓              ↓
Master List  Product    Maintenance   Any Other
  Updates    Detail      History      Consumer
             Updates     Updates       Widgets
```

**Key Points:**
- No page refresh needed
- All updates happen automatically
- Real-time synchronization
- Multiple UI components update simultaneously
- Database stays in sync


---

## Complete End-to-End Flow Diagram

### Visual Representation

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         FLOW 1: CREATE NEW ITEM                         │
└─────────────────────────────────────────────────────────────────────────┘

User Fills Form
    ↓
Validate & Prepare Data
    ↓
POST /api/Tools
    ↓
INSERT INTO ToolsMaster (NextServiceDue = NULL)
    ↓
Success Response
    ↓
Form Closes

Database State: NextServiceDue = NULL (will be calculated on Master List load)

┌─────────────────────────────────────────────────────────────────────────┐
│                      FLOW 2: VIEW MASTER LIST                           │
└─────────────────────────────────────────────────────────────────────────┘

User Opens Master List
    ↓
masterListProvider triggers
    ↓
GET /api/ItemDetailsV2/enhanced-master-list
    ↓
Backend Query (JOIN ToolsMaster, AssetsConsumablesMaster, MmdsMaster)
    ↓
Calculate Next Service Due (CreatedDate + Frequency)
    ↓
Return JSON with calculated dates
    ↓
Parse Response → MasterListModel objects
    ↓
Populate NextServiceProvider
    ↓
Display in UI (Consumer widgets)

UI Shows: T123 | Hydraulic Press | 2026-03-02

┌─────────────────────────────────────────────────────────────────────────┐
│                 FLOW 3: OPEN MAINTENANCE FORM                           │
└─────────────────────────────────────────────────────────────────────────┘

User Clicks "Add Maintenance Service"
    ↓
Dialog Opens → initState()
    ↓
_loadItemData()
    ↓
    ├─→ Get Next Service Due from NextServiceProvider
    │   Result: 2026-03-02
    │
    └─→ GET /api/NextService/GetMaintenanceFrequency/T123/Tool
        Result: "Monthly"
    ↓
Auto-populate Service Date: 2026-03-02
    ↓
_calculateNextServiceDue(2026-03-02)
    ↓
Calculate: 2026-03-02 + 1 month = 2026-04-02
    ↓
Auto-populate Next Service Due Date: 2026-04-02
    ↓
Form Displays Both Fields Pre-filled

┌─────────────────────────────────────────────────────────────────────────┐
│                 FLOW 4: SUBMIT MAINTENANCE                              │
└─────────────────────────────────────────────────────────────────────────┘

User Fills Remaining Fields & Clicks Submit
    ↓
Validate Form
    ↓
Parse Dates (YYYY-MM-DD → DateTime)
    ↓
Prepare JSON Data
    ↓
POST /api/Maintenance
    ↓
INSERT INTO Maintenance (ServiceDate, NextServiceDue)
    ↓
Success Response
    ↓
    ├─→ Update NextServiceProvider (Global State)
    │   _nextServiceDates["T123"] = 2026-04-02
    │   notifyListeners() ← Triggers UI updates!
    │
    ├─→ POST /api/NextService/UpdateNextServiceDate
    │   UPDATE ToolsMaster SET NextServiceDue = '2026-04-02'
    │
    └─→ Close Form & Callback
        ↓
        ├─→ Update ProductStateProvider (Item State)
        │
        ├─→ Refresh Maintenance Records
        │
        └─→ Refresh Master List from Database

┌─────────────────────────────────────────────────────────────────────────┐
│                   FLOW 5: REAL-TIME UI UPDATES                          │
└─────────────────────────────────────────────────────────────────────────┘

notifyListeners() called
    ↓
    ├─→ Master List Consumer Rebuilds
    │   Shows: 2026-04-02 (was 2026-03-02)
    │
    ├─→ Product Detail Consumer Rebuilds
    │   Shows: 2026-04-02 (was 2026-03-02)
    │
    ├─→ Maintenance History Refreshes
    │   Shows: New record with ServiceDate=2026-03-02
    │
    └─→ Database Refresh Completes
        All UI components synchronized with database

Final State:
- Database: NextServiceDue = 2026-04-02
- Provider: _nextServiceDates["T123"] = 2026-04-02
- UI: All components show 2026-04-02
```


---

## Continuous Loop Example

### Scenario: Multiple Maintenance Services Over Time

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         INITIAL STATE                                   │
└─────────────────────────────────────────────────────────────────────────┘

Item Created: 2026-02-02
Maintenance Frequency: Monthly
Next Service Due: 2026-03-02 (Calculated: 2026-02-02 + 1 month)

┌─────────────────────────────────────────────────────────────────────────┐
│                      FIRST MAINTENANCE                                  │
└─────────────────────────────────────────────────────────────────────────┘

User Opens Form:
  Service Date: 2026-03-02 (Auto-populated from Next Service Due)
  Next Service Due: 2026-04-02 (Auto-calculated: 2026-03-02 + 1 month)

User Submits:
  ✓ Maintenance record created
  ✓ Next Service Due updated to 2026-04-02
  ✓ UI updates everywhere

┌─────────────────────────────────────────────────────────────────────────┐
│                     SECOND MAINTENANCE                                  │
└─────────────────────────────────────────────────────────────────────────┘

User Opens Form:
  Service Date: 2026-04-02 (Auto-populated from Next Service Due)
  Next Service Due: 2026-05-02 (Auto-calculated: 2026-04-02 + 1 month)

User Submits:
  ✓ Maintenance record created
  ✓ Next Service Due updated to 2026-05-02
  ✓ UI updates everywhere

┌─────────────────────────────────────────────────────────────────────────┐
│                      THIRD MAINTENANCE                                  │
└─────────────────────────────────────────────────────────────────────────┘

User Opens Form:
  Service Date: 2026-05-02 (Auto-populated from Next Service Due)
  Next Service Due: 2026-06-02 (Auto-calculated: 2026-05-02 + 1 month)

User Submits:
  ✓ Maintenance record created
  ✓ Next Service Due updated to 2026-06-02
  ✓ UI updates everywhere

┌─────────────────────────────────────────────────────────────────────────┐
│                         PATTERN                                         │
└─────────────────────────────────────────────────────────────────────────┘

Each Service:
  Current Next Service Due → Service Date
  Service Date + Frequency → New Next Service Due
  New Next Service Due → Stored for next service

This creates a continuous, self-perpetuating maintenance schedule!
```

---

## Data State Timeline

### Complete State Changes from Creation to Third Maintenance

```
TIME: 2026-02-02 (Item Created)
─────────────────────────────────────────────────────────────────────────
Database:
  ToolsMaster.NextServiceDue = NULL
  Maintenance: No records

Provider:
  NextServiceProvider._nextServiceDates["T123"] = Not set

UI:
  Master List: Not visible yet (item just created)

─────────────────────────────────────────────────────────────────────────
TIME: 2026-02-03 (User Opens Master List)
─────────────────────────────────────────────────────────────────────────
Database:
  ToolsMaster.NextServiceDue = NULL (unchanged)
  Maintenance: No records

Provider:
  NextServiceProvider._nextServiceDates["T123"] = DateTime(2026, 3, 2)
  (Calculated: 2026-02-02 + Monthly)

UI:
  Master List: Shows "2026-03-02"

─────────────────────────────────────────────────────────────────────────
TIME: 2026-03-02 (First Maintenance Submitted)
─────────────────────────────────────────────────────────────────────────
Database:
  ToolsMaster.NextServiceDue = 2026-04-02 ← Updated!
  Maintenance: 1 record (ServiceDate=2026-03-02, NextServiceDue=2026-04-02)

Provider:
  NextServiceProvider._nextServiceDates["T123"] = DateTime(2026, 4, 2) ← Updated!

UI:
  Master List: Shows "2026-04-02" ← Updated!
  Product Detail: Shows "2026-04-02" ← Updated!
  Maintenance History: 1 record ← New!

─────────────────────────────────────────────────────────────────────────
TIME: 2026-04-02 (Second Maintenance Submitted)
─────────────────────────────────────────────────────────────────────────
Database:
  ToolsMaster.NextServiceDue = 2026-05-02 ← Updated!
  Maintenance: 2 records

Provider:
  NextServiceProvider._nextServiceDates["T123"] = DateTime(2026, 5, 2) ← Updated!

UI:
  Master List: Shows "2026-05-02" ← Updated!
  Product Detail: Shows "2026-05-02" ← Updated!
  Maintenance History: 2 records ← Updated!

─────────────────────────────────────────────────────────────────────────
TIME: 2026-05-02 (Third Maintenance Submitted)
─────────────────────────────────────────────────────────────────────────
Database:
  ToolsMaster.NextServiceDue = 2026-06-02 ← Updated!
  Maintenance: 3 records

Provider:
  NextServiceProvider._nextServiceDates["T123"] = DateTime(2026, 6, 2) ← Updated!

UI:
  Master List: Shows "2026-06-02" ← Updated!
  Product Detail: Shows "2026-06-02" ← Updated!
  Maintenance History: 3 records ← Updated!
```


---

## Key Methods and Their Roles

### Backend Methods

#### 1. MasterRegisterRepository.GetEnhancedMasterListAsync()
**Purpose:** Fetch all items with calculated next service dates
**When Called:** When Master List screen loads
**What It Does:**
- Queries database with JOINs
- Calculates next service due for each item
- Returns enriched data

#### 2. MasterRegisterRepository.CalculateNextServiceDate()
**Purpose:** Calculate next service date based on frequency
**When Called:** By GetEnhancedMasterListAsync() for each item
**What It Does:**
- Takes created date and frequency
- Adds appropriate time period
- Returns calculated date

#### 3. NextServiceController.GetMaintenanceFrequency()
**Purpose:** Fetch maintenance frequency for an item
**When Called:** When maintenance form opens
**What It Does:**
- Queries appropriate master table
- Returns frequency string

#### 4. NextServiceController.UpdateNextServiceDate()
**Purpose:** Update next service date in database
**When Called:** After maintenance submission
**What It Does:**
- Updates master table
- Persists new next service date

---

### Frontend Methods

#### 5. NextServiceProvider.updateNextServiceDate()
**Purpose:** Update global state and notify listeners
**When Called:** After maintenance submission
**What It Does:**
- Updates _nextServiceDates map
- Calls notifyListeners()
- Triggers UI rebuilds

#### 6. NextServiceProvider.calculateNextServiceDate()
**Purpose:** Calculate next service date (frontend logic)
**When Called:** By various services
**What It Does:**
- Takes base date and frequency
- Calculates next date
- Returns DateTime

#### 7. NextServiceCalculationService.getMaintenanceFrequency()
**Purpose:** Fetch frequency from API
**When Called:** When maintenance form loads
**What It Does:**
- Makes API call
- Returns frequency string

#### 8. NextServiceCalculationService.calculateNextServiceDateAfterMaintenance()
**Purpose:** Update next service date after maintenance
**When Called:** After maintenance submission
**What It Does:**
- Updates provider
- Calls API to update database
- Returns new date

#### 9. AddMaintenanceService._loadItemData()
**Purpose:** Load item data when form opens
**When Called:** In initState()
**What It Does:**
- Gets next service due from provider
- Fetches frequency from API
- Auto-populates form fields

#### 10. AddMaintenanceService._calculateNextServiceDue()
**Purpose:** Calculate next service due in form
**When Called:** When service date changes
**What It Does:**
- Takes service date and frequency
- Calculates next date
- Updates form field

#### 11. AddMaintenanceService._submitForm()
**Purpose:** Submit maintenance record
**When Called:** When user clicks Submit
**What It Does:**
- Validates form
- Parses dates
- Calls API
- Updates providers
- Closes form

---

## Method Call Chain

### When User Opens Maintenance Form

```
User Clicks "Add Maintenance Service"
    ↓
showDialog() → AddMaintenanceService widget created
    ↓
initState()
    ↓
_loadItemData()
    ↓
    ├─→ NextServiceProvider.getNextServiceDate("T123")
    │   Returns: DateTime(2026, 3, 2)
    │
    └─→ NextServiceCalculationService.getMaintenanceFrequency("T123", "Tool")
        ↓
        HTTP GET /api/NextService/GetMaintenanceFrequency/T123/Tool
        ↓
        NextServiceController.GetMaintenanceFrequency("T123", "Tool")
        ↓
        SQL: SELECT MaintainanceFrequency FROM ToolsMaster WHERE ToolsId = 'T123'
        ↓
        Returns: "Monthly"
    ↓
_formatDateForInput(DateTime(2026, 3, 2))
    Returns: "2026-03-02"
    ↓
_serviceDateController.text = "2026-03-02"
    ↓
_calculateNextServiceDue(DateTime(2026, 3, 2))
    ↓
    Calculate: DateTime(2026, 3, 2) + 1 month = DateTime(2026, 4, 2)
    ↓
_formatDateForInput(DateTime(2026, 4, 2))
    Returns: "2026-04-02"
    ↓
_nextServiceDateController.text = "2026-04-02"
    ↓
Form Displays with Both Fields Pre-filled
```

### When User Submits Maintenance Form

```
User Clicks "Submit"
    ↓
_submitForm()
    ↓
Validate Form
    ↓
Parse Dates
    ↓
ApiService.addMaintenanceRecord(maintenanceData)
    ↓
HTTP POST /api/Maintenance
    ↓
MaintenanceController.AddMaintenance()
    ↓
SQL: INSERT INTO Maintenance (...)
    ↓
Success Response
    ↓
NextServiceProvider.updateNextServiceDate("T123", DateTime(2026, 4, 2))
    ↓
    _nextServiceDates["T123"] = DateTime(2026, 4, 2)
    notifyListeners() ← All Consumer widgets rebuild!
    ↓
NextServiceCalculationService.calculateNextServiceDateAfterMaintenance(...)
    ↓
    NextServiceProvider.updateNextServiceDateAfterMaintenance(...)
    ↓
    HTTP POST /api/NextService/UpdateNextServiceDate
    ↓
    NextServiceController.UpdateNextServiceDate()
    ↓
    SQL: UPDATE ToolsMaster SET NextServiceDue = '2026-04-02' WHERE ToolsId = 'T123'
    ↓
Close Form
    ↓
onServiceAdded callback
    ↓
    ├─→ Update ProductStateProvider
    │
    ├─→ Refresh Maintenance Records
    │
    └─→ Refresh Master List
        ↓
        ref.invalidate(masterListProvider)
        ↓
        MasterListService.fetchEnhancedMasterList()
        ↓
        HTTP GET /api/ItemDetailsV2/enhanced-master-list
        ↓
        MasterRegisterRepository.GetEnhancedMasterListAsync()
        ↓
        All UI Components Update with Fresh Data
```

---

## Conclusion

This data flow documentation shows the complete journey of data from:
1. **Item Creation** → Database storage
2. **Master List Load** → Calculation and display
3. **Form Opening** → Auto-population
4. **Maintenance Submission** → Multi-layer updates
5. **Real-time UI Updates** → Reactive synchronization

The system ensures data consistency across:
- Database (persistent storage)
- Providers (in-memory state)
- UI Components (visual display)

All updates happen automatically without page refreshes, providing a seamless user experience.

