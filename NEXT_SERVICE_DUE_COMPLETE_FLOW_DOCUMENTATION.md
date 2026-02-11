# NEXT SERVICE DUE DATE CALCULATION - COMPLETE FLOW DOCUMENTATION
## Line-by-Line Explanation of POC1 Implementation

---

## Table of Contents
1. [Overview](#overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Complete Data Flow](#complete-data-flow)
4. [Frontend Implementation](#frontend-implementation)
5. [Backend Implementation](#backend-implementation)
6. [Database Layer](#database-layer)
7. [Step-by-Step Execution Flow](#step-by-step-execution-flow)
8. [Code Walkthrough](#code-walkthrough)

---

## 1. Overview

### What is Next Service Due Calculation?

The Next Service Due calculation system automatically determines when an item (Tool, MMD, Asset, or Consumable) needs its next maintenance service based on:
- **Maintenance Frequency**: How often service is required (Daily, Weekly, Monthly, Quarterly, Half-Yearly, Yearly, 2nd Year, 3rd Year)
- **Last Service Date**: When the item was last serviced
- **Created Date**: When the item was first added to the system

### Why This System?

**Problem**: Manual tracking of maintenance schedules is error-prone and time-consuming.

**Solution**: Automatic calculation ensures:
- ✅ No missed maintenance schedules
- ✅ Proactive service planning
- ✅ Compliance with maintenance requirements
- ✅ Real-time status updates across the system

---

## 2. Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                               │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐ │
│  │ Add Maintenance  │  │   Master List    │  │  Product Detail  │ │
│  │     Form         │  │     Screen       │  │     Screen       │ │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘ │
└───────────┼────────────────────┼────────────────────┼─────────────┘
            │                    │                    │
            ▼                    ▼                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      FRONTEND LAYER (Flutter/Dart)                   │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  NextServiceProvider (State Management)                       │  │
│  │  - Stores next service dates for all items                    │  │
│  │  - Calculates maintenance status (Overdue, Due Soon, OK)      │  │
│  │  - Provides reactive updates to UI                            │  │
│  └────────────────────────┬─────────────────────────────────────┘  │
│                           │                                          │
│  ┌────────────────────────▼─────────────────────────────────────┐  │
│  │  NextServiceCalculationService                                │  │
│  │  - Handles API communication                                  │  │
│  │  - Calculates next service dates                              │  │
│  │  - Updates provider state                                     │  │
│  └────────────────────────┬─────────────────────────────────────┘  │
└───────────────────────────┼──────────────────────────────────────────┘
                            │ HTTP API Calls
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    BACKEND LAYER (ASP.NET Core/C#)                   │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  NextServiceController (API Endpoints)                        │  │
│  │  - GetLastServiceDate: Get last maintenance date              │  │
│  │  - GetMaintenanceFrequency: Get item's frequency              │  │
│  │  - CalculateNextServiceDate: Calculate next date              │  │
│  │  - UpdateNextServiceDate: Update database                     │  │
│  └────────────────────────┬─────────────────────────────────────┘  │
└───────────────────────────┼──────────────────────────────────────────┘
                            │ SQL Queries
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      DATABASE LAYER (SQL Server)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │ ToolsMaster  │  │  MmdsMaster  │  │AssetsConsum. │             │
│  │NextServiceDue│  │NextCalibration│ │NextServiceDue│             │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘             │
│         │                 │                  │                      │
│         └─────────────────┴──────────────────┘                      │
│                           │                                          │
│                  ┌────────▼────────┐                                │
│                  │   Maintenance   │                                │
│                  │  ServiceDate    │                                │
│                  │ NextServiceDue  │                                │
│                  └─────────────────┘                                │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Complete Data Flow

### Scenario 1: Adding New Item with Maintenance Frequency

```
Step 1: User fills Add Form
   ↓
Step 2: User selects Maintenance Frequency (e.g., "Yearly")
   ↓
Step 3: User clicks Submit
   ↓
Step 4: Frontend calculates: NextServiceDue = CreatedDate + Frequency
   ↓
Step 5: Frontend sends POST request to create item
   ↓
Step 6: Backend saves item with NextServiceDue in database
   ↓
Step 7: Frontend updates NextServiceProvider state
   ↓
Step 8: Master List displays item with Next Service Due date
```

### Scenario 2: Adding Maintenance Service

```
Step 1: User opens Maintenance Form from Product Detail
   ↓
Step 2: Form auto-populates Service Date with current Next Service Due
   ↓
Step 3: User enters service details
   ↓
Step 4: Form auto-calculates NEW Next Service Due = ServiceDate + Frequency
   ↓
Step 5: User clicks Submit
   ↓
Step 6: Frontend sends POST request with maintenance data
   ↓
Step 7: Backend saves maintenance record
   ↓
Step 8: Backend updates item's NextServiceDue in database
   ↓
Step 9: Frontend updates NextServiceProvider state
   ↓
Step 10: Product Detail and Master List show updated Next Service Due
```

---

## 4. Frontend Implementation

### 4.1 NextServiceProvider (State Management)

**File**: `Frontend/inventory/lib/providers/next_service_provider.dart`

**Purpose**: Central state management for all Next Service Due dates

**Line-by-Line Explanation**:

```dart
class NextServiceProvider extends ChangeNotifier {
  // LINE 1: Store next service dates for all items
  // Key: AssetId (e.g., "TOOL001"), Value: Next Service Due Date
  final Map<String, DateTime> _nextServiceDates = {};
```
**Why Map?** Fast O(1) lookup by asset ID. Stores dates for all items in memory.

```dart
  // LINE 2: Calculate and store next service date for a new item
  void calculateAndStoreNextServiceDate({
    required String assetId,
    required DateTime createdDate,
    required String maintenanceFrequency,
    DateTime? lastServiceDate,
  }) {
```
**Purpose**: Calculate next service date when item is created.

```dart
    // LINE 3: Determine base date for calculation
    // RULE: If item has service history, use last service date
    //       Otherwise, use created date
    final baseDate = lastServiceDate ?? createdDate;
```
**Why?** New items use created date. Items with service history use last service date for accuracy.

```dart
    // LINE 4: Calculate next service date based on frequency
    final nextServiceDate = _calculateNextServiceDate(baseDate, maintenanceFrequency);
```
**Calculation Logic**:
- Daily: baseDate + 1 day
- Weekly: baseDate + 7 days
- Monthly: baseDate + 1 month
- Quarterly: baseDate + 3 months
- Half-Yearly: baseDate + 6 months
- Yearly: baseDate + 1 year
- 2nd Year: baseDate + 2 years
- 3rd Year: baseDate + 3 years

```dart
    // LINE 5: Store in map and notify listeners
    if (nextServiceDate != null) {
      _nextServiceDates[assetId] = nextServiceDate;
      notifyListeners(); // Triggers UI rebuild
    }
  }
```
**Why notifyListeners()?** All widgets watching this provider will rebuild with new data.

```dart
  // LINE 6: Get next service date for an item
  DateTime? getNextServiceDate(String assetId) {
    return _nextServiceDates[assetId];
  }
```
**Usage**: Master List and Product Detail screens call this to display dates.

```dart
  // LINE 7: Update next service date after maintenance
  void updateNextServiceDate(String assetId, DateTime nextServiceDate) {
    _nextServiceDates[assetId] = nextServiceDate;
    notifyListeners(); // Triggers UI rebuild
  }
```
**When Called**: After maintenance service is completed, updates the date.

```dart
  // LINE 8: Calculate maintenance status for UI indicators
  String getMaintenanceStatus(String assetId) {
    final nextServiceDate = _nextServiceDates[assetId];
    if (nextServiceDate == null) return 'Unknown';
    
    final now = DateTime.now();
    final daysUntilService = nextServiceDate.difference(now).inDays;
    
    if (daysUntilService < 0) return 'Overdue';      // Red indicator
    if (daysUntilService <= 7) return 'Due Soon';    // Orange indicator
    return 'Scheduled';                               // Green indicator
  }
```
**UI Impact**: Master List shows color-coded dots based on status.



### 4.2 NextServiceCalculationService (API Communication)

**File**: `Frontend/inventory/lib/services/next_service_calculation_service.dart`

**Purpose**: Handle API calls and coordinate with provider

**Line-by-Line Explanation**:

```dart
class NextServiceCalculationService {
  final Dio _dio = DioClient.getDio();  // LINE 1: HTTP client for API calls
  final NextServiceProvider _nextServiceProvider;  // LINE 2: Reference to provider
  
  NextServiceCalculationService(this._nextServiceProvider);
```
**Why Dio?** HTTP client for making REST API calls to backend.

```dart
  // LINE 3: Calculate next service date for a new item
  Future<DateTime?> calculateNextServiceDateForNewItem({
    required String assetId,
    required String assetType,
    required DateTime createdDate,
    required String maintenanceFrequency,
  }) async {
```
**When Called**: When user creates a new Tool, MMD, Asset, or Consumable.

```dart
    try {
      // LINE 4: First check if there's any existing maintenance record
      final lastServiceDate = await _getLastServiceDate(assetId, assetType);
```
**Why Check?** Item might have been serviced before being added to system.

```dart
      // LINE 5: Calculate next service date using provider
      _nextServiceProvider.calculateAndStoreNextServiceDate(
        assetId: assetId,
        createdDate: createdDate,
        maintenanceFrequency: maintenanceFrequency,
        lastServiceDate: lastServiceDate,
      );
```
**Flow**: Provider calculates date → Stores in memory → Notifies UI.

```dart
      // LINE 6: Get the calculated date from provider
      final nextServiceDate = _nextServiceProvider.getNextServiceDate(assetId);
```
**Why Get?** Retrieve the date that was just calculated and stored.

```dart
      // LINE 7: Update the item's next service date in the database
      if (nextServiceDate != null) {
        await _updateItemNextServiceDate(assetId, assetType, nextServiceDate);
      }
```
**Critical**: Persist to database so it survives app restarts.

```dart
      return nextServiceDate;
    } catch (e) {
      print('Error calculating next service date: $e');
      return null;
    }
  }
```
**Error Handling**: Returns null if calculation fails, doesn't crash app.

```dart
  // LINE 8: Get the last service date from maintenance records
  Future<DateTime?> _getLastServiceDate(String assetId, String assetType) async {
    try {
      final response = await _dio.get(
        '/api/NextService/GetLastServiceDate/$assetId/$assetType',
      );
```
**API Call**: GET request to backend to fetch last service date.

```dart
      if (response.statusCode == 200 && response.data != null) {
        final lastServiceDateStr = response.data['lastServiceDate'];
        if (lastServiceDateStr != null) {
          return DateTime.tryParse(lastServiceDateStr);
        }
      }
      return null;
    } catch (e) {
      print('Error getting last service date: $e');
      return null;
    }
  }
```
**Response Format**: `{ "lastServiceDate": "2024-04-06T00:00:00Z" }`

```dart
  // LINE 9: Update item's next service date in the database
  Future<bool> _updateItemNextServiceDate(
    String assetId, 
    String assetType, 
    DateTime nextServiceDate
  ) async {
    try {
      final response = await _dio.post(
        '/api/NextService/UpdateNextServiceDate',
        data: {
          'assetId': assetId,
          'assetType': assetType,
          'nextServiceDate': nextServiceDate.toIso8601String(),
        },
      );
```
**API Call**: POST request to update database with calculated date.

```dart
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating next service date: $e');
      return false;
    }
  }
```
**Return**: true if update successful, false otherwise.

```dart
  // LINE 10: Calculate next service date after maintenance is performed
  Future<DateTime?> calculateNextServiceDateAfterMaintenance({
    required String assetId,
    required String assetType,
    required DateTime serviceDate,
    required String maintenanceFrequency,
  }) async {
```
**When Called**: After user submits maintenance service form.

```dart
    try {
      // LINE 11: Calculate using provider
      _nextServiceProvider.updateNextServiceDateAfterMaintenance(
        assetId: assetId,
        serviceDate: serviceDate,
        maintenanceFrequency: maintenanceFrequency,
      );
```
**Calculation**: NextServiceDue = ServiceDate + MaintenanceFrequency

```dart
      final nextServiceDate = _nextServiceProvider.getNextServiceDate(assetId);
      
      // LINE 12: Update in database
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
**Complete Flow**: Calculate → Store in Provider → Update Database → Return Date

### 4.3 Add Maintenance Service Form

**File**: `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

**Purpose**: Form for adding maintenance service records

**Key Lines Explained**:

```dart
// LINE 1: Load current next service due and maintenance frequency
Future<void> _loadItemData() async {
  try {
    final nextServiceProvider = Provider.of<NextServiceProvider>(context, listen: false);
    final nextServiceCalculationService = NextServiceCalculationService(nextServiceProvider);
```
**Purpose**: Get current data to pre-populate form.

```dart
    // LINE 2: PRIORITY 1 - Use Next Service Due passed from parent dialog
    DateTime? nextServiceDue;
    
    if (widget.currentNextServiceDue != null && widget.currentNextServiceDue!.isNotEmpty) {
      try {
        final parts = widget.currentNextServiceDue!.split('-');
        if (parts.length == 3) {
          nextServiceDue = DateTime(
            int.parse(parts[0]),  // Year
            int.parse(parts[1]),  // Month
            int.parse(parts[2])   // Day
          );
          print('DEBUG: Using Next Service Due from parent dialog: $nextServiceDue');
        }
      } catch (e) {
        print('DEBUG: Error parsing Next Service Due from parent: $e');
      }
    }
```
**Why Priority 1?** Parent dialog shows the SAME date user sees, ensures consistency.

```dart
    // LINE 3: PRIORITY 2 - Fallback to provider if not passed from parent
    if (nextServiceDue == null) {
      nextServiceDue = nextServiceProvider.getNextServiceDate(widget.assetId);
      print('DEBUG: Using Next Service Due from provider: $nextServiceDue');
    }
```
**Fallback**: If parent doesn't pass date, get from provider.

```dart
    // LINE 4: Get maintenance frequency from backend
    final frequency = await nextServiceCalculationService.getMaintenanceFrequency(
      widget.assetId,
      widget.assetType ?? 'Unknown'
    );
```
**API Call**: Fetch frequency to calculate next service due.

```dart
    // LINE 5: Update state and auto-populate Service Date
    if (mounted) {
      setState(() {
        _currentNextServiceDue = nextServiceDue;
        _maintenanceFrequency = frequency;
        
        // IMPORTANT: Auto-populate Service Date with CURRENT Next Service Due
        if (nextServiceDue != null && widget.existingMaintenance == null) {
          _serviceDateController.text = _formatDateForInput(nextServiceDue);
          // Auto-calculate the NEXT Next Service Due Date
          _calculateNextServiceDue(nextServiceDue);
        }
      });
    }
  } catch (e) {
    print('DEBUG: Error loading item data: $e');
  }
}
```
**Smart Pre-population**:
1. Service Date = Current Next Service Due (when service should happen)
2. Next Service Due = Service Date + Frequency (when NEXT service should happen)

```dart
// LINE 6: Calculate next service due based on service date and frequency
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
    print('DEBUG: Calculated Next Service Due: ServiceDate=$serviceDate, Frequency=$frequency, NextDue=$nextServiceDue');
  }
}
```
**Calculation Logic**: Adds time period to service date based on frequency.

```dart
// LINE 7: Submit form and update next service date
Future<void> _submitForm() async {
  // ... validation code ...
  
  try {
    // LINE 8: Create maintenance data
    final maintenanceData = <String, dynamic>{
      'assetId': widget.assetId,
      'assetType': widget.assetType ?? 'Unknown',
      'itemName': widget.itemName ?? 'Unknown',
      'serviceDate': serviceDate?.toIso8601String(),
      'nextServiceDue': nextServiceDate?.toIso8601String(),
      // ... other fields ...
    };
```
**Data Structure**: Prepares JSON payload for API.

```dart
    // LINE 9: Send POST request to backend
    final response = await apiService.addMaintenanceRecord(maintenanceData);
```
**API Call**: Creates maintenance record in database.

```dart
    // LINE 10: Update next service date via provider
    if (nextServiceDate != null && widget.assetType != null) {
      try {
        final nextServiceProvider = Provider.of<NextServiceProvider>(context, listen: false);
        
        // Update the next service date in provider (triggers UI updates everywhere)
        nextServiceProvider.updateNextServiceDate(widget.assetId, nextServiceDate);
```
**Critical**: Updates provider so ALL screens show new date immediately.

```dart
        // Also update via API to persist in database
        final nextServiceCalculationService = NextServiceCalculationService(nextServiceProvider);
        await nextServiceCalculationService.calculateNextServiceDateAfterMaintenance(
          assetId: widget.assetId,
          assetType: widget.assetType!,
          serviceDate: serviceDate!,
          maintenanceFrequency: _maintenanceFrequency ?? 'Yearly',
        );
        
        print('DEBUG: Next service date updated after maintenance: $nextServiceDate');
      } catch (e) {
        print('DEBUG: Error updating next service date after maintenance: $e');
      }
    }
```
**Double Update**: Provider (immediate UI) + Database (persistence).

```dart
    // LINE 11: Close dialog and notify parent
    if (mounted) {
      Navigator.of(context).pop();
      widget.onServiceAdded(_nextServiceDateController.text.isNotEmpty ? _nextServiceDateController.text : null);
    }
  } catch (e) {
    // Error handling...
  }
}
```
**Callback**: Notifies parent screen to refresh data.



---

## 5. Backend Implementation

### 5.1 NextServiceController (API Endpoints)

**File**: `Backend/InventoryManagement/Controllers/NextServiceController.cs`

**Purpose**: Provide REST API endpoints for next service date operations

**Line-by-Line Explanation**:

```csharp
[ApiController]
[Route("api/[controller]")]
public class NextServiceController : ControllerBase
{
    private readonly DapperContext _context;  // LINE 1: Database connection context

    public NextServiceController(DapperContext context)
    {
        _context = context;  // LINE 2: Dependency injection
    }
```
**Why Dapper?** Lightweight ORM for fast SQL queries.

```csharp
    // LINE 3: Get last service date from maintenance records
    [HttpGet("GetLastServiceDate/{assetId}/{assetType}")]
    public async Task<IActionResult> GetLastServiceDate(string assetId, string assetType)
    {
        try
        {
            using var connection = _context.CreateConnection();
```
**Connection**: Opens database connection for this request.

```csharp
            // LINE 4: SQL query to get most recent service date
            var query = @"
                SELECT TOP 1 ServiceDate as LastServiceDate
                FROM Maintenance 
                WHERE AssetId = @AssetId AND AssetType = @AssetType 
                AND ServiceDate IS NOT NULL
                ORDER BY ServiceDate DESC";
```
**SQL Breakdown**:
- `SELECT TOP 1`: Get only the most recent record
- `WHERE AssetId = @AssetId`: Filter by specific item
- `AND ServiceDate IS NOT NULL`: Only records with actual service dates
- `ORDER BY ServiceDate DESC`: Most recent first

```csharp
            // LINE 5: Execute query with parameters
            var result = await connection.QueryFirstOrDefaultAsync<DateTime?>(
                query, 
                new { AssetId = assetId, AssetType = assetType }
            );
```
**Parameterized Query**: Prevents SQL injection attacks.

```csharp
            // LINE 6: Return result as JSON
            return Ok(new { lastServiceDate = result?.ToString("yyyy-MM-ddTHH:mm:ss.fffZ") });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error retrieving last service date", error = ex.Message });
        }
    }
```
**Response Format**: `{ "lastServiceDate": "2024-04-06T00:00:00.000Z" }`

```csharp
    // LINE 7: Update next service date in database
    [HttpPost("UpdateNextServiceDate")]
    public async Task<IActionResult> UpdateNextServiceDate([FromBody] UpdateNextServiceDateRequest request)
    {
        try
        {
            using var connection = _context.CreateConnection();
```
**POST Endpoint**: Receives JSON body with update data.

```csharp
            // LINE 8: Determine which table to update based on asset type
            string updateQuery = request.AssetType.ToLower() switch
            {
                "tool" => "UPDATE ToolsMaster SET NextServiceDue = @NextServiceDate WHERE ToolsId = @AssetId",
                "mmd" => "UPDATE MmdsMaster SET NextCalibration = @NextServiceDate WHERE MmdId = @AssetId",
                "asset" => "UPDATE AssetsConsumablesMaster SET NextServiceDue = @NextServiceDate WHERE AssetId = @AssetId AND ItemTypeKey = 1",
                "consumable" => "UPDATE AssetsConsumablesMaster SET NextServiceDue = @NextServiceDate WHERE AssetId = @AssetId AND ItemTypeKey = 2",
                _ => throw new ArgumentException("Invalid asset type")
            };
```
**Why Switch?** Different tables store next service due in different columns:
- Tools: `NextServiceDue` in `ToolsMaster`
- MMDs: `NextCalibration` in `MmdsMaster`
- Assets/Consumables: `NextServiceDue` in `AssetsConsumablesMaster`

```csharp
            // LINE 9: Execute update query
            var rowsAffected = await connection.ExecuteAsync(updateQuery, new 
            { 
                AssetId = request.AssetId, 
                NextServiceDate = request.NextServiceDate 
            });
```
**Execution**: Updates the appropriate table with new date.

```csharp
            // LINE 10: Return success or not found
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
**Response Codes**:
- 200 OK: Update successful
- 404 Not Found: Asset doesn't exist
- 500 Internal Server Error: Database error

```csharp
    // LINE 11: Get maintenance frequency for an item
    [HttpGet("GetMaintenanceFrequency/{assetId}/{assetType}")]
    public async Task<IActionResult> GetMaintenanceFrequency(string assetId, string assetType)
    {
        try
        {
            using var connection = _context.CreateConnection();
            
            // LINE 12: Determine which table to query based on asset type
            string query = assetType.ToLower() switch
            {
                "tool" => "SELECT MaintainanceFrequency as MaintenanceFrequency FROM ToolsMaster WHERE ToolsId = @AssetId",
                "mmd" => "SELECT CalibrationFrequency as MaintenanceFrequency FROM MmdsMaster WHERE MmdId = @AssetId",
                "asset" => "SELECT MaintenanceFrequency FROM AssetsConsumablesMaster WHERE AssetId = @AssetId AND ItemTypeKey = 1",
                "consumable" => "SELECT MaintenanceFrequency FROM AssetsConsumablesMaster WHERE AssetId = @AssetId AND ItemTypeKey = 2",
                _ => throw new ArgumentException("Invalid asset type")
            };
```
**Why Different Queries?** Each table has different column names for frequency.

```csharp
            // LINE 13: Execute query and return result
            var result = await connection.QueryFirstOrDefaultAsync<string>(query, new { AssetId = assetId });
            
            return Ok(new { maintenanceFrequency = result });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error retrieving maintenance frequency", error = ex.Message, stackTrace = ex.StackTrace });
        }
    }
```
**Response Format**: `{ "maintenanceFrequency": "Yearly" }`

```csharp
    // LINE 14: Calculate next service date (alternative calculation method)
    [HttpPost("CalculateNextServiceDate")]
    public IActionResult CalculateNextServiceDate([FromBody] CalculateNextServiceDateRequest request)
    {
        try
        {
            // LINE 15: Determine base date (last service or created date)
            var baseDate = request.LastServiceDate ?? request.CreatedDate;
            
            // LINE 16: Calculate next service date
            var nextServiceDate = CalculateNextServiceDateFromFrequency(baseDate, request.MaintenanceFrequency);

            return Ok(new { nextServiceDate = nextServiceDate.ToString("yyyy-MM-ddTHH:mm:ss.fffZ") });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error calculating next service date", error = ex.Message });
        }
    }
```
**Alternative Method**: Frontend can also call this for calculation.

```csharp
    // LINE 17: Helper method to calculate next service date
    private DateTime CalculateNextServiceDateFromFrequency(DateTime baseDate, string maintenanceFrequency)
    {
        return maintenanceFrequency.ToLower() switch
        {
            "daily" => baseDate.AddDays(1),
            "weekly" => baseDate.AddDays(7),
            "monthly" => baseDate.AddMonths(1),
            "quarterly" => baseDate.AddMonths(3),
            "half-yearly" or "halfyearly" => baseDate.AddMonths(6),
            "yearly" => baseDate.AddYears(1),
            "2nd year" => baseDate.AddYears(2),
            "3rd year" => baseDate.AddYears(3),
            _ => baseDate.AddYears(1) // Default to yearly
        };
    }
}
```
**Calculation Logic**: Same as frontend, ensures consistency.

```csharp
// LINE 18: Request DTOs
public class UpdateNextServiceDateRequest
{
    public string AssetId { get; set; }
    public string AssetType { get; set; }
    public DateTime NextServiceDate { get; set; }
}

public class CalculateNextServiceDateRequest
{
    public DateTime CreatedDate { get; set; }
    public DateTime? LastServiceDate { get; set; }
    public string MaintenanceFrequency { get; set; }
}
```
**DTOs**: Data Transfer Objects for API requests.

---

## 6. Database Layer

### 6.1 Table Structures

**ToolsMaster Table**:
```sql
CREATE TABLE ToolsMaster (
    ToolsId NVARCHAR(50) PRIMARY KEY,
    ToolName NVARCHAR(200),
    MaintainanceFrequency NVARCHAR(50),  -- 'Daily', 'Weekly', 'Monthly', etc.
    NextServiceDue DATETIME,              -- Calculated next service date
    -- ... other fields
);
```

**MmdsMaster Table**:
```sql
CREATE TABLE MmdsMaster (
    MmdId NVARCHAR(50) PRIMARY KEY,
    ModelNumber NVARCHAR(200),
    CalibrationFrequency NVARCHAR(50),    -- 'Monthly', 'Quarterly', 'Yearly', etc.
    NextCalibration DATETIME,             -- Calculated next calibration date
    -- ... other fields
);
```

**AssetsConsumablesMaster Table**:
```sql
CREATE TABLE AssetsConsumablesMaster (
    AssetId NVARCHAR(50) PRIMARY KEY,
    AssetName NVARCHAR(200),
    ItemTypeKey INT,                      -- 1 = Asset, 2 = Consumable
    MaintenanceFrequency NVARCHAR(50),    -- Maintenance frequency
    NextServiceDue DATETIME,              -- Calculated next service date
    -- ... other fields
);
```

**Maintenance Table**:
```sql
CREATE TABLE Maintenance (
    MaintenanceId INT IDENTITY(1,1) PRIMARY KEY,
    AssetId NVARCHAR(50),
    AssetType NVARCHAR(50),
    ServiceDate DATETIME,                 -- When service was performed
    NextServiceDue DATETIME,              -- Calculated next service date
    -- ... other fields
);
```

### 6.2 Data Flow in Database

```
1. Item Created
   ↓
   INSERT INTO ToolsMaster (ToolsId, MaintainanceFrequency, NextServiceDue)
   VALUES ('TOOL001', 'Yearly', '2025-01-01')
   
2. Maintenance Performed
   ↓
   INSERT INTO Maintenance (AssetId, ServiceDate, NextServiceDue)
   VALUES ('TOOL001', '2024-04-06', '2025-04-06')
   ↓
   UPDATE ToolsMaster 
   SET NextServiceDue = '2025-04-06'
   WHERE ToolsId = 'TOOL001'
```

---

## 7. Step-by-Step Execution Flow

### Complete Flow: Adding Maintenance Service

**Step 1: User Opens Maintenance Form**
```
User clicks "Add Maintenance" on Product Detail screen
   ↓
Frontend: AddMaintenanceService widget initializes
   ↓
Frontend: Calls _loadItemData()
```

**Step 2: Load Current Data**
```
Frontend: _loadItemData() executes
   ↓
Frontend: Gets NextServiceProvider instance
   ↓
Frontend: Creates NextServiceCalculationService
   ↓
Frontend: Checks widget.currentNextServiceDue (passed from parent)
   ↓
Frontend: If available, parses date string "2024-12-01" → DateTime
   ↓
Frontend: If not available, calls nextServiceProvider.getNextServiceDate(assetId)
```

**Step 3: Fetch Maintenance Frequency**
```
Frontend: Calls nextServiceCalculationService.getMaintenanceFrequency()
   ↓
Frontend: HTTP GET /api/NextService/GetMaintenanceFrequency/TOOL001/Tool
   ↓
Backend: NextServiceController.GetMaintenanceFrequency() receives request
   ↓
Backend: Determines query based on assetType = "Tool"
   ↓
Backend: Executes SQL: SELECT MaintainanceFrequency FROM ToolsMaster WHERE ToolsId = 'TOOL001'
   ↓
Database: Returns "Yearly"
   ↓
Backend: Returns JSON: { "maintenanceFrequency": "Yearly" }
   ↓
Frontend: Receives response, stores in _maintenanceFrequency variable
```

**Step 4: Auto-Populate Form**
```
Frontend: setState() updates UI
   ↓
Frontend: _serviceDateController.text = "2024-12-01" (current next service due)
   ↓
Frontend: Calls _calculateNextServiceDue(DateTime(2024, 12, 1))
   ↓
Frontend: Calculates: 2024-12-01 + 1 year = 2025-12-01
   ↓
Frontend: _nextServiceDateController.text = "2025-12-01"
   ↓
UI: Form displays with pre-populated dates
```

**Step 5: User Fills Form and Submits**
```
User: Enters service provider, engineer, notes, etc.
User: Clicks "Submit" button
   ↓
Frontend: _submitForm() executes
   ↓
Frontend: Validates form fields
   ↓
Frontend: Parses dates from text controllers
   ↓
Frontend: Creates maintenanceData JSON object
```

**Step 6: Create Maintenance Record**
```
Frontend: Calls apiService.addMaintenanceRecord(maintenanceData)
   ↓
Frontend: HTTP POST /api/Maintenance with JSON body
   ↓
Backend: MaintenanceController receives request
   ↓
Backend: Inserts into Maintenance table
   ↓
Database: INSERT INTO Maintenance (AssetId, ServiceDate, NextServiceDue, ...) VALUES (...)
   ↓
Backend: Returns success response
```

**Step 7: Update Next Service Date in Provider**
```
Frontend: Gets NextServiceProvider instance
   ↓
Frontend: Calls nextServiceProvider.updateNextServiceDate('TOOL001', DateTime(2025, 12, 1))
   ↓
Provider: Updates _nextServiceDates['TOOL001'] = DateTime(2025, 12, 1)
   ↓
Provider: Calls notifyListeners()
   ↓
UI: All widgets watching provider rebuild with new date
```

**Step 8: Update Next Service Date in Database**
```
Frontend: Calls nextServiceCalculationService.calculateNextServiceDateAfterMaintenance()
   ↓
Frontend: HTTP POST /api/NextService/UpdateNextServiceDate
   Body: { "assetId": "TOOL001", "assetType": "Tool", "nextServiceDate": "2025-12-01T00:00:00Z" }
   ↓
Backend: NextServiceController.UpdateNextServiceDate() receives request
   ↓
Backend: Determines update query for assetType = "Tool"
   ↓
Backend: Executes SQL: UPDATE ToolsMaster SET NextServiceDue = '2025-12-01' WHERE ToolsId = 'TOOL001'
   ↓
Database: Updates record
   ↓
Backend: Returns success response
```

**Step 9: Close Form and Refresh UI**
```
Frontend: Navigator.of(context).pop() - closes dialog
   ↓
Frontend: Calls widget.onServiceAdded("2025-12-01")
   ↓
Parent Screen: Receives callback, refreshes data
   ↓
Master List: Reads from NextServiceProvider, displays "2025-12-01"
   ↓
Product Detail: Reads from NextServiceProvider, displays "2025-12-01"
```

---

## 8. Code Walkthrough

### Example: Tool with Yearly Maintenance

**Initial State**:
- Tool ID: TOOL001
- Created Date: 2024-01-01
- Maintenance Frequency: Yearly
- Next Service Due: 2025-01-01 (calculated at creation)

**User Performs Maintenance on 2024-12-01**:

1. **Form Opens**:
   - Service Date auto-populated: 2024-12-01 (current next service due)
   - Next Service Due auto-calculated: 2025-12-01 (service date + 1 year)

2. **User Submits**:
   - Maintenance record created with ServiceDate = 2024-12-01
   - NextServiceDue = 2025-12-01

3. **Database Updates**:
   ```sql
   -- Maintenance table
   INSERT INTO Maintenance (AssetId, ServiceDate, NextServiceDue)
   VALUES ('TOOL001', '2024-12-01', '2025-12-01');
   
   -- ToolsMaster table
   UPDATE ToolsMaster 
   SET NextServiceDue = '2025-12-01'
   WHERE ToolsId = 'TOOL001';
   ```

4. **Provider Updates**:
   ```dart
   _nextServiceDates['TOOL001'] = DateTime(2025, 12, 1);
   notifyListeners(); // All UI updates
   ```

5. **UI Reflects Change**:
   - Master List shows: Next Service Due = 2025-12-01
   - Product Detail shows: Next Service Due = 2025-12-01
   - Status indicator: Green (Scheduled, not due soon)

---

## Summary

The Next Service Due calculation system provides:

✅ **Automatic Calculation**: No manual date entry required
✅ **Consistent Logic**: Same calculation in frontend and backend
✅ **Real-time Updates**: Provider pattern ensures immediate UI updates
✅ **Database Persistence**: All dates stored in database
✅ **Smart Pre-population**: Forms auto-fill with intelligent defaults
✅ **Multi-table Support**: Works with Tools, MMDs, Assets, Consumables
✅ **Flexible Frequencies**: Supports 8 different maintenance frequencies
✅ **Error Handling**: Graceful fallbacks if calculations fail

**Key Technologies**:
- Frontend: Flutter/Dart with Provider state management
- Backend: ASP.NET Core with Dapper ORM
- Database: SQL Server with multiple tables
- Communication: REST API with JSON payloads

