# FRONTEND COMPREHENSIVE DOCUMENTATION
# Inventory Management System - Flutter Application

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Core Concepts](#core-concepts)
4. [Screens Documentation](#screens-documentation)
5. [Widgets Documentation](#widgets-documentation)
6. [Services Documentation](#services-documentation)
7. [State Management](#state-management)
8. [Models Documentation](#models-documentation)
9. [Routing & Navigation](#routing--navigation)
10. [API Integration](#api-integration)
11. [UI/UX Design System](#uiux-design-system)

---

## 1. Architecture Overview

### Application Architecture
The Inventory Management System follows a **layered architecture** pattern with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Screens, Widgets, UI Components)      │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      State Management Layer             │
│  (Riverpod Providers, State Notifiers)  │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│         Business Logic Layer            │
│    (Services, Calculation Logic)        │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│          Data Layer                     │
│  (API Service, Models, DTOs)            │
└─────────────────────────────────────────┘
```

### Technology Stack
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Riverpod (flutter_riverpod)
- **Routing**: AutoRoute
- **HTTP Client**: Dio
- **SVG Support**: flutter_svg
- **Date Handling**: Built-in DateTime

### Design Patterns Used
1. **Repository Pattern**: API services abstract data access
2. **Provider Pattern**: State management using Riverpod
3. **Factory Pattern**: Model creation from JSON
4. **Observer Pattern**: Reactive state updates
5. **Singleton Pattern**: API service instances


## 2. Project Structure

```
Frontend/inventory/lib/
├── main.dart                          # Application entry point
├── core/
│   └── api/
│       └── dio_client.dart           # HTTP client configuration
├── screens/                          # All screen widgets
│   ├── master_list.dart             # Main inventory list (legacy)
│   ├── master_list_paginated.dart   # Paginated inventory list
│   ├── product_detail_screen.dart   # Item detail view with tabs
│   ├── qc_template_screen.dart      # Quality control templates
│   ├── dashboard_screen.dart        # Main dashboard
│   ├── dashboard_body.dart          # Dashboard content
│   ├── default_screen.dart          # Default/placeholder screen
│   └── add_forms/                   # Form dialogs for adding/editing
│       ├── add_mmd.dart            # Measuring & Monitoring Devices
│       ├── add_tool.dart           # Tools
│       ├── add_asset.dart          # Assets
│       ├── add_consumable.dart     # Consumables
│       ├── add_maintenance_service.dart  # Maintenance records
│       ├── add_allocation.dart     # Allocation records
│       └── add_control_point.dart  # QC control points
├── widgets/                         # Reusable UI components
│   ├── top_layer.dart              # Top navigation bar
│   ├── nav_profile.dart            # Profile dropdown
│   ├── sidebar.dart                # Side navigation menu
│   ├── searchable_dropdown.dart    # Custom searchable dropdown
│   ├── sortable_header.dart        # Sortable table headers
│   ├── pagination_bar.dart         # Pagination controls
│   └── generic_paginated_table.dart # Reusable paginated table
├── services/                        # Business logic services
│   ├── api_service.dart            # Main API service
│   ├── quality_service.dart        # QC-specific API calls
│   ├── next_service_calculation_service.dart  # Service date calculations
│   └── next_service_sync_service.dart         # Service date synchronization
├── providers/                       # State management
│   ├── master_list_provider.dart   # Master list state
│   ├── product_state_provider.dart # Product reactive state
│   ├── next_service_provider.dart  # Next service due dates
│   ├── pagination_provider.dart    # Pagination state
│   ├── sorting_provider.dart       # Sorting state
│   ├── search_provider.dart        # Search state
│   ├── selection_provider.dart     # Row selection state
│   ├── header_state.dart           # Page header state
│   ├── sidebar_state.dart          # Sidebar state
│   ├── sidebar_expand_state.dart   # Sidebar expansion state
│   ├── screen_provider.dart        # Current screen state
│   └── tool_provider.dart          # Tool-specific state
├── model/                           # Data models
│   ├── master_list_model.dart      # Main inventory item model
│   ├── maintenance_model.dart      # Maintenance record model
│   ├── allocation_model.dart       # Allocation record model
│   ├── tool_model.dart             # Tool model
│   └── pagination_model.dart       # Pagination model
├── routers/                         # Navigation routing
│   ├── app_router.dart             # Route definitions
│   └── app_router.gr.dart          # Generated routes
├── dialogs/
│   └── dialog_pannel_helper.dart   # Dialog utilities
└── utils/
    └── sorting_utils.dart          # Sorting helper functions
```


## 3. Core Concepts

### Why Flutter?
Flutter was chosen for this inventory management system because:
- **Cross-platform**: Single codebase for web, mobile, and desktop
- **Performance**: Compiled to native code for fast execution
- **Rich UI**: Material Design widgets for professional appearance
- **Hot Reload**: Fast development and debugging
- **Strong typing**: Dart's type system prevents runtime errors

### State Management with Riverpod
**Why Riverpod?**
- Compile-time safety (no runtime errors from providers)
- Better testability than Provider
- No BuildContext dependency
- Automatic disposal of resources
- Easy dependency injection

**How it works:**
```dart
// Define a provider
final counterProvider = StateProvider<int>((ref) => 0);

// Read in widget
final count = ref.watch(counterProvider);

// Update state
ref.read(counterProvider.notifier).state++;
```

### Reactive State Updates
The application uses a reactive state management pattern where:
1. User performs action (e.g., adds maintenance record)
2. API call updates database
3. Provider state updates immediately (optimistic UI)
4. Master list refreshes from database
5. All dependent widgets rebuild automatically

**Example Flow:**
```
User adds maintenance → API updates DB → Provider updates state
                                              ↓
                                    UI updates instantly
                                              ↓
                                    Master list refreshes
```


## 4. Screens Documentation

### 4.1 Master List Screen (master_list_paginated.dart)

**Purpose**: Display all inventory items in a paginated, sortable, searchable table.

**Key Features**:
- Server-side pagination (loads data in chunks)
- Multi-column sorting
- Real-time search across all columns
- Row selection with checkboxes
- Export to Excel functionality
- Add new items via dialog
- Navigate to item details on row click

**UI Layout**:
```
┌────────────────────────────────────────────────┐
│  Search Bar    [Add New Item Button]           │
├────────────────────────────────────────────────┤
│  ☐ | Item Type | Name | Supplier | Location...│
│  ☐ | MMD       | Tool1| Acme Inc | Warehouse  │
│  ☐ | Tool      | Tool2| XYZ Corp | Lab        │
├────────────────────────────────────────────────┤
│  [< Previous]  Page 1 of 10  [Next >]          │
└────────────────────────────────────────────────┘
```

**State Management**:
- `paginatedMasterListProvider`: Fetches paginated data from API
- `masterListSortProvider`: Manages sorting state
- `masterListSearchProvider`: Manages search query
- `selectionProvider`: Tracks selected rows

**How to Use**:
1. Search: Type in search bar to filter items
2. Sort: Click column headers to sort (ascending/descending/none)
3. Select: Check boxes to select multiple items
4. Add: Click "Add New Item" to open form dialog
5. View Details: Click any row to navigate to product detail screen

**Code Structure**:
```dart
class MasterListPaginated extends ConsumerStatefulWidget {
  // State variables
  int currentPage = 1;
  int rowsPerPage = 10;
  String searchQuery = '';
  
  // Methods
  _loadData()           // Fetch data from API
  _handleSearch()       // Filter data
  _handleSort()         // Sort columns
  _handlePageChange()   // Navigate pages
  _handleRowClick()     // Navigate to details
}
```

**Why This Design?**
- **Pagination**: Improves performance with large datasets
- **Server-side filtering**: Reduces data transfer
- **Reactive updates**: Changes reflect immediately across the app


### 4.2 Product Detail Screen (product_detail_screen.dart)

**Purpose**: Display detailed information about a single inventory item with maintenance and allocation history.

**Key Features**:
- Product information card with image
- Two tabs: Maintenance & Allocation
- Add/edit maintenance records
- Add/edit allocation records
- Real-time status updates
- Reactive Next Service Due date
- Search within maintenance/allocation records

**UI Layout**:
```
┌──────────────────────────────────────────────────┐
│  [Image]  Tool Name: Drill Machine               │
│           Asset ID: TOOL-001                      │
│           Status: [In Use]  [Edit Icon]           │
│                                                   │
│  Item Type: Tool    | Supplier: Acme Inc         │
│  Location: Warehouse| Next Service: 2024-12-01   │
├──────────────────────────────────────────────────┤
│  [Maintenance Tab] [Allocation Tab]              │
├──────────────────────────────────────────────────┤
│  Search: [_______]        [Add New Service]      │
│  ┌────────────────────────────────────────────┐  │
│  │ Date | Provider | Engineer | Type | Cost   │  │
│  │ 2024 | ABC Ltd  | John Doe | PM   | $500  │  │
│  └────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

**State Management**:
- `productStateByIdProvider`: Reactive product state
- `maintenanceSortProvider`: Maintenance table sorting
- `allocationSortProvider`: Allocation table sorting
- `updateProductStateProvider`: Updates product state
- `updateAvailabilityStatusProvider`: Updates status

**How It Works**:

1. **Loading Product Data**:
```dart
_loadProductData() {
  // Fetch from API
  final data = await apiService.getMasterListById(id);
  // Update local state
  setState(() => productData = data);
  // Load related data
  _loadMaintenanceData();
  _loadAllocationData();
}
```

2. **Reactive Updates**:
```dart
// When maintenance is added
onServiceAdded: (nextServiceDue) {
  // 1. Refresh maintenance list
  _loadMaintenanceData();
  // 2. Update reactive state
  updateProductState(assetId, nextServiceDue: nextServiceDue);
  // 3. Refresh master list
  _safeRefreshMasterList();
}
```

3. **Tab Navigation**:
- Uses `TabController` for switching between Maintenance and Allocation
- Each tab has its own search functionality
- Tables are paginated independently

**Why This Design?**
- **Tabs**: Organize related data without cluttering the UI
- **Reactive State**: Ensures all views show consistent data
- **Search per Tab**: Users can filter maintenance or allocation records independently
- **Edit on Click**: Quick access to edit forms by clicking table rows


### 4.3 QC Template Screen (qc_template_screen.dart)

**Purpose**: Create and manage quality control templates with control points for different materials and products.

**Key Features**:
- Two tabs: Quality Check Customization & Production Process Customization
- Template sidebar with search
- Searchable dropdowns for products and materials
- Drag-and-drop control points (future feature)
- Unique template per material validation
- Auto-generated template names
- Tools field for quality check equipment

**UI Layout**:
```
┌──────────────────────────────────────────────────────┐
│ [Quality Check Tab] [Production Process Tab]         │
├──────────────────────────────────────────────────────┤
│ ┌─────────────┐ ┌──────────────────────────────────┐ │
│ │ Templates   │ │ Basic Information                 │ │
│ │ [+ Add New] │ │ Validation Type: [Dropdown ▼]    │ │
│ │ [Search...] │ │ Final Product:   [Searchable ▼]  │ │
│ │             │ │ Material:        [Searchable ▼]  │ │
│ │ > Template1 │ │ Tools:           [Text Field]     │ │
│ │   Template2 │ │                                   │ │
│ │   Template3 │ │ QC Control Points  [+ Add Point]  │ │
│ │             │ │ ┌──────────────────────────────┐  │ │
│ │             │ │ │ 1. Dimension Check           │  │ │
│ │             │ │ │ 2. Visual Inspection         │  │ │
│ │             │ │ └──────────────────────────────┘  │ │
│ └─────────────┘ └──────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

**Template Naming Convention**:
```
Format: {ValidationTypeCode} - {ProductName} - {MSICode} - {MaterialName}
Example: IG - Product A - MSI-001 - Steel Grade A

Validation Type Codes:
- IG: Incoming Goods Validation
- IP: In-progress/Inprocess Validation
- FI: Final Inspection
```

**State Management**:
- Local state for templates, control points, and form fields
- `QualityService` for API calls
- Temporary control points for untitled templates

**How to Create a Template**:

1. **Click "Add new template"**:
   - Creates "Untitled template" in sidebar
   - Clears all form fields
   - Enables form inputs

2. **Fill Basic Information**:
   - Select Validation Type (required)
   - Select Final Product (required, loads materials)
   - Select Material/Component (required, checks for duplicates)
   - Enter Tools to quality check (required)

3. **Add Control Points**:
   - Click "Add control point" button
   - Fill control point form (name, type, target value, unit, tolerance)
   - Control points are stored temporarily until template is saved

4. **Submit Template**:
   - Validates all required fields
   - Checks for duplicate material
   - Generates template name automatically
   - Saves template and all control points to database
   - Removes "Untitled template" from sidebar
   - Activates newly created template

**Why This Design?**:
- **Sidebar**: Easy navigation between templates
- **Searchable Dropdowns**: Handle large lists of products/materials
- **Unique Material Constraint**: Prevents duplicate templates
- **Auto-naming**: Ensures consistent naming convention
- **Temporary Storage**: Control points saved only when template is submitted
- **Locked Fields**: Existing templates cannot be modified (prevents data corruption)


### 4.4 Add Forms (add_forms/)

All add forms follow a consistent design pattern with:
- Header with title and description
- Scrollable form fields
- Section titles for grouping
- Required field indicators (red asterisk)
- Cancel and Submit buttons
- Loading states during submission
- Validation before submission

**Common Form Structure**:
```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      // Header
      Text("Add new [item type]"),
      Text("Please enter the details..."),
      
      // Scrollable Fields
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _sectionTitle("Section 1"),
              // Form fields...
              _sectionTitle("Section 2"),
              // More fields...
            ],
          ),
        ),
      ),
      
      // Buttons
      Row(
        children: [
          OutlinedButton("Cancel"),
          ElevatedButton("Submit"),
        ],
      ),
    ],
  ),
)
```

#### 4.4.1 Add MMD (add_mmd.dart)

**Purpose**: Add or edit Measuring and Monitoring Devices with calibration information.

**Sections**:
1. **Device Information**: Asset ID, Name, Brand, Accuracy Class, Supplier, Calibrated By, Specifications, Model Number, Serial Number, Quantity, Certificate Number, Location

2. **Purchase Information**: PO Number, PO Date, Invoice Number, Invoice Date, Cost, Extra Charges, Total Cost (auto-calculated)

3. **Calibration Information**: Frequency, Last Calibration Date, Next Calibration Date, Warranty Period, Status, Responsible Person, Operating Manual, Stock MSI Asset, Additional Notes

**Key Features**:
- Auto-calculates total cost (Cost + Extra Charges)
- Date pickers for all date fields
- Dropdown for calibration frequency and status
- Pre-populates fields when editing existing MMD
- Fetches complete details using V2 API
- Validates all required fields
- Prevents duplicate submissions

**How It Works**:

1. **New MMD**:
```dart
// Initialize with defaults
selectedCalibrationStatus = "Calibrated";

// On submit
_submitMmd() {
  // Validate form
  if (!_formKey.currentState!.validate()) return;
  
  // Prepare data
  final mmdData = {
    "MmdId": _assetIdCtrl.text,
    "BrandName": _brandNameCtrl.text,
    // ... all fields
    "Status": true, // Force active for new items
  };
  
  // Call API
  await ApiService().addMmd(mmdData);
  
  // Calculate next service date
  await nextServiceCalculationService.calculateNextServiceDateForNewItem();
  
  // Close dialog and refresh
  widget.submit();
}
```

2. **Edit MMD**:
```dart
// Fetch complete details
_fetchCompleteMMDDetails(mmdId) {
  final data = await apiService.getCompleteItemDetailsV2(mmdId, 'mmd');
  
  // Populate all fields
  _assetIdCtrl.text = data['MasterData']['itemID'];
  _brandNameCtrl.text = data['DetailedData']['brandName'];
  // ... populate all fields
  
  // Handle dropdowns
  selectedCalibrationFrequency = data['DetailedData']['calibrationFrequency'];
}
```

**Why This Design?**:
- **Sections**: Organize related fields logically
- **Auto-calculation**: Reduces user errors
- **V2 API**: Fetches both master and detailed data in one call
- **Status Handling**: Ensures new items are always active
- **Validation**: Prevents incomplete submissions


#### 4.4.2 Add Maintenance Service (add_maintenance_service.dart)

**Purpose**: Record maintenance/service activities and calculate next service due date.

**Key Features**:
- Auto-populates Service Date with current Next Service Due
- Auto-calculates Next Service Due based on maintenance frequency
- Date validation (Next Service Due cannot be before Service Date)
- Fetches maintenance frequency from item data
- Updates reactive state immediately
- Refreshes master list after submission

**Critical Flow**:
```
1. Dialog Opens
   ↓
2. Load current Next Service Due from parent/provider
   ↓
3. Auto-populate Service Date with Next Service Due
   ↓
4. User selects Service Date
   ↓
5. Auto-calculate Next Service Due (Service Date + Frequency)
   ↓
6. User submits form
   ↓
7. Update database
   ↓
8. Update reactive state (immediate UI update)
   ↓
9. Refresh master list (sync with database)
```

**Date Calculation Logic**:
```dart
_calculateNextServiceDue(serviceDate) {
  switch (frequency) {
    case 'daily': return serviceDate + 1 day;
    case 'weekly': return serviceDate + 7 days;
    case 'monthly': return serviceDate + 1 month;
    case 'quarterly': return serviceDate + 3 months;
    case 'half-yearly': return serviceDate + 6 months;
    case 'yearly': return serviceDate + 1 year;
  }
}
```

**Why This Design?**:
- **Auto-population**: Reduces user input errors
- **Auto-calculation**: Ensures consistent date calculations
- **Validation**: Prevents illogical dates
- **Reactive Updates**: UI reflects changes immediately
- **Database Sync**: Ensures data consistency

#### 4.4.3 Add Allocation (add_allocation.dart)

**Purpose**: Record asset allocation to employees/teams.

**Key Features**:
- Issue Date, Employee Name, Team Name, Purpose
- Expected Return Date, Actual Return Date (optional)
- Status dropdown (Allocated, Available, Returned, etc.)
- Date validation (Return dates cannot be before Issue Date)
- Updates availability status reactively

**Status Flow**:
```
Issue Date selected → Expected Return Date → Actual Return Date
                                                      ↓
                                            Status: Returned
                                                      ↓
                                    Availability Status: Available
```

**Why This Design?**:
- **Date Validation**: Ensures logical date sequences
- **Status Tracking**: Monitors asset usage
- **Reactive Updates**: Availability status updates across all views


## 5. Widgets Documentation

### 5.1 Generic Paginated Table (generic_paginated_table.dart)

**Purpose**: Reusable table widget with built-in pagination, sorting, and row selection.

**Why Use This Widget?**:
- **Reusability**: One widget for all tables in the app
- **Consistency**: Same look and feel across all tables
- **Type Safety**: Generic type parameter ensures type safety
- **Built-in Features**: Pagination, sorting, selection out of the box

**How to Use**:
```dart
GenericPaginatedTable<MaintenanceModel>(
  data: sortedData,              // List of items to display
  rowsPerPage: 5,                // Items per page
  minWidth: 1330,                // Minimum table width
  showCheckboxColumn: false,     // Show/hide checkboxes
  onRowTap: (record) {           // Handle row clicks
    // Navigate or show dialog
  },
  headers: [                     // Define column headers
    SortableHeader(
      title: 'Service Date',
      sortKey: 'serviceDate',
      width: 140,
      sortProvider: maintenanceSortProvider,
    ),
    // More headers...
  ],
  rowBuilder: (record, isSelected, onChanged) => [
    // Build each cell
    Container(
      width: 140,
      child: Text(record.serviceDate),
    ),
    // More cells...
  ],
)
```

**Features**:
- **Pagination**: Automatically splits data into pages
- **Sorting**: Integrates with SortableHeader widgets
- **Selection**: Optional checkbox column for multi-select
- **Responsive**: Horizontal scroll for wide tables
- **Customizable**: Full control over cell rendering

### 5.2 Sortable Header (sortable_header.dart)

**Purpose**: Table header with sorting functionality (ascending, descending, none).

**Sorting States**:
```
None → Ascending → Descending → None (cycles)
  ↓        ↓           ↓
 [▼]      [▲]        [▼]
```

**How It Works**:
```dart
SortableHeader(
  title: 'Service Date',        // Column title
  sortKey: 'serviceDate',       // Key for sorting
  width: 140,                   // Column width
  sortProvider: sortProvider,   // Riverpod provider
)

// Provider manages sort state
final sortProvider = StateNotifierProvider<SortNotifier, SortState>(
  (ref) => SortNotifier(),
);

// Sort state
class SortState {
  final String? sortColumn;
  final SortDirection direction;  // none, asc, desc
}
```

**Why This Design?**:
- **Three States**: None, Ascending, Descending (better UX than two states)
- **Visual Feedback**: Icons show current sort direction
- **Provider Integration**: State persists across rebuilds
- **Reusable**: Works with any data type

### 5.3 Searchable Dropdown (searchable_dropdown.dart)

**Purpose**: Dropdown with search functionality for large lists.

**Key Features**:
- Search input field
- Filtered results
- Keyboard navigation
- Clear button
- Disabled state
- Custom styling

**How to Use**:
```dart
SearchableDropdown(
  value: selectedValue,
  items: [
    {'id': 1, 'name': 'Product A'},
    {'id': 2, 'name': 'Product B'},
  ],
  hintText: 'Select product',
  labelText: 'Product *',
  enabled: true,
  onChanged: (value) {
    setState(() => selectedValue = value);
  },
)
```

**Why This Widget?**:
- **Large Lists**: Standard dropdown is unusable with 100+ items
- **Search**: Users can quickly find items
- **Accessibility**: Keyboard navigation support
- **Consistency**: Same UX across all dropdowns

### 5.4 Pagination Bar (pagination_bar.dart)

**Purpose**: Navigation controls for paginated data.

**UI Layout**:
```
[< Previous]  Page 1 of 10  [Next >]
```

**Features**:
- Previous/Next buttons
- Current page indicator
- Total pages display
- Disabled state for first/last page
- Callback for page changes

**How to Use**:
```dart
PaginationBar(
  currentPage: 1,
  totalPages: 10,
  onPageChanged: (newPage) {
    setState(() => currentPage = newPage);
    _loadData();
  },
)
```


## 6. Services Documentation

### 6.1 API Service (api_service.dart)

**Purpose**: Central service for all HTTP API calls to the backend.

**Base Configuration**:
```dart
class ApiService {
  final String baseUrl = 'http://localhost:5062/api';
  final Dio _dio = Dio();
  
  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
  }
}
```

**Key Methods**:

1. **Master List Operations**:
```dart
// Get paginated master list
Future<Map<String, dynamic>> getPaginatedMasterList({
  int page = 1,
  int pageSize = 10,
  String? searchQuery,
  String? sortColumn,
  String? sortDirection,
})

// Get single item by ID
Future<MasterListModel?> getMasterListById(String id)

// Get complete item details (V2 API)
Future<Map<String, dynamic>?> getCompleteItemDetailsV2(
  String itemId,
  String itemType,  // 'mmd', 'tool', 'asset', 'consumable'
)
```

2. **Maintenance Operations**:
```dart
// Get maintenance records for an asset
Future<List<MaintenanceModel>> getMaintenanceByAssetId(String assetId)

// Add maintenance record
Future<dynamic> addMaintenanceRecord(Map<String, dynamic> data)

// Update maintenance record
Future<dynamic> updateMaintenanceRecord(int id, Map<String, dynamic> data)
```

3. **Allocation Operations**:
```dart
// Get allocations for an asset
Future<List<AllocationModel>> getAllocationsByAssetId(String assetId)

// Add allocation record
Future<dynamic> addAllocationRecord(Map<String, dynamic> data)

// Update allocation record
Future<dynamic> updateAllocationRecord(int id, Map<String, dynamic> data)
```

4. **Item-Specific Operations**:
```dart
// Add MMD
Future<void> addMmd(Map<String, dynamic> data)

// Add Tool
Future<void> addTool(Map<String, dynamic> data)

// Add Asset/Consumable
Future<void> addAssetConsumable(Map<String, dynamic> data)

// Update complete item details (V2 API)
Future<bool> updateCompleteItemDetailsV2(
  String itemId,
  String itemType,
  Map<String, dynamic> data,
)
```

**Error Handling**:
```dart
try {
  final response = await _dio.get('/endpoint');
  return response.data;
} catch (e) {
  print('API Error: $e');
  rethrow;  // Let caller handle the error
}
```

**Why This Design?**:
- **Centralized**: All API calls in one place
- **Type Safety**: Returns typed models
- **Error Handling**: Consistent error handling
- **Timeout**: Prevents hanging requests
- **Reusable**: Methods used across multiple screens

### 6.2 Next Service Calculation Service

**Purpose**: Calculate next service due dates based on maintenance frequency.

**Key Methods**:
```dart
// Calculate for new item
Future<void> calculateNextServiceDateForNewItem({
  required String assetId,
  required String assetType,
  required DateTime createdDate,
  required String maintenanceFrequency,
})

// Calculate after maintenance
Future<void> calculateNextServiceDateAfterMaintenance({
  required String assetId,
  required String assetType,
  required DateTime serviceDate,
  required String maintenanceFrequency,
})

// Get maintenance frequency
Future<String?> getMaintenanceFrequency(
  String assetId,
  String assetType,
)
```

**Calculation Logic**:
```dart
DateTime calculateNextDate(DateTime baseDate, String frequency) {
  switch (frequency.toLowerCase()) {
    case 'daily': return baseDate.add(Duration(days: 1));
    case 'weekly': return baseDate.add(Duration(days: 7));
    case 'monthly': return DateTime(baseDate.year, baseDate.month + 1, baseDate.day);
    case 'quarterly': return DateTime(baseDate.year, baseDate.month + 3, baseDate.day);
    case 'half-yearly': return DateTime(baseDate.year, baseDate.month + 6, baseDate.day);
    case 'yearly': return DateTime(baseDate.year + 1, baseDate.month, baseDate.day);
    default: return DateTime(baseDate.year + 1, baseDate.month, baseDate.day);
  }
}
```

**Why This Service?**:
- **Consistency**: Same calculation logic everywhere
- **Reusability**: Used by multiple forms
- **Accuracy**: Handles edge cases (month boundaries, leap years)
- **Integration**: Updates both provider and database


## 7. State Management

### 7.1 Master List Provider (master_list_provider.dart)

**Purpose**: Manage master list data and provide reactive updates.

**Key Providers**:

1. **Paginated Master List Provider**:
```dart
final paginatedMasterListProvider = FutureProvider.autoDispose.family<
  Map<String, dynamic>,
  PaginationParams
>((ref, params) async {
  final apiService = ApiService();
  return await apiService.getPaginatedMasterList(
    page: params.page,
    pageSize: params.pageSize,
    searchQuery: params.searchQuery,
    sortColumn: params.sortColumn,
    sortDirection: params.sortDirection,
  );
});
```

2. **Force Refresh Provider**:
```dart
final forceRefreshMasterListProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    // Invalidate paginated provider
    ref.invalidate(paginatedMasterListProvider);
    // Wait for rebuild
    await Future.delayed(Duration(milliseconds: 100));
  };
});
```

**How to Use**:
```dart
// Watch for data
final masterListAsync = ref.watch(
  paginatedMasterListProvider(PaginationParams(...))
);

// Handle states
masterListAsync.when(
  data: (data) => _buildTable(data),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);

// Force refresh
await ref.read(forceRefreshMasterListProvider)();
```

### 7.2 Product State Provider (product_state_provider.dart)

**Purpose**: Manage reactive state for individual products (Next Service Due, Availability Status).

**Why Reactive State?**:
- **Immediate Updates**: UI updates before database refresh
- **Consistency**: All views show the same data
- **Performance**: Avoids unnecessary API calls

**Key Providers**:

1. **Product State Notifier**:
```dart
class ProductStateNotifier extends StateNotifier<Map<String, ProductState>> {
  ProductStateNotifier() : super({});
  
  void updateNextServiceDue(String assetId, String? nextServiceDue) {
    state = {
      ...state,
      assetId: ProductState(
        assetId: assetId,
        nextServiceDue: nextServiceDue,
        availabilityStatus: state[assetId]?.availabilityStatus,
      ),
    };
  }
  
  void updateAvailabilityStatus(String assetId, String status) {
    state = {
      ...state,
      assetId: ProductState(
        assetId: assetId,
        nextServiceDue: state[assetId]?.nextServiceDue,
        availabilityStatus: status,
      ),
    };
  }
}
```

2. **Product State by ID Provider**:
```dart
final productStateByIdProvider = Provider.family<ProductState?, String>(
  (ref, assetId) {
    final allStates = ref.watch(productStateProvider);
    return allStates[assetId];
  },
);
```

3. **Update Providers**:
```dart
final updateProductStateProvider = Provider<Function>((ref) {
  return (String assetId, {String? nextServiceDue}) {
    ref.read(productStateProvider.notifier)
       .updateNextServiceDue(assetId, nextServiceDue);
  };
});

final updateAvailabilityStatusProvider = Provider<Function>((ref) {
  return (String assetId, String status) {
    ref.read(productStateProvider.notifier)
       .updateAvailabilityStatus(assetId, status);
  };
});
```

**Usage Example**:
```dart
// In Product Detail Screen
Consumer(
  builder: (context, ref, child) {
    final productState = ref.watch(productStateByIdProvider(assetId));
    final nextServiceDue = productState?.nextServiceDue ?? 'N/A';
    
    return Text('Next Service Due: $nextServiceDue');
  },
)

// Update state after maintenance
final updateProductState = ref.read(updateProductStateProvider);
updateProductState(assetId, nextServiceDue: '2024-12-01');
```

### 7.3 Sorting Provider (sorting_provider.dart)

**Purpose**: Manage sorting state for tables.

**Sort State**:
```dart
class SortState {
  final String? sortColumn;
  final SortDirection direction;  // none, asc, desc
  
  SortState({this.sortColumn, this.direction = SortDirection.none});
}

enum SortDirection { none, asc, desc }
```

**Sort Notifier**:
```dart
class SortNotifier extends StateNotifier<SortState> {
  SortNotifier() : super(SortState());
  
  void toggleSort(String column) {
    if (state.sortColumn != column) {
      // New column: start with ascending
      state = SortState(column: column, direction: SortDirection.asc);
    } else {
      // Same column: cycle through states
      switch (state.direction) {
        case SortDirection.none:
          state = SortState(column: column, direction: SortDirection.asc);
          break;
        case SortDirection.asc:
          state = SortState(column: column, direction: SortDirection.desc);
          break;
        case SortDirection.desc:
          state = SortState(column: null, direction: SortDirection.none);
          break;
      }
    }
  }
}
```

**Providers for Different Tables**:
```dart
final masterListSortProvider = StateNotifierProvider<SortNotifier, SortState>(
  (ref) => SortNotifier(),
);

final maintenanceSortProvider = StateNotifierProvider<SortNotifier, SortState>(
  (ref) => SortNotifier(),
);

final allocationSortProvider = StateNotifierProvider<SortNotifier, SortState>(
  (ref) => SortNotifier(),
);
```


## 8. Models Documentation

### 8.1 Master List Model (master_list_model.dart)

**Purpose**: Represents an inventory item in the master list.

**Model Structure**:
```dart
class MasterListModel {
  final int sno;                    // Serial number
  final String itemType;            // MMD, Tool, Asset, Consumable
  final String refId;               // Reference ID
  final String assetId;             // Unique asset identifier
  final String type;                // Category/Type
  final String name;                // Item name
  final String supplier;            // Vendor/Supplier
  final String location;            // Storage location
  final DateTime createdDate;       // Creation date
  final String responsibleTeam;     // Responsible person/team
  final DateTime? nextServiceDue;   // Next service due date
  final String availabilityStatus;  // Available, In Use, etc.
  
  MasterListModel({
    required this.sno,
    required this.itemType,
    required this.refId,
    required this.assetId,
    required this.type,
    required this.name,
    required this.supplier,
    required this.location,
    required this.createdDate,
    required this.responsibleTeam,
    this.nextServiceDue,
    required this.availabilityStatus,
  });
  
  // Factory constructor from JSON
  factory MasterListModel.fromJson(Map<String, dynamic> json) {
    return MasterListModel(
      sno: json['sno'] ?? 0,
      itemType: json['itemType'] ?? '',
      refId: json['refId'] ?? '',
      assetId: json['assetId'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      supplier: json['supplier'] ?? '',
      location: json['location'] ?? '',
      createdDate: DateTime.parse(json['createdDate']),
      responsibleTeam: json['responsibleTeam'] ?? '',
      nextServiceDue: json['nextServiceDue'] != null 
          ? DateTime.parse(json['nextServiceDue']) 
          : null,
      availabilityStatus: json['availabilityStatus'] ?? '',
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'sno': sno,
      'itemType': itemType,
      'refId': refId,
      'assetId': assetId,
      'type': type,
      'name': name,
      'supplier': supplier,
      'location': location,
      'createdDate': createdDate.toIso8601String(),
      'responsibleTeam': responsibleTeam,
      'nextServiceDue': nextServiceDue?.toIso8601String(),
      'availabilityStatus': availabilityStatus,
    };
  }
}
```

**Why This Structure?**:
- **Immutable**: All fields are final (prevents accidental modifications)
- **Nullable**: nextServiceDue is optional (not all items need service)
- **Type Safety**: Strong typing prevents runtime errors
- **JSON Serialization**: Easy conversion to/from API responses

### 8.2 Maintenance Model (maintenance_model.dart)

**Purpose**: Represents a maintenance/service record.

**Model Structure**:
```dart
class MaintenanceModel {
  final int maintenanceId;
  final String assetId;
  final String assetType;
  final String itemName;
  final DateTime? serviceDate;
  final String serviceProviderCompany;
  final String serviceEngineerName;
  final String serviceType;
  final DateTime? nextServiceDue;
  final String? serviceNotes;
  final String maintenanceStatus;
  final double cost;
  final String responsibleTeam;
  final DateTime createdDate;
  
  MaintenanceModel({
    required this.maintenanceId,
    required this.assetId,
    required this.assetType,
    required this.itemName,
    this.serviceDate,
    required this.serviceProviderCompany,
    required this.serviceEngineerName,
    required this.serviceType,
    this.nextServiceDue,
    this.serviceNotes,
    required this.maintenanceStatus,
    required this.cost,
    required this.responsibleTeam,
    required this.createdDate,
  });
  
  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      maintenanceId: json['maintenanceId'] ?? 0,
      assetId: json['assetId'] ?? '',
      assetType: json['assetType'] ?? '',
      itemName: json['itemName'] ?? '',
      serviceDate: json['serviceDate'] != null 
          ? DateTime.parse(json['serviceDate']) 
          : null,
      serviceProviderCompany: json['serviceProviderCompany'] ?? '',
      serviceEngineerName: json['serviceEngineerName'] ?? '',
      serviceType: json['serviceType'] ?? '',
      nextServiceDue: json['nextServiceDue'] != null 
          ? DateTime.parse(json['nextServiceDue']) 
          : null,
      serviceNotes: json['serviceNotes'],
      maintenanceStatus: json['maintenanceStatus'] ?? '',
      cost: (json['cost'] ?? 0).toDouble(),
      responsibleTeam: json['responsibleTeam'] ?? '',
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}
```

### 8.3 Allocation Model (allocation_model.dart)

**Purpose**: Represents an asset allocation record.

**Model Structure**:
```dart
class AllocationModel {
  final int allocationId;
  final String assetId;
  final String assetType;
  final String itemName;
  final String employeeId;
  final String employeeName;
  final String teamName;
  final String purpose;
  final DateTime? issuedDate;
  final DateTime? expectedReturnDate;
  final DateTime? actualReturnDate;
  final String availabilityStatus;
  final DateTime createdDate;
  
  AllocationModel({
    required this.allocationId,
    required this.assetId,
    required this.assetType,
    required this.itemName,
    required this.employeeId,
    required this.employeeName,
    required this.teamName,
    required this.purpose,
    this.issuedDate,
    this.expectedReturnDate,
    this.actualReturnDate,
    required this.availabilityStatus,
    required this.createdDate,
  });
  
  factory AllocationModel.fromJson(Map<String, dynamic> json) {
    return AllocationModel(
      allocationId: json['allocationId'] ?? 0,
      assetId: json['assetId'] ?? '',
      assetType: json['assetType'] ?? '',
      itemName: json['itemName'] ?? '',
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      teamName: json['teamName'] ?? '',
      purpose: json['purpose'] ?? '',
      issuedDate: json['issuedDate'] != null 
          ? DateTime.parse(json['issuedDate']) 
          : null,
      expectedReturnDate: json['expectedReturnDate'] != null 
          ? DateTime.parse(json['expectedReturnDate']) 
          : null,
      actualReturnDate: json['actualReturnDate'] != null 
          ? DateTime.parse(json['actualReturnDate']) 
          : null,
      availabilityStatus: json['availabilityStatus'] ?? '',
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}
```


## 9. Routing & Navigation

### 9.1 AutoRoute Configuration (app_router.dart)

**Purpose**: Define application routes and navigation structure.

**Route Configuration**:
```dart
@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: DashboardRoute.page,
      initial: true,
      children: [
        AutoRoute(page: MasterListPaginatedRoute.page),
        AutoRoute(page: ProductDetailRoute.page),
        AutoRoute(page: QCTemplateRoute.page),
        AutoRoute(page: DefaultRoute.page),
      ],
    ),
  ];
}
```

**Navigation Methods**:

1. **Push (Navigate to new screen)**:
```dart
context.router.push(ProductDetailRoute(id: assetId));
```

2. **Pop (Go back)**:
```dart
context.router.pop();
```

3. **Replace (Replace current screen)**:
```dart
context.router.replace(MasterListPaginatedRoute());
```

**Route Parameters**:
```dart
@RoutePage()
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.id});
  
  final String id;  // Route parameter
  
  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}
```

**Why AutoRoute?**:
- **Type Safety**: Compile-time route checking
- **Code Generation**: Automatic route generation
- **Deep Linking**: Support for web URLs
- **Nested Routes**: Support for complex navigation structures

### 9.2 Navigation Flow

**Main Navigation Flow**:
```
Dashboard (Root)
├── Master List (Default)
│   └── Product Detail (On row click)
│       ├── Maintenance Tab
│       └── Allocation Tab
├── QC Templates
│   └── Control Points
└── Other Screens
```

**Dialog Navigation**:
```
Any Screen
└── Dialog Panel
    ├── Add MMD Form
    ├── Add Tool Form
    ├── Add Asset Form
    ├── Add Consumable Form
    ├── Add Maintenance Form
    ├── Add Allocation Form
    └── Add Control Point Form
```


## 10. UI/UX Design System

### 10.1 Color Palette

**Primary Colors**:
```dart
const primaryBlue = Color(0xFF00599A);      // Main brand color
const primaryDark = Color(0xFF003D6B);      // Darker variant
const primaryLight = Color(0xFFE3F2FD);     // Light background
```

**Neutral Colors**:
```dart
const black = Color(0xFF000000);            // Text primary
const darkGray = Color(0xFF111827);         // Text secondary
const mediumGray = Color(0xFF6B7280);       // Text tertiary
const lightGray = Color(0xFF9CA3AF);        // Disabled text
const borderGray = Color(0xFFD1D5DB);       // Borders
const backgroundGray = Color(0xFFF3F4F6);   // Backgrounds
const white = Color(0xFFFFFFFF);            // White
```

**Status Colors**:
```dart
// Success
const successGreen = Color(0xFF166534);     // Text
const successBg = Color(0xFFDCFCE7);        // Background

// Warning
const warningOrange = Color(0xFF92400E);    // Text
const warningBg = Color(0xFFFEF3C7);        // Background

// Error
const errorRed = Color(0xFF991B1B);         // Text
const errorBg = Color(0xFFFEE2E2);          // Background

// Info
const infoBlue = Color(0xFF1E40AF);         // Text
const infoBg = Color(0xFFDBEAFE);           // Background
```

### 10.2 Typography

**Font Family**: Fira Sans (Regular)

**Text Styles**:
```dart
// Headers
const h1 = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
const h2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
const h3 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
const h4 = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

// Body
const bodyLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
const bodyMedium = TextStyle(fontSize: 13, fontWeight: FontWeight.w400);
const bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

// Labels
const labelLarge = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
const labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
```

### 10.3 Spacing System

**Spacing Scale** (multiples of 4):
```dart
const spacing4 = 4.0;
const spacing8 = 8.0;
const spacing12 = 12.0;
const spacing16 = 16.0;
const spacing20 = 20.0;
const spacing24 = 24.0;
const spacing32 = 32.0;
const spacing40 = 40.0;
```

**Usage**:
- **4px**: Icon padding, small gaps
- **8px**: Between related elements
- **12px**: Between form fields
- **16px**: Section padding
- **20px**: Card padding
- **24px**: Between sections
- **32px**: Large gaps
- **40px**: Page margins

### 10.4 Component Styles

**Buttons**:
```dart
// Primary Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF00599A),
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
    elevation: 0,
  ),
  child: Text('Submit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
)

// Secondary Button
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: Color(0xFF00599A), width: 1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
  ),
  child: Text('Cancel', style: TextStyle(color: Color(0xFF00599A), fontSize: 12)),
)
```

**Input Fields**:
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Field Label *',
    hintText: 'Enter value',
    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF909090)),
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFFD2D2D2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFFD2D2D2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFF00599A), width: 1.2),
    ),
  ),
  style: TextStyle(fontSize: 12),
)
```

**Cards**:
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Color(0xFFE5E7EB)),
  ),
  padding: EdgeInsets.all(16),
  child: // Content
)
```

**Tables**:
```dart
// Header
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Color(0xFFF9FAFB),
    border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
  ),
  child: Text('Column Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
)

// Cell
Container(
  padding: EdgeInsets.all(12),
  child: Text('Cell Value', style: TextStyle(fontSize: 12, color: Color(0xFF374151))),
)
```

### 10.5 Layout Patterns

**Page Layout**:
```
┌─────────────────────────────────────────┐
│  Top Navigation Bar                     │
├─────────────────────────────────────────┤
│  Page Header (Title + Subtitle)         │
├─────────────────────────────────────────┤
│  Content Area                           │
│  ┌───────────────────────────────────┐  │
│  │                                   │  │
│  │  Main Content                     │  │
│  │                                   │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**Form Dialog Layout**:
```
┌─────────────────────────────────────────┐
│  Title                                  │
│  Description                            │
├─────────────────────────────────────────┤
│  ┌───────────────────────────────────┐  │
│  │                                   │  │
│  │  Scrollable Form Fields           │  │
│  │                                   │  │
│  └───────────────────────────────────┘  │
├─────────────────────────────────────────┤
│  [Cancel]              [Submit]         │
└─────────────────────────────────────────┘
```

**Table Layout**:
```
┌─────────────────────────────────────────┐
│  Search Bar              [Add Button]   │
├─────────────────────────────────────────┤
│  ☐ | Header 1 | Header 2 | Header 3    │
├─────────────────────────────────────────┤
│  ☐ | Data 1   | Data 2   | Data 3      │
│  ☐ | Data 1   | Data 2   | Data 3      │
├─────────────────────────────────────────┤
│  [< Prev]  Page 1 of 10  [Next >]       │
└─────────────────────────────────────────┘
```


## 11. Best Practices & Guidelines

### 11.1 Code Organization

**File Naming**:
- Use snake_case for file names: `master_list_screen.dart`
- Use PascalCase for class names: `MasterListScreen`
- Use camelCase for variables: `currentPage`

**Import Organization**:
```dart
// 1. Dart imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

// 4. Local imports
import 'package:inventory/services/api_service.dart';
import 'package:inventory/model/master_list_model.dart';
```

### 11.2 State Management Guidelines

**When to Use Providers**:
- ✅ Data that needs to be shared across multiple widgets
- ✅ Data that needs to persist across navigation
- ✅ Data that requires reactive updates
- ❌ Local UI state (use setState instead)
- ❌ Temporary form data (use controllers)

**Provider Naming Convention**:
```dart
// Data providers
final masterListProvider = ...
final productDataProvider = ...

// Action providers
final updateProductStateProvider = ...
final forceRefreshMasterListProvider = ...

// State notifier providers
final sortProvider = StateNotifierProvider<SortNotifier, SortState>(...)
```

### 11.3 API Integration Guidelines

**Error Handling**:
```dart
try {
  final data = await apiService.getData();
  // Handle success
} catch (e) {
  print('Error: $e');
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

**Loading States**:
```dart
bool _isLoading = false;

Future<void> _loadData() async {
  setState(() => _isLoading = true);
  try {
    final data = await apiService.getData();
    // Process data
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

**Preventing Duplicate Submissions**:
```dart
bool _isSubmitting = false;

Future<void> _submit() async {
  if (_isSubmitting) return;  // Prevent duplicate
  
  setState(() => _isSubmitting = true);
  try {
    await apiService.submit(data);
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}
```

### 11.4 Form Validation Guidelines

**Required Fields**:
```dart
TextFormField(
  validator: (v) => (v == null || v.isEmpty) 
      ? "The field cannot be empty" 
      : null,
)
```

**Number Validation**:
```dart
TextFormField(
  keyboardType: TextInputType.number,
  validator: (v) {
    if (v == null || v.isEmpty) return "Required";
    if (int.tryParse(v) == null) return "Enter only numbers";
    return null;
  },
)
```

**Date Validation**:
```dart
TextFormField(
  validator: (v) {
    if (v == null || v.isEmpty) return "Required";
    
    // Custom validation
    final date = DateTime.parse(v);
    if (date.isBefore(minDate)) {
      return "Date cannot be before $minDate";
    }
    return null;
  },
)
```

### 11.5 Performance Optimization

**Use const Constructors**:
```dart
const Text('Static text')  // ✅ Good
Text('Static text')        // ❌ Avoid
```

**Avoid Rebuilding Entire Trees**:
```dart
// ✅ Good: Only rebuild specific widget
Consumer(
  builder: (context, ref, child) {
    final data = ref.watch(dataProvider);
    return Text(data);
  },
)

// ❌ Avoid: Rebuilds entire screen
ref.watch(dataProvider);
```

**Use ListView.builder for Long Lists**:
```dart
// ✅ Good: Lazy loading
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// ❌ Avoid: Loads all items at once
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)
```

### 11.6 Accessibility Guidelines

**Semantic Labels**:
```dart
IconButton(
  icon: Icon(Icons.search),
  tooltip: 'Search',  // Helps screen readers
  onPressed: () {},
)
```

**Contrast Ratios**:
- Text on background: minimum 4.5:1
- Large text: minimum 3:1
- Interactive elements: minimum 3:1

**Touch Targets**:
- Minimum size: 44x44 pixels
- Spacing between targets: 8 pixels

### 11.7 Testing Guidelines

**Widget Testing**:
```dart
testWidgets('Master list displays items', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('Item 1'), findsOneWidget);
});
```

**Provider Testing**:
```dart
test('Sort provider toggles correctly', () {
  final container = ProviderContainer();
  final notifier = container.read(sortProvider.notifier);
  
  notifier.toggleSort('name');
  expect(container.read(sortProvider).direction, SortDirection.asc);
});
```

---

## 12. Common Patterns & Solutions

### 12.1 Reactive State Updates

**Problem**: UI doesn't update after API call
**Solution**: Use reactive providers and force refresh

```dart
// 1. Update reactive state
final updateState = ref.read(updateProductStateProvider);
updateState(assetId, nextServiceDue: newDate);

// 2. Refresh master list
await ref.read(forceRefreshMasterListProvider)();
```

### 12.2 Form Pre-population

**Problem**: Edit form doesn't show existing data
**Solution**: Fetch complete details and populate fields

```dart
void _populateForm() async {
  final data = await apiService.getCompleteDetails(id);
  setState(() {
    _nameCtrl.text = data['name'];
    _selectedType = data['type'];
    // ... populate all fields
  });
}
```

### 12.3 Date Handling

**Problem**: Date format inconsistencies
**Solution**: Use consistent format functions

```dart
String formatDate(DateTime? date) {
  if (date == null) return '';
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

DateTime? parseDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  return DateTime.tryParse(dateStr);
}
```

### 12.4 Search Implementation

**Problem**: Search is slow with large datasets
**Solution**: Use debouncing and server-side search

```dart
Timer? _debounceTimer;

void _onSearchChanged(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 300), () {
    // Perform search
    _loadData(searchQuery: query);
  });
}
```

---

## 13. Troubleshooting

### Common Issues & Solutions

**Issue**: "Provider was disposed"
**Solution**: Use `autoDispose` for providers that should clean up

```dart
final provider = FutureProvider.autoDispose<Data>((ref) async {
  return await fetchData();
});
```

**Issue**: "setState called after dispose"
**Solution**: Check `mounted` before calling setState

```dart
if (mounted) {
  setState(() {
    // Update state
  });
}
```

**Issue**: "Null check operator used on null value"
**Solution**: Use null-aware operators

```dart
final value = data?.field ?? 'default';  // ✅ Safe
final value = data!.field;               // ❌ Unsafe
```

**Issue**: Form validation not working
**Solution**: Ensure Form widget wraps all fields

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(validator: ...),
      // More fields
    ],
  ),
)

// Validate
if (_formKey.currentState!.validate()) {
  // Submit
}
```

---

## 14. Conclusion

This inventory management system demonstrates modern Flutter development practices with:

- **Clean Architecture**: Separation of concerns across layers
- **Reactive State Management**: Immediate UI updates with Riverpod
- **Reusable Components**: Generic widgets for consistency
- **Type Safety**: Strong typing prevents runtime errors
- **Performance**: Pagination and lazy loading for large datasets
- **User Experience**: Intuitive UI with clear feedback
- **Maintainability**: Well-organized code structure

### Key Takeaways

1. **Use Riverpod for state management** - It provides compile-time safety and better testability
2. **Implement reactive updates** - Users see changes immediately without manual refreshes
3. **Create reusable widgets** - Reduces code duplication and ensures consistency
4. **Validate user input** - Prevents bad data from entering the system
5. **Handle errors gracefully** - Show user-friendly messages instead of crashes
6. **Optimize performance** - Use pagination, lazy loading, and const constructors
7. **Follow design system** - Consistent UI improves user experience
8. **Document your code** - Makes maintenance easier for future developers

### Next Steps for Developers

1. **Familiarize with the codebase** - Read through the main screens and understand the flow
2. **Understand state management** - Learn how Riverpod providers work
3. **Study the API service** - Know how data flows from backend to UI
4. **Practice with forms** - Create or modify add forms to understand the pattern
5. **Experiment with widgets** - Modify existing widgets to see how they work
6. **Test your changes** - Always test thoroughly before deploying

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Maintained By**: Development Team

