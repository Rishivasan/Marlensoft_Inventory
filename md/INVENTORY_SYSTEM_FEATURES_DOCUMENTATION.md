# Inventory Management System - Features & Implementation Documentation

## Overview
This document provides a comprehensive review of the inventory management system's key features, implementation details, and architecture patterns. It serves as a technical reference for understanding how each component works and interacts within the system.

---

## 1. PAGINATION SYSTEM - DETAILED IMPLEMENTATION

### 🎯 How Pagination Works

The system implements **client-side pagination** where all data is fetched from the backend and pagination is handled entirely on the frontend.

#### Frontend Pagination Architecture

**Core Components:**

1. **PaginationState Class** (`Frontend/inventory/lib/widgets/pagination_controls.dart`)
   ```dart
   class PaginationState {
     final int currentPage;
     final int rowsPerPage;
     final int totalItems;
     
     int get totalPages => (totalItems / rowsPerPage).ceil();
     int get firstRowIndex => (currentPage - 1) * rowsPerPage;
     int get lastRowIndex => math.min(firstRowIndex + rowsPerPage, totalItems);
   }
   ```

2. **GenericPaginatedTable Widget** (`Frontend/inventory/lib/widgets/generic_paginated_table.dart`)
   - **Purpose**: Reusable paginated table component
   - **Key Features**:
     - Manages internal pagination state
     - Handles row selection with persistence across pages
     - Supports custom row builders
     - Integrates with sorting and filtering
   - **Data Flow**: 
     ```
     Complete Dataset → Filter → Sort → Paginate → Display Current Page
     ```

3. **PaginationControls Widget** (`Frontend/inventory/lib/widgets/pagination_controls.dart`)
   - **Purpose**: Navigation controls for pagination
   - **Features**:
     - "Show X entries" dropdown (5, 10, 15, 20 options)
     - Smart page number display with ellipsis
     - Previous/Next navigation buttons
     - Responsive page calculation for large datasets

#### Backend Data Strategy

**No Server-Side Pagination**: The backend returns complete datasets without pagination parameters.

**Key Repository Method** (`Backend/InventoryManagement/Repositories/MasterRegisterRepository.cs`):
```csharp
public async Task<List<EnhancedMasterListDto>> GetEnhancedMasterListAsync()
{
    var query = @"
    SELECT m.SNo, m.ItemType, m.RefId, m.CreatedDate,
           -- Enhanced fields with maintenance and allocation data
           CASE WHEN m.ItemType = 'Tool' THEN tm.ToolName
                WHEN m.ItemType IN ('Asset','Consumable') THEN ac.AssetName
                WHEN m.ItemType = 'MMD' THEN mm.ModelNumber
                ELSE '' END AS Name,
           -- Additional fields...
    FROM MasterRegister m
    LEFT JOIN ToolsMaster tm ON m.ItemType = 'Tool' AND m.RefId = tm.ToolsId
    LEFT JOIN AssetsConsumablesMaster ac ON m.ItemType IN ('Asset','Consumable') AND m.RefId = ac.AssetId
    LEFT JOIN MmdsMaster mm ON m.ItemType = 'MMD' AND m.RefId = mm.MmdId
    -- Additional JOINs for maintenance and allocation data
    ORDER BY m.SNo DESC";
}
```

#### Pagination Data Flow Example

1. **User Action**: User navigates to Master List screen
2. **Provider Trigger**: `masterListProvider` is watched by `MasterListScreen`
3. **Service Call**: `MasterListService.getMasterList()` is invoked
4. **API Request**: HTTP GET to `/api/enhanced-master-list`
5. **Backend Processing**: Repository executes complex JOIN query
6. **Data Return**: Complete dataset returned to frontend
7. **State Management**: Data stored in Riverpod provider
8. **UI Processing**: 
   - Search filtering applied (`filteredMasterListProvider`)
   - Sorting applied (`sortedMasterListProvider`)
   - Pagination slicing in `GenericPaginatedTable`
9. **Display**: Current page items rendered in table

---

## 2. PROVIDER PATTERN - STATE MANAGEMENT ARCHITECTURE

### 🎯 Riverpod 3.x Implementation

The system uses Flutter Riverpod for reactive state management with a comprehensive provider hierarchy.

#### Master List Providers (`Frontend/inventory/lib/providers/master_list_provider.dart`)

```dart
// Main data provider
final masterListProvider = AsyncNotifierProvider<MasterListNotifier, List<MasterListModel>>(() {
  return MasterListNotifier();
});

// Service provider
final masterListServiceProvider = Provider((ref) => MasterListService());

// Sorted data provider
final sortedMasterListProvider = Provider<AsyncValue<List<MasterListModel>>>((ref) {
  final masterListAsync = ref.watch(masterListProvider);
  final sortState = ref.watch(sortProvider);
  
  return masterListAsync.when(
    data: (items) => AsyncValue.data(SortingUtils.sortMasterList(items, sortState.sortColumn, sortState.direction)),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});
```

#### Sorting Providers (`Frontend/inventory/lib/providers/sorting_provider.dart`)

```dart
enum SortDirection { ascending, descending, none }

class SortState {
  final String? sortColumn;
  final SortDirection direction;
}

final sortProvider = NotifierProvider<SortNotifier, SortState>(() => SortNotifier());
```

#### Search Providers (`Frontend/inventory/lib/providers/search_provider.dart`)

```dart
// Search query providers for different screens
final masterListSearchQueryProvider = StateProvider<String>((ref) => '');
final maintenanceSearchQueryProvider = StateProvider<String>((ref) => '');
final allocationSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered data provider
final filteredMasterListProvider = Provider<List<MasterListModel>>((ref) {
  final sortedMasterListAsync = ref.watch(sortedMasterListProvider);
  final searchQuery = ref.watch(masterListSearchQueryProvider);
  
  return sortedMasterListAsync.when(
    data: (items) => searchQuery.isEmpty ? items : filterMasterListItems(items, searchQuery),
    loading: () => [],
    error: (_, __) => [],
  );
});
```

#### Selection Providers (`Frontend/inventory/lib/providers/selection_provider.dart`)

```dart
// Selected items management
final selectedItemsProvider = NotifierProvider<SelectedItemsNotifier, Set<String>>(() {
  return SelectedItemsNotifier();
});

// Select all state
final selectAllProvider = NotifierProvider<SelectAllNotifier, bool>(() {
  return SelectAllNotifier();
});
```

#### Product State Providers (`Frontend/inventory/lib/providers/product_state_provider.dart`)

```dart
// Reactive state for individual products
final productStateByIdProvider = Provider.family<AsyncValue<ProductState>, String>((ref, assetId) {
  // Returns reactive state for specific asset
});

// Update providers for real-time data sync
final updateNextServiceDueProvider = Provider((ref) => UpdateNextServiceDueNotifier());
final updateAvailabilityStatusProvider = Provider((ref) => UpdateAvailabilityStatusNotifier());
```

---

## 3. ROUTING SYSTEM - NAVIGATION ARCHITECTURE

### 🎯 Auto Route Configuration

**Router Setup** (`Frontend/inventory/lib/routers/app_router.dart`):

```dart
@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: DashboardRoute.page, initial: true, children: [
      AutoRoute(page: MasterListRoute.page), 
      AutoRoute(page: DefaultRoute.page, initial: true),
      AutoRoute(page: ProductDetailRoute.page),
    ]),
  ];
}
```

**Navigation Flow**:
1. **Dashboard** is the root route with nested child routes
2. **Sidebar selection** triggers route changes via `sideBarStateProvider`
3. **DashboardBodyScreen** listens to sidebar state and updates displayed screen
4. **Master list items** navigate to `ProductDetailRoute` with item ID parameter

**Screen Mapping**:
- Sidebar 0 → Dashboard (DefaultRoute)
- Sidebar 1 → Products (DefaultRoute) 
- Sidebar 2 → Quality Check (QCTemplateScreen)
- Sidebar 6 → Inventory (MasterListRoute)
- Sidebar 7 → Quality Check (DefaultRoute)

---

## 4. KEY FEATURES & FUNCTIONALITIES

### 🎯 Core System Features

#### 4.1 Master List Management
**File**: `Frontend/inventory/lib/screens/master_list.dart`

**Features**:
- Centralized view of all Tools, Assets, Consumables, and MMDs
- Real-time data integration from multiple backend tables
- Advanced search across multiple fields (ID, name, type, supplier, location, etc.)
- Multi-column sorting with visual indicators
- Multi-select functionality with select-all option
- Configurable pagination (5, 10, 15, 20 items per page)
- Row click navigation to detailed item view

**Implementation**:
```dart
GenericPaginatedTable<MasterListModel>(
  data: sortedAndFilteredItems,
  rowsPerPage: 10,
  minWidth: 1800,
  showCheckboxColumn: true,
  onRowTap: (item) => context.router.push(ProductDetailRoute(id: item.refId)),
  onSelectionChanged: (selectedItems) => ref.read(selectedItemsProvider.notifier).updateSelection(selectedItems),
  // Custom row builder with sortable headers
)
```

#### 4.2 Item Details Management (V2 API)
**Files**: 
- Backend: `Backend/InventoryManagement/Controllers/ItemDetailsV2Controller.cs`
- Frontend: `Frontend/inventory/lib/services/api_service.dart`

**Features**:
- Unified API endpoint for all item types (Tools, MMDs, Assets, Consumables)
- Dynamic field structure retrieval for form generation
- Complete item details with master data and type-specific data
- Update functionality with validation

**API Endpoints**:
```csharp
[HttpGet("api/v2/item-details/{itemId}/{itemType}")]
public async Task<IActionResult> GetCompleteItemDetails(string itemId, string itemType)

[HttpPut("api/v2/item-details/{itemId}/{itemType}")]
public async Task<IActionResult> UpdateCompleteItemDetails(string itemId, string itemType, [FromBody] object updateData)

[HttpGet("api/v2/item-details/{itemId}/{itemType}/fields")]
public async Task<IActionResult> GetItemFieldStructure(string itemId, string itemType)
```

#### 4.3 Maintenance Tracking System
**Files**:
- Backend: `Backend/InventoryManagement/Controllers/MaintenanceController.cs`
- Frontend: `Frontend/inventory/lib/model/maintenance_model.dart`

**Features**:
- Track maintenance records per asset
- Service provider and engineer information
- Next service due date calculation and tracking
- Maintenance status management (Scheduled, In Progress, Completed)
- Cost tracking and reporting
- Maintenance history with pagination

**Data Model**:
```dart
class MaintenanceModel {
  final int maintenanceId;
  final String assetType;
  final String assetId;
  final String itemName;
  final DateTime? serviceDate;
  final String serviceProviderCompany;
  final String serviceEngineerName;
  final String serviceType;
  final DateTime? nextServiceDue;
  final String serviceNotes;
  final String maintenanceStatus;
  final double cost;
  final String responsibleTeam;
  final DateTime createdDate;
}
```

#### 4.4 Asset Allocation System
**Files**:
- Backend: `Backend/InventoryManagement/Controllers/AllocationController.cs`
- Frontend: `Frontend/inventory/lib/model/allocation_model.dart`

**Features**:
- Track asset allocation to employees/teams
- Issue and return date management
- Availability status tracking (Available, Allocated, Under Maintenance)
- Purpose tracking for allocations
- Employee and team assignment
- Allocation history with search and filter

#### 4.5 Quality Control Management
**Files**:
- Frontend: `Frontend/inventory/lib/screens/qc_template_screen.dart`
- Backend: `Backend/InventoryManagement/Controllers/QualityController.cs`

**Features**:
- QC template customization
- Control point type management
- Validation type configuration
- Quality check workflow

#### 4.6 Data Export Functionality
**File**: `Frontend/inventory/lib/services/export_service.dart`

**Features**:
- Export master list data to Excel format
- Filtered data export (respects current search/filter)
- Custom column selection
- Formatted Excel output with headers

---

## 5. SERVICE LAYER ARCHITECTURE

### 🎯 Frontend Services

#### ApiService - Central HTTP Client
**File**: `Frontend/inventory/lib/services/api_service.dart`

**Configuration**:
```dart
static const List<String> possibleUrls = [
  "http://localhost:5069",      // Primary
  "http://localhost:5071",      // Fallback 1
  "http://localhost:5070",      // Fallback 2
  "http://localhost:38234",     // IIS Express
  "http://localhost:7294",      // HTTPS
];
```

**Key Methods**:
- `getCompleteItemDetailsV2()` - Fetch complete item details by ID and type
- `updateCompleteItemDetailsV2()` - Update item details
- `getMasterListById()` - Get specific item from master list
- `getMaintenanceByAssetId()` - Fetch maintenance records for asset
- `getAllocationsByAssetId()` - Fetch allocation records for asset
- CRUD operations for Tools, Assets, MMDs

#### MasterListService
**File**: `Frontend/inventory/lib/services/master_list_service.dart`

```dart
class MasterListService {
  Future<List<MasterListModel>> getMasterList() async {
    final dio = DioClient.getDio();
    final response = await dio.get("/api/enhanced-master-list");
    
    // Remove duplicates based on ItemID
    final uniqueItems = <String, MasterListModel>{};
    for (final item in items) {
      uniqueItems[item.assetId] = item;
    }
    
    return uniqueItems.values.toList();
  }
}
```

### 🎯 Backend Services

#### MasterRegisterService
**File**: `Backend/InventoryManagement/Services/MasterRegisterService.cs`

```csharp
public class MasterRegisterService : IMasterRegisterService
{
    public async Task<List<MasterListDto>> GetMasterListAsync()
    public async Task<List<EnhancedMasterListDto>> GetEnhancedMasterListAsync()
}
```

#### ToolService
**File**: `Backend/InventoryManagement/Services/ToolsService.cs`

```csharp
public class ToolService : IToolService
{
    public async Task<IEnumerable<ToolDto>> GetToolsAsync()
    public async Task<bool> CreateToolAsync(ToolEntity tool)
    public async Task<bool> UpdateToolAsync(ToolEntity tool)
    public async Task<bool> DeleteToolAsync(string toolId)
}
```

---

## 6. REPOSITORY PATTERN IMPLEMENTATION

### 🎯 Backend Repository Architecture

#### MasterRegisterRepository - Core Data Access
**File**: `Backend/InventoryManagement/Repositories/MasterRegisterRepository.cs`

**Enhanced Master List Query**:
```csharp
public async Task<List<EnhancedMasterListDto>> GetEnhancedMasterListAsync()
{
    var query = @"
    SELECT 
        m.SNo, m.ItemType, m.RefId, m.CreatedDate,
        
        -- Dynamic name resolution
        CASE 
            WHEN m.ItemType = 'Tool' THEN tm.ToolName
            WHEN m.ItemType IN ('Asset','Consumable') THEN ac.AssetName
            WHEN m.ItemType = 'MMD' THEN mm.ModelNumber
            ELSE ''
        END AS Name,
        
        -- Dynamic type resolution
        CASE
            WHEN m.ItemType = 'Tool' THEN tm.ToolType
            WHEN m.ItemType IN ('Asset','Consumable') THEN ac.Category
            WHEN m.ItemType = 'MMD' THEN mm.Specifications
            ELSE m.ItemType
        END AS Type,
        
        -- Real-time maintenance data
        COALESCE(latest_maintenance.NextServiceDue, '1900-01-01') AS NextServiceDue,
        COALESCE(latest_maintenance.ResponsibleTeam, 'Unassigned') AS ResponsibleTeam,
        
        -- Real-time allocation data
        CASE 
            WHEN latest_allocation.AllocationId IS NOT NULL 
                 AND latest_allocation.ActualReturnDate IS NULL 
            THEN 'Allocated'
            ELSE 'Available'
        END AS AvailabilityStatus
        
    FROM MasterRegister m
    
    -- Item type specific JOINs
    LEFT JOIN ToolsMaster tm ON m.ItemType = 'Tool' AND m.RefId = tm.ToolsId AND tm.Status = 1
    LEFT JOIN AssetsConsumablesMaster ac ON m.ItemType IN ('Asset','Consumable') AND m.RefId = ac.AssetId AND ac.Status = 1
    LEFT JOIN MmdsMaster mm ON m.ItemType = 'MMD' AND m.RefId = mm.MmdId AND mm.Status = 1
    
    -- Latest maintenance record
    LEFT JOIN (
        SELECT AssetId, NextServiceDue, ResponsibleTeam,
               ROW_NUMBER() OVER (PARTITION BY AssetId ORDER BY CreatedDate DESC) as rn
        FROM MaintenanceMaster
        WHERE Status = 1
    ) latest_maintenance ON m.RefId = latest_maintenance.AssetId AND latest_maintenance.rn = 1
    
    -- Latest allocation record
    LEFT JOIN (
        SELECT AssetId, AllocationId, ActualReturnDate,
               ROW_NUMBER() OVER (PARTITION BY AssetId ORDER BY CreatedDate DESC) as rn
        FROM AllocationMaster
        WHERE Status = 1
    ) latest_allocation ON m.RefId = latest_allocation.AssetId AND latest_allocation.rn = 1
    
    WHERE (
        (m.ItemType = 'Tool' AND tm.ToolsId IS NOT NULL) OR
        (m.ItemType IN ('Asset','Consumable') AND ac.AssetId IS NOT NULL) OR
        (m.ItemType = 'MMD' AND mm.MmdId IS NOT NULL)
    )
    ORDER BY m.SNo DESC";
}
```

#### ToolRepository - Transaction Management
**File**: `Backend/InventoryManagement/Repositories/ToolRepository.cs`

```csharp
public async Task<int> CreateToolAsync(ToolEntity tool)
{
    using var connection = _context.CreateConnection();
    connection.Open();
    using var transaction = connection.BeginTransaction();

    try
    {
        // Insert into ToolsMaster
        var toolResult = await connection.ExecuteAsync(toolQuery, tool, transaction);

        // Insert into MasterRegister
        var masterResult = await connection.ExecuteAsync(masterQuery, masterParams, transaction);

        transaction.Commit();
        return toolResult;
    }
    catch
    {
        transaction.Rollback();
        throw;
    }
}
```

---

## 7. API ENDPOINTS REFERENCE

### 🎯 Complete API Documentation

#### Master Register Endpoints
```
GET  /api/master-list              - Basic master list
GET  /api/enhanced-master-list     - Enhanced master list with real-time data
```

#### Item Details V2 Endpoints
```
GET  /api/v2/item-details/{itemId}/{itemType}         - Complete item details
PUT  /api/v2/item-details/{itemId}/{itemType}         - Update item details
GET  /api/v2/item-details/{itemId}/{itemType}/fields  - Field structure
```

#### Tools Management
```
GET    /api/tools           - All tools
POST   /api/addtools        - Create tool
DELETE /api/Tools/{id}      - Delete tool
```

#### MMDs Management
```
GET    /api/mmds            - All MMDs
POST   /api/addmmds         - Create MMD
PUT    /api/updatemmds      - Update MMD
DELETE /api/Mmds/{id}       - Delete MMD
```

#### Assets/Consumables Management
```
GET    /api/assets-consumables              - All assets/consumables
POST   /api/add-assets-consumables          - Create asset/consumable
GET    /api/asset-full-details              - Complete asset details
PUT    /api/update-assets-consumables       - Update asset/consumable
DELETE /api/AssetsConsumables/{id}          - Delete asset/consumable
```

#### Maintenance Management
```
GET  /api/maintenance/{assetId}    - Maintenance records for asset
POST /api/maintenance              - Create maintenance record
PUT  /api/maintenance/{id}         - Update maintenance record
```

#### Allocation Management
```
GET  /api/allocation/{assetId}     - Allocation records for asset
POST /api/allocation               - Create allocation record
PUT  /api/allocation/{id}          - Update allocation record
```

---

## 8. DATA MODELS & ENTITIES

### 🎯 Frontend Models

#### MasterListModel
**File**: `Frontend/inventory/lib/model/master_list_model.dart`

```dart
class MasterListModel {
  final int sno;
  final String itemType;
  final String refId;
  final String assetId;
  final String type;
  final String name;
  final String supplier;
  final String location;
  
  // Enhanced fields
  final DateTime createdDate;
  final String responsibleTeam;
  final DateTime? nextServiceDue;
  final String availabilityStatus;
}
```

#### MaintenanceModel
**File**: `Frontend/inventory/lib/model/maintenance_model.dart`

```dart
class MaintenanceModel {
  final int maintenanceId;
  final String assetType;
  final String assetId;
  final String itemName;
  final DateTime? serviceDate;
  final String serviceProviderCompany;
  final String serviceEngineerName;
  final String serviceType;
  final DateTime? nextServiceDue;
  final String serviceNotes;
  final String maintenanceStatus;
  final double cost;
  final String responsibleTeam;
  final DateTime createdDate;
}
```

### 🎯 Backend DTOs & Entities

#### EnhancedMasterListDto
```csharp
public class EnhancedMasterListDto
{
    public int SNo { get; set; }
    public string ItemType { get; set; }
    public string RefId { get; set; }
    public string Name { get; set; }
    public string Type { get; set; }
    public string Supplier { get; set; }
    public string Location { get; set; }
    public DateTime CreatedDate { get; set; }
    public string ResponsibleTeam { get; set; }
    public DateTime? NextServiceDue { get; set; }
    public string AvailabilityStatus { get; set; }
}
```

#### ToolEntity
```csharp
public class ToolEntity
{
    public string ToolsId { get; set; }
    public string ToolName { get; set; }
    public string ToolType { get; set; }
    public string AssociatedProduct { get; set; }
    public string ArticleCode { get; set; }
    public string Vendor { get; set; }
    public string Specifications { get; set; }
    public string StorageLocation { get; set; }
    // Additional fields...
}
```

---

## 9. ARCHITECTURAL PATTERNS SUMMARY

### 🎯 Key Design Patterns

1. **Client-Side Pagination**
   - All data fetched to frontend
   - Pagination handled in UI components
   - Better user experience with instant navigation

2. **Reactive State Management**
   - Riverpod providers for reactive updates
   - Automatic UI updates when data changes
   - Efficient state sharing across components

3. **Service Layer Pattern**
   - Abstraction between UI and data access
   - Centralized business logic
   - Reusable service methods

4. **Repository Pattern**
   - Backend data access abstraction
   - Consistent data access interface
   - Transaction management

5. **Soft Delete Pattern**
   - Items marked as inactive (Status = 0)
   - Data preservation for audit trails
   - Reversible delete operations

6. **Master Register Pattern**
   - Central registry of all items
   - Unified item tracking across types
   - Consistent item identification

7. **Fallback Query Strategy**
   - Enhanced query with basic fallback
   - Robust error handling
   - Graceful degradation

8. **Transaction Management**
   - Multi-table operations wrapped in transactions
   - Data consistency guarantees
   - Rollback on failures

---

## 10. PERFORMANCE CONSIDERATIONS

### 🎯 Optimization Strategies

1. **Data Fetching**
   - Single API call for complete dataset
   - Efficient JOIN queries in backend
   - Duplicate removal in frontend

2. **State Management**
   - Provider-based caching
   - Selective rebuilds with Riverpod
   - Computed providers for derived data

3. **UI Rendering**
   - Virtualized pagination
   - Lazy loading of table rows
   - Efficient selection state management

4. **Database Queries**
   - Indexed columns for JOINs
   - ROW_NUMBER() for latest records
   - Status-based filtering

---

## 11. TESTING & DEBUGGING

### 🎯 Debug Features

1. **Comprehensive Logging**
   - API request/response logging
   - Provider state change logging
   - Error tracking with stack traces

2. **Debug Endpoints**
   - Test files in `md/` directory
   - PowerShell test scripts
   - JSON test data files

3. **Error Handling**
   - Graceful API failure handling
   - Fallback data strategies
   - User-friendly error messages

---

## CONCLUSION

This inventory management system demonstrates a well-architected solution with:

- **Scalable pagination** that handles large datasets efficiently
- **Reactive state management** using modern Flutter patterns
- **Comprehensive feature set** covering all inventory management needs
- **Robust backend architecture** with proper separation of concerns
- **Real-time data integration** across multiple related entities
- **User-friendly interface** with advanced search, sort, and filter capabilities

The system is designed for maintainability, extensibility, and performance, making it suitable for enterprise-level inventory management requirements.