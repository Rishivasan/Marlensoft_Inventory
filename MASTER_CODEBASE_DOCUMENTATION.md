# 📋 Master Codebase Documentation
## Inventory Management System - Complete Technical Overview

---

## 📑 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture Overview](#architecture-overview)
3. [Database Structure](#database-structure)
4. [Backend (.NET Core)](#backend-net-core)
5. [Frontend (Flutter)](#frontend-flutter)
6. [API Documentation](#api-documentation)
7. [Key Features](#key-features)
8. [Development Setup](#development-setup)
9. [Deployment Guide](#deployment-guide)
10. [Testing Strategy](#testing-strategy)
11. [Performance Optimizations](#performance-optimizations)
12. [Security Implementation](#security-implementation)
13. [Troubleshooting Guide](#troubleshooting-guide)

---

## 🎯 Project Overview

### **System Purpose**
A comprehensive inventory management system for tracking tools, assets, MMDs (Measuring and Monitoring Devices), and consumables across an organization.

### **Technology Stack**
- **Frontend**: Flutter (Dart) - Cross-platform web/mobile application
- **Backend**: .NET Core 9.0 - RESTful API with clean architecture
- **Database**: SQL Server - Relational database with optimized queries
- **Architecture**: Clean Architecture with Repository Pattern
- **State Management**: Riverpod (Flutter)
- **Routing**: Auto Route (Flutter)
- **HTTP Client**: Dio (Flutter)

### **Key Capabilities**
- ✅ Multi-category inventory tracking (Tools, Assets, MMDs, Consumables)
- ✅ Maintenance scheduling and tracking
- ✅ Allocation management with return tracking
- ✅ Advanced search and filtering
- ✅ Bulk operations (delete, export)
- ✅ Real-time data synchronization
- ✅ Responsive design for all devices
- ✅ Role-based access control

---

## 🏗️ Architecture Overview

### **System Architecture**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter Web   │    │  .NET Core API  │    │  SQL Server DB  │
│   (Frontend)    │◄──►│   (Backend)     │◄──►│   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **Clean Architecture Layers**
```
┌─────────────────────────────────────────┐
│              Presentation               │ ← Controllers
├─────────────────────────────────────────┤
│               Application               │ ← Services
├─────────────────────────────────────────┤
│                Domain                   │ ← Models/Entities
├─────────────────────────────────────────┤
│             Infrastructure              │ ← Repositories
└─────────────────────────────────────────┘
```

### **Data Flow**
1. **User Interaction** → Flutter UI Components
2. **State Management** → Riverpod Providers
3. **API Calls** → Dio HTTP Client
4. **Backend Processing** → .NET Controllers → Services → Repositories
5. **Database Operations** → Dapper ORM → SQL Server
6. **Response Flow** → JSON → DTOs → UI Updates

---

## 🗄️ Database Structure

### **Core Tables**

#### **1. MasterRegister** (Central inventory table)
```sql
CREATE TABLE MasterRegister (
    Sno INT IDENTITY(1,1) PRIMARY KEY,
    ItemType NVARCHAR(50) NOT NULL,
    RefId NVARCHAR(50) UNIQUE NOT NULL,
    AssetId NVARCHAR(50) NOT NULL,
    Type NVARCHAR(50) NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Supplier NVARCHAR(200),
    Location NVARCHAR(200),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ResponsibleTeam NVARCHAR(200),
    NextServiceDue DATETIME2,
    AvailabilityStatus NVARCHAR(50) DEFAULT 'Available'
);
```

#### **2. Tools** (Tool-specific details)
```sql
CREATE TABLE Tools (
    ToolsId NVARCHAR(50) PRIMARY KEY,
    ToolName NVARCHAR(200) NOT NULL,
    ToolType NVARCHAR(100),
    ArticleCode NVARCHAR(100),
    AssociatedProduct NVARCHAR(200),
    Vendor NVARCHAR(200),
    StorageLocation NVARCHAR(200),
    Specifications NVARCHAR(MAX),
    PoNumber NVARCHAR(100),
    PoDate DATETIME2,
    InvoiceNumber NVARCHAR(100),
    InvoiceDate DATETIME2,
    ToolCost DECIMAL(18,2),
    ExtraCharges DECIMAL(18,2),
    Lifespan NVARCHAR(100),
    AuditInterval NVARCHAR(100),
    MaintainanceFrequency NVARCHAR(100),
    HandlingCertificate BIT DEFAULT 0,
    LastAuditDate DATETIME2,
    LastAuditNotes NVARCHAR(MAX),
    MaxOutput NVARCHAR(100),
    Status INT DEFAULT 1,
    ResponsibleTeam NVARCHAR(200),
    MsiAsset NVARCHAR(100),
    KernAsset NVARCHAR(100),
    Notes NVARCHAR(MAX),
    CreatedDate DATETIME2 DEFAULT GETDATE()
);
```

#### **3. MMDs** (Measuring & Monitoring Devices)
```sql
CREATE TABLE MMDs (
    MmdId NVARCHAR(50) PRIMARY KEY,
    MmdName NVARCHAR(200) NOT NULL,
    MmdType NVARCHAR(100),
    ArticleCode NVARCHAR(100),
    AssociatedProduct NVARCHAR(200),
    Vendor NVARCHAR(200),
    StorageLocation NVARCHAR(200),
    Specifications NVARCHAR(MAX),
    -- Purchase Information
    PoNumber NVARCHAR(100),
    PoDate DATETIME2,
    InvoiceNumber NVARCHAR(100),
    InvoiceDate DATETIME2,
    MmdCost DECIMAL(18,2),
    ExtraCharges DECIMAL(18,2),
    -- Calibration & Maintenance
    CalibrationFrequency NVARCHAR(100),
    LastCalibrationDate DATETIME2,
    NextCalibrationDue DATETIME2,
    CalibrationCertificate BIT DEFAULT 0,
    CalibrationNotes NVARCHAR(MAX),
    -- Technical Specifications
    MeasurementRange NVARCHAR(200),
    Accuracy NVARCHAR(100),
    Resolution NVARCHAR(100),
    OperatingConditions NVARCHAR(MAX),
    -- Status & Management
    Status INT DEFAULT 1,
    ResponsibleTeam NVARCHAR(200),
    MsiAsset NVARCHAR(100),
    KernAsset NVARCHAR(100),
    Notes NVARCHAR(MAX),
    CreatedDate DATETIME2 DEFAULT GETDATE()
);
```

#### **4. AssetsConsumables** (Assets & Consumables)
```sql
CREATE TABLE AssetsConsumables (
    AssetId NVARCHAR(50) PRIMARY KEY,
    AssetName NVARCHAR(200) NOT NULL,
    AssetType NVARCHAR(100),
    Category NVARCHAR(100),
    Vendor NVARCHAR(200),
    StorageLocation NVARCHAR(200),
    Specifications NVARCHAR(MAX),
    -- Purchase Information
    PoNumber NVARCHAR(100),
    PoDate DATETIME2,
    InvoiceNumber NVARCHAR(100),
    InvoiceDate DATETIME2,
    AssetCost DECIMAL(18,2),
    ExtraCharges DECIMAL(18,2),
    -- Inventory Management
    CurrentStock INT DEFAULT 0,
    MinimumStock INT DEFAULT 0,
    MaximumStock INT DEFAULT 0,
    ReorderLevel INT DEFAULT 0,
    -- Status & Management
    Status INT DEFAULT 1,
    ResponsibleTeam NVARCHAR(200),
    MsiAsset NVARCHAR(100),
    KernAsset NVARCHAR(100),
    Notes NVARCHAR(MAX),
    CreatedDate DATETIME2 DEFAULT GETDATE()
);
```

#### **5. Maintenance** (Service & maintenance records)
```sql
CREATE TABLE Maintenance (
    MaintenanceId INT IDENTITY(1,1) PRIMARY KEY,
    AssetType NVARCHAR(50) NOT NULL,
    AssetId NVARCHAR(50) NOT NULL,
    ItemName NVARCHAR(200),
    ServiceDate DATETIME2 NOT NULL,
    ServiceProviderCompany NVARCHAR(200),
    ServiceEngineerName NVARCHAR(200),
    ServiceType NVARCHAR(100),
    NextServiceDue DATETIME2,
    ServiceNotes NVARCHAR(MAX),
    MaintenanceStatus NVARCHAR(50) DEFAULT 'Pending',
    Cost DECIMAL(18,2),
    ResponsibleTeam NVARCHAR(200),
    CreatedDate DATETIME2 DEFAULT GETDATE()
);
```

#### **6. Allocation** (Item allocation tracking)
```sql
CREATE TABLE Allocation (
    AllocationId INT IDENTITY(1,1) PRIMARY KEY,
    AssetType NVARCHAR(50) NOT NULL,
    AssetId NVARCHAR(50) NOT NULL,
    ItemName NVARCHAR(200),
    EmployeeId NVARCHAR(50),
    EmployeeName NVARCHAR(200),
    TeamName NVARCHAR(200),
    Purpose NVARCHAR(MAX),
    IssuedDate DATETIME2 NOT NULL,
    ExpectedReturnDate DATETIME2,
    ActualReturnDate DATETIME2,
    AvailabilityStatus NVARCHAR(50) DEFAULT 'Allocated',
    CreatedDate DATETIME2 DEFAULT GETDATE()
);
```

### **Database Relationships**
- **MasterRegister** ↔ **Tools/MMDs/AssetsConsumables** (1:1 via AssetId/RefId)
- **MasterRegister** ↔ **Maintenance** (1:N via AssetId)
- **MasterRegister** ↔ **Allocation** (1:N via AssetId)

### **Indexes & Performance**
```sql
-- Primary indexes for fast lookups
CREATE INDEX IX_MasterRegister_AssetId ON MasterRegister(AssetId);
CREATE INDEX IX_MasterRegister_Type ON MasterRegister(Type);
CREATE INDEX IX_Maintenance_AssetId ON Maintenance(AssetId);
CREATE INDEX IX_Allocation_AssetId ON Allocation(AssetId);

-- Composite indexes for common queries
CREATE INDEX IX_MasterRegister_Type_Status ON MasterRegister(Type, AvailabilityStatus);
CREATE INDEX IX_Maintenance_Status_Date ON Maintenance(MaintenanceStatus, ServiceDate);
```

---

## 🔧 Backend (.NET Core)

### **Project Structure**
```
Backend/InventoryManagement/
├── Controllers/           # API endpoints
├── Services/             # Business logic layer
├── Repositories/         # Data access layer
├── Models/
│   ├── DTOs/            # Data transfer objects
│   └── Entities/        # Database entities
├── Data/                # Database context
└── Program.cs           # Application entry point
```

### **Key Controllers**

#### **1. MasterRegisterController.cs**
```csharp
[ApiController]
public class MasterRegisterController : ControllerBase
{
    [HttpGet("api/enhanced-master-list")]
    public async Task<IActionResult> GetEnhancedMasterList()
    
    [HttpPost("api/master-register")]
    public async Task<IActionResult> CreateMasterRegister([FromBody] MasterRegister register)
    
    [HttpDelete("api/master-register/{id}")]
    public async Task<IActionResult> DeleteMasterRegister(string id)
}
```

#### **2. ItemDetailsController.cs**
```csharp
[ApiController]
public class ItemDetailsController : ControllerBase
{
    [HttpGet("api/item-details/{itemId}")]
    public async Task<IActionResult> GetItemDetails(string itemId)
    
    [HttpPut("api/item-details/{itemId}")]
    public async Task<IActionResult> UpdateItemDetails(string itemId, [FromBody] JsonElement updateData)
}
```

#### **3. ToolsController.cs**
```csharp
[ApiController]
public class ToolsController : ControllerBase
{
    [HttpGet("api/tools")]
    public async Task<IActionResult> GetTools()
    
    [HttpPost("api/addtools")]
    public async Task<IActionResult> CreateTool([FromBody] ToolEntity tool)
    
    [HttpDelete("api/Tools/{id}")]
    public async Task<IActionResult> DeleteTool(string id)
}
```

### **Service Layer Architecture**

#### **Interface Pattern**
```csharp
public interface IMasterRegisterService
{
    Task<IEnumerable<EnhancedMasterListDto>> GetEnhancedMasterListAsync();
    Task<bool> CreateMasterRegisterAsync(MasterRegister register);
    Task<bool> DeleteMasterRegisterAsync(string id);
}
```

#### **Service Implementation**
```csharp
public class MasterRegisterService : IMasterRegisterService
{
    private readonly IMasterRegisterRepository _repository;
    
    public MasterRegisterService(IMasterRegisterRepository repository)
    {
        _repository = repository;
    }
    
    public async Task<IEnumerable<EnhancedMasterListDto>> GetEnhancedMasterListAsync()
    {
        return await _repository.GetEnhancedMasterListAsync();
    }
}
```

### **Repository Pattern with Dapper**

#### **Repository Interface**
```csharp
public interface IMasterRegisterRepository
{
    Task<IEnumerable<EnhancedMasterListDto>> GetEnhancedMasterListAsync();
    Task<int> CreateMasterRegisterAsync(MasterRegister register);
    Task<int> DeleteMasterRegisterAsync(string id);
}
```

#### **Repository Implementation**
```csharp
public class MasterRegisterRepository : IMasterRegisterRepository
{
    private readonly DapperContext _context;
    
    public async Task<IEnumerable<EnhancedMasterListDto>> GetEnhancedMasterListAsync()
    {
        var query = @"
            SELECT 
                mr.Sno,
                mr.ItemType,
                mr.RefId as ItemID,
                mr.AssetId,
                mr.Type,
                mr.Name as ItemName,
                mr.Supplier as Vendor,
                mr.Location as StorageLocation,
                mr.CreatedDate,
                mr.ResponsibleTeam,
                mr.NextServiceDue,
                mr.AvailabilityStatus
            FROM MasterRegister mr
            ORDER BY mr.CreatedDate DESC";
            
        using var connection = _context.CreateConnection();
        return await connection.QueryAsync<EnhancedMasterListDto>(query);
    }
}
```

### **Dependency Injection Setup**
```csharp
// Program.cs
builder.Services.AddScoped<IMasterRegisterService, MasterRegisterService>();
builder.Services.AddScoped<IMasterRegisterRepository, MasterRegisterRepository>();
builder.Services.AddScoped<IToolService, ToolsService>();
builder.Services.AddScoped<IToolRepository, ToolRepository>();
// ... other services
```

### **Database Connection**
```csharp
public class DapperContext
{
    private readonly IConfiguration _configuration;
    private readonly string _connectionString;
    
    public DapperContext(IConfiguration configuration)
    {
        _configuration = configuration;
        _connectionString = _configuration.GetConnectionString("DefaultConnection");
    }
    
    public IDbConnection CreateConnection() => new SqlConnection(_connectionString);
}
```

---

## 🎨 Frontend (Flutter)

### **Project Structure**
```
Frontend/inventory/lib/
├── core/
│   └── api/             # HTTP client configuration
├── dialogs/             # Reusable dialog components
├── features/            # Feature-specific modules
├── model/               # Data models
├── providers/           # Riverpod state management
├── routers/             # Navigation routing
├── screens/             # UI screens
│   ├── add_forms/       # Add/Edit forms
│   └── ...
├── services/            # API service layer
├── utils/               # Utility functions
├── widgets/             # Reusable UI components
└── main.dart           # Application entry point
```

### **State Management (Riverpod)**

#### **Providers**
```dart
// Master List Provider
final masterListProvider = FutureProvider<List<MasterListModel>>((ref) async {
  final apiService = ApiService();
  return await apiService.getMasterList();
});

// Search Provider
final searchProvider = StateProvider<String>((ref) => '');

// Selection Provider
final selectedItemsProvider = StateProvider<Set<String>>((ref) => {});

// Sorting Provider
final sortProvider = StateNotifierProvider<SortNotifier, SortState>((ref) {
  return SortNotifier();
});
```

#### **State Notifiers**
```dart
class SortNotifier extends StateNotifier<SortState> {
  SortNotifier() : super(const SortState());
  
  void sortBy(String column) {
    if (state.sortColumn == column) {
      // Toggle direction
      final newDirection = state.direction == SortDirection.ascending
          ? SortDirection.descending
          : SortDirection.ascending;
      state = state.copyWith(direction: newDirection);
    } else {
      // New column
      state = state.copyWith(
        sortColumn: column,
        direction: SortDirection.ascending,
      );
    }
  }
}
```

### **API Service Layer**

#### **HTTP Client Setup (Dio)**
```dart
class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();
  
  late Dio _dio;
  
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://localhost:7240',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
    
    // Add interceptors for logging, error handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
  
  Dio get dio => _dio;
}
```

#### **API Service Implementation**
```dart
class ApiService {
  final Dio _dio = DioClient().dio;
  final String baseUrl = 'https://localhost:7240';
  
  // Get master list
  Future<List<MasterListModel>> getMasterList() async {
    try {
      final response = await _dio.get('$baseUrl/api/enhanced-master-list');
      final List<dynamic> data = response.data;
      return data.map((json) => MasterListModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load master list: $e');
    }
  }
  
  // Get item details
  Future<Map<String, dynamic>?> getCompleteItemDetails(String itemId, String itemType) async {
    try {
      final response = await _dio.get('$baseUrl/api/item-details/$itemId');
      if (response.statusCode == 200) {
        final data = response.data;
        return data['DetailedData'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error fetching item details: $e');
      return null;
    }
  }
}
```

### **Routing (Auto Route)**

#### **Router Configuration**
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

#### **Navigation Usage**
```dart
// Navigate to product detail
context.router.push(ProductDetailRoute(id: item.refId));

// Navigate back
context.router.pop();
```

### **Key UI Components**

#### **1. GenericPaginatedTable**
```dart
class GenericPaginatedTable<T> extends StatefulWidget {
  final List<T> data;
  final List<Widget> Function(T item, bool isSelected, Function(bool?) onChanged) rowBuilder;
  final List<Widget> headers;
  final int rowsPerPage;
  final Function(T item)? onRowTap;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final bool showCheckboxColumn;
  
  // Implementation with pagination, sorting, selection
}
```

#### **2. SortableHeader**
```dart
class SortableHeader extends ConsumerWidget {
  final String title;
  final String sortKey;
  final double width;
  final NotifierProvider<SortNotifier, SortState> sortProvider;
  
  // Implementation with sort icons and click handling
}
```

#### **3. PaginationControls**
```dart
class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int rowsPerPage;
  final int totalItems;
  final Function(int) onPageChanged;
  final Function(int) onRowsPerPageChanged;
  
  // Implementation with page navigation and rows per page selection
}
```

### **Form Management**

#### **Add/Edit Forms**
```dart
class AddTool extends StatefulWidget {
  final VoidCallback submit;
  final MasterListModel? existingData;
  
  @override
  State<AddTool> createState() => _AddToolState();
}

class _AddToolState extends State<AddTool> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _toolIdCtrl = TextEditingController();
  final _toolNameCtrl = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _populateFormWithExistingData();
    }
  }
  
  void _populateFormWithExistingData() {
    final data = widget.existingData!;
    _toolIdCtrl.text = data.assetId;
    _toolNameCtrl.text = data.name;
    // Fetch complete details from API
    _fetchCompleteToolDetails(data.assetId);
  }
}
```

---

## 📡 API Documentation

### **Base URL**
```
https://localhost:7240
```

### **Authentication**
Currently using development setup without authentication. Production should implement JWT tokens.

### **Core Endpoints**

#### **Master Register**
```http
GET /api/enhanced-master-list
Response: List<EnhancedMasterListDto>

POST /api/master-register
Body: MasterRegister
Response: Success message

DELETE /api/master-register/{id}
Response: Success message
```

#### **Item Details**
```http
GET /api/item-details/{itemId}
Response: {
  "ItemType": "Tool",
  "MasterData": { ... },
  "DetailedData": { ... }
}

PUT /api/item-details/{itemId}
Body: Item-specific data
Response: Success message
```

#### **Tools**
```http
GET /api/tools
Response: List<ToolDto>

POST /api/addtools
Body: ToolEntity
Response: Success message

DELETE /api/Tools/{id}
Response: Success message
```

#### **Maintenance**
```http
GET /api/maintenance
Response: List<MaintenanceModel>

GET /api/maintenance/asset/{assetId}
Response: List<MaintenanceModel>

POST /api/maintenance
Body: MaintenanceEntity
Response: Success message
```

#### **Allocation**
```http
GET /api/allocations
Response: List<AllocationModel>

GET /api/allocations/asset/{assetId}
Response: List<AllocationModel>

POST /api/allocations
Body: AllocationEntity
Response: Success message
```

### **Error Handling**
```json
{
  "error": "Error message",
  "statusCode": 400,
  "timestamp": "2024-01-01T00:00:00Z"
}
```

---

## ✨ Key Features

### **1. Multi-Category Inventory Management**
- **Tools**: Hand tools, power tools, measuring instruments
- **Assets**: Furniture, computers, vehicles, machinery
- **MMDs**: Measuring and monitoring devices with calibration tracking
- **Consumables**: Materials, chemicals, disposable items

### **2. Advanced Search & Filtering**
- Real-time search across all fields
- Type-based filtering
- Status-based filtering
- Date range filtering
- Advanced query capabilities

### **3. Maintenance Management**
- Service scheduling and tracking
- Maintenance history
- Cost tracking
- Service provider management
- Next service due alerts

### **4. Allocation Tracking**
- Employee allocation tracking
- Return date management
- Purpose documentation
- Availability status updates
- Overdue tracking

### **5. Data Export & Import**
- Excel export functionality
- CSV export options
- Bulk data import
- Report generation

### **6. User Interface Features**
- Responsive design for all devices
- Dark/light theme support
- Intuitive navigation
- Real-time updates
- Bulk operations (select all, delete multiple)

### **7. Performance Features**
- Pagination for large datasets
- Lazy loading
- Optimized database queries
- Caching strategies
- Efficient state management

---

## 🚀 Development Setup

### **Prerequisites**
- Flutter SDK (3.0+)
- .NET Core SDK (9.0+)
- SQL Server (2019+)
- Visual Studio Code / Visual Studio
- Git

### **Backend Setup**
```bash
# Clone repository
git clone <repository-url>
cd Backend/InventoryManagement

# Restore packages
dotnet restore

# Update database connection string in appsettings.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=InventoryDB;Trusted_Connection=true;"
  }
}

# Run database scripts
# Execute CREATE_TABLES.sql in SQL Server Management Studio

# Run the application
dotnet run
```

### **Frontend Setup**
```bash
# Navigate to frontend directory
cd Frontend/inventory

# Get Flutter dependencies
flutter pub get

# Generate route files
flutter packages pub run build_runner build

# Run the application
flutter run -d chrome
```

### **Database Setup**
```sql
-- Create database
CREATE DATABASE InventoryDB;

-- Execute table creation scripts
-- Run CREATE_TABLES.sql

-- Insert sample data (optional)
-- Run sample_data.sql
```

---

## 🚢 Deployment Guide

### **Backend Deployment (IIS)**
```bash
# Publish the application
dotnet publish -c Release -o ./publish

# Copy to IIS wwwroot
# Configure IIS application pool (.NET Core)
# Update connection strings for production
```

### **Frontend Deployment (Web)**
```bash
# Build for web
flutter build web

# Deploy to web server
# Copy build/web/* to web server directory
```

### **Database Deployment**
```sql
-- Production database setup
-- Execute all table creation scripts
-- Set up proper indexes
-- Configure backup strategies
-- Set up monitoring
```

---

## 🧪 Testing Strategy

### **Backend Testing**
```csharp
[TestClass]
public class MasterRegisterServiceTests
{
    [TestMethod]
    public async Task GetEnhancedMasterList_ReturnsData()
    {
        // Arrange
        var mockRepository = new Mock<IMasterRegisterRepository>();
        var service = new MasterRegisterService(mockRepository.Object);
        
        // Act
        var result = await service.GetEnhancedMasterListAsync();
        
        // Assert
        Assert.IsNotNull(result);
    }
}
```

### **Frontend Testing**
```dart
void main() {
  group('MasterListModel', () {
    test('should create model from JSON', () {
      // Arrange
      final json = {
        'ItemID': 'TEST001',
        'ItemName': 'Test Item',
        'Type': 'Tool'
      };
      
      // Act
      final model = MasterListModel.fromJson(json);
      
      // Assert
      expect(model.refId, 'TEST001');
      expect(model.name, 'Test Item');
    });
  });
}
```

### **API Testing Scripts**
```powershell
# PowerShell API testing
$baseUrl = "https://localhost:7240"
$response = Invoke-RestMethod -Uri "$baseUrl/api/enhanced-master-list" -Method Get
Write-Host "Retrieved $($response.Count) items"
```

---

## ⚡ Performance Optimizations

### **Database Optimizations**
- Proper indexing on frequently queried columns
- Query optimization with execution plans
- Connection pooling
- Stored procedures for complex operations

### **Backend Optimizations**
- Async/await patterns throughout
- Efficient LINQ queries
- Response caching where appropriate
- Minimal API responses (DTOs)

### **Frontend Optimizations**
- Lazy loading of data
- Pagination to limit data transfer
- Efficient state management with Riverpod
- Image optimization and caching
- Bundle size optimization

---

## 🔒 Security Implementation

### **Backend Security**
- Input validation and sanitization
- SQL injection prevention (parameterized queries)
- CORS configuration
- HTTPS enforcement
- Error handling without information disclosure

### **Frontend Security**
- Input validation on forms
- XSS prevention
- Secure HTTP client configuration
- Environment-specific configurations

### **Database Security**
- Proper user permissions
- Encrypted connections
- Regular security updates
- Backup encryption

---

## 🔧 Troubleshooting Guide

### **Common Backend Issues**

#### **Database Connection Issues**
```csharp
// Check connection string
// Verify SQL Server is running
// Check firewall settings
// Validate user permissions
```

#### **API Not Responding**
```bash
# Check if service is running
netstat -an | findstr :7240

# Check application logs
# Verify CORS settings
# Check SSL certificate
```

### **Common Frontend Issues**

#### **API Connection Failed**
```dart
// Check base URL configuration
// Verify CORS settings
// Check network connectivity
// Validate SSL certificates
```

#### **State Not Updating**
```dart
// Verify Riverpod provider setup
// Check consumer widgets
// Validate state mutations
// Review provider dependencies
```

### **Database Issues**

#### **Performance Problems**
```sql
-- Check query execution plans
-- Verify indexes are being used
-- Monitor database performance counters
-- Check for blocking queries
```

#### **Data Integrity Issues**
```sql
-- Verify foreign key constraints
-- Check for orphaned records
-- Validate data types
-- Review transaction isolation levels
```

---

## 📊 Monitoring & Logging

### **Backend Logging**
```csharp
// Configure logging in Program.cs
builder.Services.AddLogging(builder => {
    builder.AddConsole();
    builder.AddFile("logs/app-{Date}.txt");
});

// Use in controllers/services
private readonly ILogger<MasterRegisterController> _logger;

_logger.LogInformation("Processing request for item {ItemId}", itemId);
```

### **Frontend Logging**
```dart
// Debug logging
print('DEBUG: API call successful');

// Error logging
try {
  // API call
} catch (e) {
  print('ERROR: API call failed: $e');
}
```

### **Database Monitoring**
```sql
-- Monitor query performance
SELECT TOP 10 
    total_elapsed_time/execution_count AS avg_time,
    text
FROM sys.dm_exec_query_stats 
CROSS APPLY sys.dm_exec_sql_text(sql_handle)
ORDER BY avg_time DESC;
```

---

## 📈 Future Enhancements

### **Planned Features**
- [ ] Real-time notifications
- [ ] Advanced reporting dashboard
- [ ] Mobile app (iOS/Android)
- [ ] Barcode/QR code scanning
- [ ] Integration with external systems
- [ ] Advanced analytics and insights
- [ ] Multi-tenant support
- [ ] Workflow automation
- [ ] Document management
- [ ] Audit trail enhancements

### **Technical Improvements**
- [ ] Microservices architecture
- [ ] Event-driven architecture
- [ ] GraphQL API
- [ ] Redis caching
- [ ] Elasticsearch integration
- [ ] Docker containerization
- [ ] Kubernetes orchestration
- [ ] CI/CD pipeline
- [ ] Automated testing
- [ ] Performance monitoring

---

## 📞 Support & Contact

### **Development Team**
- **Backend Developer**: .NET Core, SQL Server, API Development
- **Frontend Developer**: Flutter, Dart, UI/UX
- **Database Administrator**: SQL Server, Performance Tuning
- **DevOps Engineer**: Deployment, Monitoring, Infrastructure

### **Documentation**
- **API Documentation**: Available at `/swagger` endpoint
- **Database Schema**: See `database_schema.sql`
- **Deployment Guide**: See `DEPLOYMENT.md`
- **User Manual**: See `USER_GUIDE.md`

---

## 📝 Version History

### **v1.0.0** (Current)
- ✅ Complete inventory management system
- ✅ Multi-category support (Tools, Assets, MMDs, Consumables)
- ✅ Maintenance and allocation tracking
- ✅ Advanced search and filtering
- ✅ Responsive web interface
- ✅ Export functionality
- ✅ Bulk operations

### **Upcoming Releases**
- **v1.1.0**: Mobile app support, enhanced reporting
- **v1.2.0**: Real-time notifications, workflow automation
- **v2.0.0**: Microservices architecture, advanced analytics

---

*Last Updated: January 2025*
*Document Version: 1.0*
*Maintained by: Development Team*