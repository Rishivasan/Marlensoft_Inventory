# BACKEND COMPREHENSIVE DOCUMENTATION
# Inventory Management System - ASP.NET Core Web API

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Core Configuration](#core-configuration)
4. [Database Architecture](#database-architecture)
5. [Controllers Documentation](#controllers-documentation)
6. [Repositories Documentation](#repositories-documentation)
7. [Services Documentation](#services-documentation)
8. [Models & Entities](#models--entities)
9. [API Endpoints Reference](#api-endpoints-reference)
10. [Data Flow & Patterns](#data-flow--patterns)
11. [Error Handling & Logging](#error-handling--logging)
12. [Best Practices & Guidelines](#best-practices--guidelines)

---

## 1. Architecture Overview

### Application Architecture
The Inventory Management Backend follows a **Clean Architecture** pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────────┐
│         Presentation Layer (Controllers)        │
│  HTTP Requests → Controllers → HTTP Responses   │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│         Business Logic Layer (Services)         │
│  Business Rules, Validation, Calculations       │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│         Data Access Layer (Repositories)        │
│  Database Queries, Data Mapping, CRUD Ops       │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│         Database Layer (SQL Server)             │
│  Tables, Stored Procedures, Relationships       │
└─────────────────────────────────────────────────┘
```

### Technology Stack
- **Framework**: ASP.NET Core 8.0 / 9.0
- **Language**: C# 12
- **ORM**: Dapper (Micro-ORM)
- **Database**: SQL Server
- **API Style**: RESTful Web API
- **Dependency Injection**: Built-in ASP.NET Core DI
- **Documentation**: Swagger/OpenAPI

### Design Patterns Used
1. **Repository Pattern**: Abstracts data access logic
2. **Service Pattern**: Encapsulates business logic
3. **Dependency Injection**: Loose coupling between components
4. **DTO Pattern**: Data Transfer Objects for API communication
5. **Factory Pattern**: Object creation through interfaces


## 2. Project Structure

```
Backend/InventoryManagement/
├── Program.cs                          # Application entry point & configuration
├── appsettings.json                    # Configuration settings
├── appsettings.Development.json        # Development-specific settings
├── InventoryManagement.csproj          # Project file with dependencies
├── Controllers/                        # API Controllers (HTTP endpoints)
│   ├── MasterRegisterController.cs    # Master list endpoints
│   ├── MmdsController.cs              # Measuring & Monitoring Devices
│   ├── ToolsController.cs             # Tools management
│   ├── AssetsConsumablesController.cs # Assets & Consumables
│   ├── MaintenanceController.cs       # Maintenance records
│   ├── AllocationController.cs        # Allocation records
│   ├── ItemDetailsController.cs       # Item details (V1)
│   ├── ItemDetailsV2Controller.cs     # Item details (V2 - improved)
│   ├── NextServiceController.cs       # Next service calculations
│   └── QualityController.cs           # Quality control templates
├── Services/                           # Business logic layer
│   ├── Interfaces/                    # Service interfaces
│   │   ├── IMasterRegisterService.cs
│   │   ├── IMmdsService.cs
│   │   ├── IToolService.cs
│   │   ├── IAssetsConsumablesService.cs
│   │   └── IQualityService.cs
│   ├── MasterRegisterService.cs
│   ├── MmdsService.cs
│   ├── ToolsService.cs
│   ├── AssetsConsumablesService.cs
│   └── QualityService.cs
├── Repositories/                       # Data access layer
│   ├── Interfaces/                    # Repository interfaces
│   │   ├── IMasterRegisterRepository.cs
│   │   ├── IMmdsRepository.cs
│   │   ├── IToolRepository.cs
│   │   ├── IAssetsConsumablesRepository.cs
│   │   └── IQualityRepository.cs
│   ├── MasterRegisterRepository.cs
│   ├── MmdsRepository.cs
│   ├── ToolRepository.cs
│   ├── AssetsConsumablesRepository.cs
│   └── QualityRepository.cs
├── Models/                             # Data models & DTOs
│   ├── Entities/                      # Database entities
│   │   ├── MasterRegister.cs
│   │   ├── MmdsEntity.cs
│   │   ├── ToolEntity.cs
│   │   ├── AssetsConsumablesEntity.cs
│   │   ├── MaintenanceEntity.cs
│   │   └── AllocationEntity.cs
│   ├── DTOs/                          # Data Transfer Objects
│   │   ├── MasterListDto.cs
│   │   ├── EnhancedMasterListDto.cs
│   │   ├── MmdsDto.cs
│   │   ├── ToolDto.cs
│   │   ├── PaginationDto.cs
│   │   └── AssetFullDetailDto.cs
│   ├── QCTemplateDto.cs
│   ├── QCControlPointDto.cs
│   ├── FinalProductDto.cs
│   ├── MaterialDto.cs
│   ├── UnitDto.cs
│   ├── ValidationTypeDto.cs
│   └── ControlPointTypeDto.cs
├── Data/                               # Database context
│   └── DapperContext.cs               # Dapper connection factory
└── Properties/
    └── launchSettings.json            # Launch configuration
```


## 3. Core Configuration

### 3.1 Program.cs - Application Entry Point

**Purpose**: Configure services, middleware, and start the application.

**Why This Design?**
- **Minimal API approach**: Modern ASP.NET Core uses top-level statements
- **Dependency Injection**: All services registered in one place
- **CORS Configuration**: Allows Flutter web app to communicate with API
- **Swagger Integration**: Automatic API documentation

**Key Configuration**:

```csharp
var builder = WebApplication.CreateBuilder(args);

// 1. Add Controllers
builder.Services.AddControllers();

// 2. Register Dapper Context (Database Connection)
builder.Services.AddSingleton<DapperContext>();

// 3. Configure CORS for Flutter Web
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy
            .AllowAnyOrigin()   // Allows any origin (important for Flutter Web dev mode)
            .AllowAnyHeader()   // Allows any HTTP header
            .AllowAnyMethod();  // Allows GET, POST, PUT, DELETE, etc.
    });
});

// 4. Register Repositories (Data Access Layer)
builder.Services.AddScoped<IToolRepository, ToolRepository>();
builder.Services.AddScoped<IMmdsRepository, MmdsRepository>();
builder.Services.AddScoped<IAssetsConsumablesRepository, AssetsConsumablesRepository>();
builder.Services.AddScoped<IMasterRegisterRepository, MasterRegisterRepository>();
builder.Services.AddScoped<IQualityRepository, QualityRepository>();

// 5. Register Services (Business Logic Layer)
builder.Services.AddScoped<IToolService, ToolService>();
builder.Services.AddScoped<IMmdsService, MmdsService>();
builder.Services.AddScoped<IAssetsConsumablesService, AssetsConsumablesService>();
builder.Services.AddScoped<IMasterRegisterService, MasterRegisterService>();
builder.Services.AddScoped<IQualityService, QualityService>();

// 6. Add Swagger for API Documentation
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// 7. Configure Middleware Pipeline
app.UseSwagger();        // Enable Swagger JSON endpoint
app.UseSwaggerUI();      // Enable Swagger UI
app.UseCors("AllowAll"); // MUST come before Authorization
app.UseAuthorization();  // Enable authorization middleware
app.MapControllers();    // Map controller routes

app.Run();               // Start the application
```

**Why Scoped Lifetime?**
- **Scoped**: One instance per HTTP request (repositories and services)
- **Singleton**: One instance for entire application lifetime (DapperContext)
- **Transient**: New instance every time (not used here)

**CORS Explanation**:
- **AllowAnyOrigin()**: Flutter Web runs on random ports during development
- **AllowAnyHeader()**: Allows custom headers like Authorization, Content-Type
- **AllowAnyMethod()**: Allows all HTTP verbs (GET, POST, PUT, DELETE, PATCH)

### 3.2 appsettings.json - Configuration Settings

**Purpose**: Store application configuration like connection strings and logging levels.

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=RISHIVASAN-PC;Database=ManufacturingApp;Trusted_Connection=False;TrustServerCertificate=True;User Id=sa;Password=Welcome@123;"
  },
  "applicationUrl": "http://localhost:5069;https://localhost:44370"
}
```

**Connection String Breakdown**:
- **Server**: SQL Server instance name
- **Database**: Database name
- **Trusted_Connection=False**: Use SQL Server authentication (not Windows auth)
- **TrustServerCertificate=True**: Trust self-signed certificates
- **User Id & Password**: SQL Server credentials

**Why This Configuration?**
- **Centralized Settings**: All configuration in one place
- **Environment-Specific**: Can override with appsettings.Development.json
- **Secure**: Passwords should be in environment variables in production

### 3.3 DapperContext.cs - Database Connection Factory

**Purpose**: Create database connections for Dapper queries.

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

    public IDbConnection CreateConnection()
        => new SqlConnection(_connectionString);
}
```

**Why This Design?**
- **Factory Pattern**: Centralized connection creation
- **Dependency Injection**: Injected into repositories
- **Connection Pooling**: SQL Server automatically pools connections
- **Dispose Pattern**: Connections disposed after use with `using` statement

**How to Use**:
```csharp
using var connection = _context.CreateConnection();
var data = await connection.QueryAsync<Entity>("SELECT * FROM Table");
```


## 4. Database Architecture

### 4.1 Database Tables Overview

The system uses SQL Server with the following main tables:

```
ManufacturingApp Database
├── MasterRegister              # Central inventory registry
├── MMDs                        # Measuring & Monitoring Devices
├── Tools                       # Tools inventory
├── AssetsConsumables           # Assets and Consumables
├── Maintenance                 # Maintenance/Service records
├── Allocation                  # Asset allocation records
├── QCTemplates                 # Quality Control templates
├── QCControlPoints             # QC control points
├── ControlPointTypes           # Types of control points
├── ValidationTypes             # Validation type lookup
├── FinalProducts               # Final products list
├── Materials                   # Materials/Components list
└── Units                       # Measurement units
```

### 4.2 Master Register Table

**Purpose**: Central registry of all inventory items across different types.

**Schema**:
```sql
CREATE TABLE MasterRegister (
    ItemID VARCHAR(50) PRIMARY KEY,
    ItemType VARCHAR(20) NOT NULL,  -- 'MMD', 'Tool', 'Asset', 'Consumable'
    RefId VARCHAR(50),
    Type VARCHAR(100),
    ItemName VARCHAR(200) NOT NULL,
    Supplier VARCHAR(200),
    Location VARCHAR(200),
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ResponsibleTeam VARCHAR(200),
    NextServiceDue DATETIME NULL,
    AvailabilityStatus VARCHAR(50) DEFAULT 'Available',
    Status BIT DEFAULT 1
)
```

**Key Fields**:
- **ItemID**: Unique identifier (e.g., MMD001, TOOL001)
- **ItemType**: Discriminator for item category
- **NextServiceDue**: Calculated based on maintenance frequency
- **AvailabilityStatus**: 'Available', 'In Use', 'Under Maintenance', etc.
- **Status**: Active (1) or Inactive (0)

**Why This Design?**
- **Single Source of Truth**: All items in one table
- **Type Discrimination**: ItemType field determines specific table
- **Denormalization**: NextServiceDue stored here for quick access
- **Soft Delete**: Status field instead of hard deletes

### 4.3 MMDs Table (Measuring & Monitoring Devices)

**Purpose**: Store detailed information about calibration equipment.

**Schema**:
```sql
CREATE TABLE MMDs (
    MmdId VARCHAR(50) PRIMARY KEY,
    MmdName VARCHAR(200) NOT NULL,
    BrandName VARCHAR(200),
    AccuracyClass VARCHAR(50),
    Supplier VARCHAR(200),
    CalibratedBy VARCHAR(200),
    Specifications TEXT,
    ModelNumber VARCHAR(100),
    SerialNumber VARCHAR(100),
    Quantity INT DEFAULT 1,
    CertificateNumber VARCHAR(100),
    Location VARCHAR(200),
    PoNumber VARCHAR(100),
    PoDate DATETIME,
    InvoiceNumber VARCHAR(100),
    InvoiceDate DATETIME,
    Cost DECIMAL(18,2),
    ExtraCharges DECIMAL(18,2),
    TotalCost AS (Cost + ExtraCharges) PERSISTED,
    CalibrationFrequency VARCHAR(50),  -- 'Monthly', 'Quarterly', 'Yearly'
    LastCalibrationDate DATETIME,
    NextCalibrationDate DATETIME,
    WarrantyPeriod VARCHAR(100),
    CalibrationStatus VARCHAR(50),
    ResponsiblePerson VARCHAR(200),
    OperatingManual VARCHAR(500),
    StockMsiAsset VARCHAR(100),
    AdditionalNotes TEXT,
    Status BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
)
```

**Key Features**:
- **Computed Column**: TotalCost automatically calculated
- **Calibration Tracking**: Frequency, last date, next date
- **Purchase Information**: PO, Invoice, Cost tracking
- **Technical Details**: Model, Serial, Specifications

### 4.4 Tools Table

**Purpose**: Manage tools inventory with maintenance tracking.

**Schema**:
```sql
CREATE TABLE Tools (
    ToolsId VARCHAR(50) PRIMARY KEY,
    ToolName VARCHAR(200) NOT NULL,
    ToolType VARCHAR(100),
    ArticleCode VARCHAR(100),
    AssociatedProduct VARCHAR(200),
    Vendor VARCHAR(200),
    StorageLocation VARCHAR(200),
    Specifications TEXT,
    PoNumber VARCHAR(100),
    PoDate DATETIME,
    InvoiceNumber VARCHAR(100),
    InvoiceDate DATETIME,
    ToolCost DECIMAL(18,2),
    ExtraCharges DECIMAL(18,2),
    TotalCost AS (ToolCost + ExtraCharges) PERSISTED,
    Lifespan VARCHAR(100),
    AuditInterval VARCHAR(50),
    MaintenanceFrequency VARCHAR(50),  -- 'Daily', 'Weekly', 'Monthly', etc.
    HandlingCertificate VARCHAR(500),
    LastAuditDate DATETIME,
    LastAuditNotes TEXT,
    MaxOutput VARCHAR(100),
    Status BIT DEFAULT 1,
    ResponsibleTeam VARCHAR(200),
    MsiAsset VARCHAR(100),
    KernAsset VARCHAR(100),
    Notes TEXT,
    CreatedDate DATETIME DEFAULT GETDATE()
)
```

**Key Features**:
- **Maintenance Tracking**: Frequency, last audit, lifespan
- **Asset Tracking**: MSI Asset, Kern Asset identifiers
- **Audit Trail**: Last audit date and notes

### 4.5 AssetsConsumables Table

**Purpose**: Track assets and consumable items with stock levels.

**Schema**:
```sql
CREATE TABLE AssetsConsumables (
    AssetId VARCHAR(50) PRIMARY KEY,
    AssetName VARCHAR(200) NOT NULL,
    AssetType VARCHAR(20) NOT NULL,  -- 'Asset' or 'Consumable'
    Category VARCHAR(100),
    Vendor VARCHAR(200),
    StorageLocation VARCHAR(200),
    Specifications TEXT,
    PoNumber VARCHAR(100),
    PoDate DATETIME,
    InvoiceNumber VARCHAR(100),
    InvoiceDate DATETIME,
    AssetCost DECIMAL(18,2),
    ExtraCharges DECIMAL(18,2),
    TotalCost AS (AssetCost + ExtraCharges) PERSISTED,
    CurrentStock INT DEFAULT 0,
    MinimumStock INT DEFAULT 0,
    MaximumStock INT DEFAULT 0,
    ReorderLevel INT DEFAULT 0,
    Status BIT DEFAULT 1,
    ResponsibleTeam VARCHAR(200),
    MsiAsset VARCHAR(100),
    KernAsset VARCHAR(100),
    Notes TEXT,
    CreatedDate DATETIME DEFAULT GETDATE()
)
```

**Key Features**:
- **Stock Management**: Current, Min, Max, Reorder levels
- **Type Discrimination**: Asset vs Consumable
- **Inventory Control**: Automatic reorder alerts

### 4.6 Maintenance Table

**Purpose**: Record all maintenance and service activities.

**Schema**:
```sql
CREATE TABLE Maintenance (
    MaintenanceId INT PRIMARY KEY IDENTITY(1,1),
    AssetType VARCHAR(20) NOT NULL,
    AssetId VARCHAR(50) NOT NULL,
    ItemName VARCHAR(200),
    ServiceDate DATETIME,
    ServiceProviderCompany VARCHAR(200),
    ServiceEngineerName VARCHAR(200),
    ServiceType VARCHAR(100),  -- 'Preventive', 'Corrective', 'Calibration'
    NextServiceDue DATETIME,
    ServiceNotes TEXT,
    MaintenanceStatus VARCHAR(50),  -- 'Scheduled', 'Completed', 'Pending'
    Cost DECIMAL(18,2) DEFAULT 0,
    ResponsibleTeam VARCHAR(200),
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (AssetId) REFERENCES MasterRegister(ItemID)
)
```

**Key Features**:
- **Service Tracking**: Date, provider, engineer, type
- **Next Service Calculation**: Automatically updates MasterRegister
- **Cost Tracking**: Maintenance cost per service
- **History**: Complete service history per asset

**Critical Flow**:
```
1. Maintenance record created
   ↓
2. NextServiceDue calculated (ServiceDate + Frequency)
   ↓
3. MasterRegister.NextServiceDue updated
   ↓
4. Frontend displays updated date immediately
```

### 4.7 Allocation Table

**Purpose**: Track asset allocation to employees/teams.

**Schema**:
```sql
CREATE TABLE Allocation (
    AllocationId INT PRIMARY KEY IDENTITY(1,1),
    AssetType VARCHAR(20) NOT NULL,
    AssetId VARCHAR(50) NOT NULL,
    ItemName VARCHAR(200),
    EmployeeId VARCHAR(50),
    EmployeeName VARCHAR(200),
    TeamName VARCHAR(200),
    Purpose TEXT,
    IssuedDate DATETIME,
    ExpectedReturnDate DATETIME,
    ActualReturnDate DATETIME NULL,
    AvailabilityStatus VARCHAR(50),  -- 'Allocated', 'Returned', 'Overdue'
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (AssetId) REFERENCES MasterRegister(ItemID)
)
```

**Key Features**:
- **Allocation Tracking**: Who, when, why
- **Return Management**: Expected vs actual return dates
- **Status Updates**: Automatically updates MasterRegister.AvailabilityStatus
- **Overdue Detection**: ExpectedReturnDate < GETDATE() AND ActualReturnDate IS NULL

### 4.8 Quality Control Tables

**QCTemplates Table**:
```sql
CREATE TABLE QCTemplates (
    TemplateId INT PRIMARY KEY IDENTITY(1,1),
    TemplateName VARCHAR(500) NOT NULL,
    ValidationTypeId INT,
    FinalProductId INT,
    MaterialId INT,
    Tools TEXT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    Status BIT DEFAULT 1,
    FOREIGN KEY (ValidationTypeId) REFERENCES ValidationTypes(ValidationTypeId),
    FOREIGN KEY (FinalProductId) REFERENCES FinalProducts(FinalProductId),
    FOREIGN KEY (MaterialId) REFERENCES Materials(MaterialId),
    CONSTRAINT UQ_Material_Template UNIQUE (MaterialId)  -- One template per material
)
```

**QCControlPoints Table**:
```sql
CREATE TABLE QCControlPoints (
    ControlPointId INT PRIMARY KEY IDENTITY(1,1),
    TemplateId INT NOT NULL,
    ControlPointTypeId INT NOT NULL,
    ControlPointName VARCHAR(200) NOT NULL,
    TargetValue VARCHAR(100),
    UnitId INT,
    TolerancePlus VARCHAR(50),
    ToleranceMinus VARCHAR(50),
    SequenceNumber INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (TemplateId) REFERENCES QCTemplates(TemplateId) ON DELETE CASCADE,
    FOREIGN KEY (ControlPointTypeId) REFERENCES ControlPointTypes(ControlPointTypeId),
    FOREIGN KEY (UnitId) REFERENCES Units(UnitId)
)
```

**Key Features**:
- **Template-Based**: Reusable QC templates
- **Unique Material Constraint**: One template per material
- **Control Points**: Multiple checkpoints per template
- **Cascade Delete**: Deleting template removes all control points
- **Sequence Numbering**: Order of control points


## 5. Controllers Documentation

### 5.1 MasterRegisterController.cs

**Purpose**: Provide API endpoints for the master inventory list with pagination, search, and sorting.

**Base Route**: `/api`

**Key Endpoints**:

#### GET /api/master-list
**Purpose**: Get all inventory items (legacy endpoint).

```csharp
[HttpGet("master-list")]
public async Task<IActionResult> GetMasterList()
{
    var data = await _service.GetMasterListAsync();
    return Ok(data);
}
```

**Returns**: List of all inventory items
**Use Case**: Initial data load, export functionality

#### GET /api/enhanced-master-list
**Purpose**: Get enhanced master list with calculated fields.

```csharp
[HttpGet("enhanced-master-list")]
public async Task<IActionResult> GetEnhancedMasterList()
{
    // Add cache-busting headers
    Response.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate");
    Response.Headers.Add("Pragma", "no-cache");
    Response.Headers.Add("Expires", "0");
    
    var data = await _service.GetEnhancedMasterListAsync();
    return Ok(data);
}
```

**Why Cache-Busting Headers?**
- **no-cache**: Forces revalidation with server
- **no-store**: Prevents caching entirely
- **must-revalidate**: Requires fresh data
- **Pragma: no-cache**: HTTP/1.0 compatibility
- **Expires: 0**: Immediate expiration

**Returns**: Enhanced list with:
- NextServiceDue calculated from maintenance frequency
- AvailabilityStatus from latest allocation
- All master register fields

#### GET /api/enhanced-master-list/paginated
**Purpose**: Get paginated, searchable, sortable master list (PRIMARY ENDPOINT).

```csharp
[HttpGet("enhanced-master-list/paginated")]
public async Task<IActionResult> GetEnhancedMasterListPaginated(
    [FromQuery] int pageNumber = 1,
    [FromQuery] int pageSize = 10,
    [FromQuery] string? searchText = null,
    [FromQuery] string? sortColumn = null,
    [FromQuery] string? sortDirection = null)
{
    // Validation
    if (pageNumber < 1) pageNumber = 1;
    if (pageSize < 1) pageSize = 10;
    if (pageSize > 100) pageSize = 100; // Max limit

    var data = await _service.GetEnhancedMasterListPaginatedAsync(
        pageNumber, pageSize, searchText, sortColumn, sortDirection);
    return Ok(data);
}
```

**Query Parameters**:
- **pageNumber**: Current page (default: 1)
- **pageSize**: Items per page (default: 10, max: 100)
- **searchText**: Search across all columns
- **sortColumn**: Column name to sort by
- **sortDirection**: 'asc' or 'desc'

**Response Format**:
```json
{
  "totalCount": 150,
  "pageNumber": 1,
  "pageSize": 10,
  "totalPages": 15,
  "items": [
    {
      "sno": 1,
      "itemType": "MMD",
      "refId": "REF001",
      "itemID": "MMD001",
      "type": "Caliper",
      "itemName": "Vernier Caliper",
      "supplier": "ABC Corp",
      "location": "Warehouse A",
      "createdDate": "2024-01-15T10:30:00",
      "responsibleTeam": "Production",
      "nextServiceDue": "2024-12-15T00:00:00",
      "availabilityStatus": "Available"
    }
  ]
}
```

**Why This Design?**
- **Server-Side Pagination**: Reduces data transfer
- **Server-Side Search**: Faster than client-side filtering
- **Server-Side Sorting**: Database-optimized sorting
- **Validation**: Prevents invalid page sizes
- **Max Limit**: Protects against memory issues

#### GET /api/debug-next-service
**Purpose**: Debug endpoint to verify next service date calculations.

```csharp
[HttpGet("debug-next-service")]
public async Task<IActionResult> DebugNextService()
{
    var data = await _service.GetEnhancedMasterListAsync();
    
    var debugInfo = data.Take(5).Select(item => new
    {
        ItemID = item.ItemID,
        ItemName = item.ItemName,
        CreatedDate = item.CreatedDate,
        NextServiceDue = item.NextServiceDue,
        DaysDifference = item.NextServiceDue.HasValue ? 
            (item.NextServiceDue.Value - item.CreatedDate).Days : (int?)null,
        IsCalculated = item.NextServiceDue.HasValue && 
            item.NextServiceDue != item.CreatedDate
    }).ToList();

    return Ok(new { 
        TotalItems = data.Count,
        DebugSample = debugInfo,
        Message = "Debug information for next service date calculation"
    });
}
```

**Use Case**: Troubleshooting next service date issues

### 5.2 MmdsController.cs

**Purpose**: CRUD operations for Measuring & Monitoring Devices.

**Base Route**: `/api`

#### GET /api/mmds
**Purpose**: Get all MMDs.

```csharp
[HttpGet("api/mmds")]
public async Task<IActionResult> GetMmds()
{
    return Ok(await _service.GetMmdsAsync());
}
```

**Returns**: List of all MMD records with complete details

#### POST /api/addmmds
**Purpose**: Create new MMD record.

```csharp
[HttpPost("api/addmmds")]
public async Task<IActionResult> CreateMmds([FromBody] MmdsEntity mmds)
{
    try
    {
        var success = await _service.CreateMmdsAsync(mmds);
        if (!success) return BadRequest("Insert failed");

        return Ok("MMDS created successfully");
    }
    catch (Exception ex)
    {
        return BadRequest($"Error creating MMD: {ex.Message}");
    }
}
```

**Request Body Example**:
```json
{
  "mmdId": "MMD001",
  "mmdName": "Vernier Caliper",
  "brandName": "Mitutoyo",
  "accuracyClass": "0.02mm",
  "supplier": "ABC Instruments",
  "calibratedBy": "XYZ Lab",
  "specifications": "Range: 0-150mm",
  "modelNumber": "VC-150",
  "serialNumber": "SN123456",
  "quantity": 5,
  "certificateNumber": "CERT-2024-001",
  "location": "Warehouse A",
  "poNumber": "PO-2024-001",
  "poDate": "2024-01-15",
  "invoiceNumber": "INV-001",
  "invoiceDate": "2024-01-20",
  "cost": 5000.00,
  "extraCharges": 500.00,
  "calibrationFrequency": "Yearly",
  "lastCalibrationDate": "2024-01-25",
  "nextCalibrationDate": "2025-01-25",
  "warrantyPeriod": "2 years",
  "calibrationStatus": "Calibrated",
  "responsiblePerson": "John Doe",
  "operatingManual": "Manual_VC150.pdf",
  "stockMsiAsset": "MSI-001",
  "additionalNotes": "Handle with care",
  "status": true
}
```

**Validation**:
- MmdId must be unique
- MmdName is required
- Cost and ExtraCharges must be non-negative
- TotalCost is auto-calculated

#### PUT /api/updatemmds
**Purpose**: Update existing MMD record.

```csharp
[HttpPut("api/updatemmds")]
public async Task<IActionResult> UpdateMmds([FromBody] MmdsEntity mmds)
{
    var success = await _service.UpdateMmdsAsync(mmds);
    if (!success) return BadRequest("Update failed");

    return Ok("MMDS updated successfully");
}
```

**Request Body**: Same as POST, must include MmdId

#### DELETE /api/Mmds/{id}
**Purpose**: Delete MMD record (soft delete).

```csharp
[HttpDelete("api/Mmds/{id}")]
public async Task<IActionResult> DeleteMmds(string id)
{
    var success = await _service.DeleteMmdsAsync(id);
    if (!success) return NotFound("MMD not found or delete failed");

    return Ok("MMD deleted successfully");
}
```

**Note**: This is typically a soft delete (sets Status = 0)

### 5.3 ToolsController.cs

**Purpose**: CRUD operations for Tools.

**Base Route**: `/api`

#### GET /api/tools
```csharp
[HttpGet("api/tools")]
public async Task<IActionResult> GetTools()
{
    return Ok(await _service.GetToolsAsync());
}
```

#### POST /api/addtools
```csharp
[HttpPost("api/addtools")]
public async Task<IActionResult> CreateTool([FromBody] ToolEntity tool)
{
    var success = await _service.CreateToolAsync(tool);
    if (!success) return BadRequest("Insert failed");

    return Ok("Tool created successfully");
}
```

**Request Body Example**:
```json
{
  "toolsId": "TOOL001",
  "toolName": "Drill Machine",
  "toolType": "Power Tool",
  "articleCode": "ART-001",
  "associatedProduct": "Product A",
  "vendor": "Tool Supplier Inc",
  "storageLocation": "Workshop",
  "specifications": "1500W, 13mm chuck",
  "poNumber": "PO-2024-002",
  "poDate": "2024-02-01",
  "invoiceNumber": "INV-002",
  "invoiceDate": "2024-02-05",
  "toolCost": 15000.00,
  "extraCharges": 1000.00,
  "lifespan": "5 years",
  "auditInterval": "6 months",
  "maintenanceFrequency": "Quarterly",
  "handlingCertificate": "CERT-TOOL-001",
  "lastAuditDate": "2024-02-10",
  "lastAuditNotes": "All checks passed",
  "maxOutput": "3000 RPM",
  "status": true,
  "responsibleTeam": "Maintenance",
  "msiAsset": "MSI-TOOL-001",
  "kernAsset": "KERN-001",
  "notes": "Regular maintenance required"
}
```

#### DELETE /api/Tools/{id}
```csharp
[HttpDelete("api/Tools/{id}")]
public async Task<IActionResult> DeleteTool(string id)
{
    var success = await _service.DeleteToolAsync(id);
    if (!success) return NotFound("Tool not found or delete failed");

    return Ok("Tool deleted successfully");
}
```

### 5.4 AssetsConsumablesController.cs

**Purpose**: CRUD operations for Assets and Consumables.

**Base Route**: `/api`

#### GET /api/assets-consumables
```csharp
[HttpGet("api/assets-consumables")]
public async Task<IActionResult> Get()
{
    return Ok(await _service.GetAsync());
}
```

#### POST /api/add-assets-consumables
```csharp
[HttpPost("api/add-assets-consumables")]
public async Task<IActionResult> Create([FromBody] AssetsConsumablesEntity asset)
{
    var success = await _service.CreateAsync(asset);
    if (!success) return BadRequest("Insert failed");

    return Ok("Asset / Consumable created successfully");
}
```

**Request Body Example**:
```json
{
  "assetId": "ASSET001",
  "assetName": "Safety Gloves",
  "assetType": "Consumable",
  "category": "PPE",
  "vendor": "Safety Supplies Co",
  "storageLocation": "Store Room A",
  "specifications": "Size: L, Material: Nitrile",
  "poNumber": "PO-2024-003",
  "poDate": "2024-03-01",
  "invoiceNumber": "INV-003",
  "invoiceDate": "2024-03-05",
  "assetCost": 50.00,
  "extraCharges": 5.00,
  "currentStock": 100,
  "minimumStock": 20,
  "maximumStock": 200,
  "reorderLevel": 30,
  "status": true,
  "responsibleTeam": "Safety",
  "msiAsset": "MSI-ASSET-001",
  "kernAsset": "KERN-ASSET-001",
  "notes": "Reorder when stock reaches 30"
}
```

#### GET /api/asset-full-details
**Purpose**: Get complete asset details including master data.

```csharp
[HttpGet("api/asset-full-details")]
public async Task<IActionResult> GetAssetFullDetails(
    [FromQuery] string assetId,
    [FromQuery] string assetType)
{
    var result = await _service.GetAssetFullDetailsAsync(assetId, assetType);

    if (result?.MasterDetails == null)
        return NotFound("Asset not found");

    return Ok(result);
}
```

**Query Parameters**:
- assetId: Asset identifier
- assetType: 'asset' or 'consumable'

**Response Format**:
```json
{
  "masterDetails": {
    "itemID": "ASSET001",
    "itemType": "Asset",
    "itemName": "Safety Gloves",
    "nextServiceDue": null,
    "availabilityStatus": "Available"
  },
  "detailedData": {
    "assetId": "ASSET001",
    "assetName": "Safety Gloves",
    "currentStock": 100,
    "minimumStock": 20
  }
}
```

#### PUT /api/update-assets-consumables
```csharp
[HttpPut("api/update-assets-consumables")]
public async Task<IActionResult> Update([FromBody] AssetsConsumablesEntity asset)
{
    var success = await _service.UpdateAsync(asset);
    if (!success) return BadRequest("Update failed");

    return Ok("Asset / Consumable updated successfully");
}
```

#### DELETE /api/AssetsConsumables/{id}
```csharp
[HttpDelete("api/AssetsConsumables/{id}")]
public async Task<IActionResult> Delete(string id)
{
    var success = await _service.DeleteAsync(id);
    if (!success) return NotFound("Asset/Consumable not found or delete failed");

    return Ok("Asset / Consumable deleted successfully");
}
```


### 5.5 MaintenanceController.cs

**Purpose**: Manage maintenance/service records with automatic Next Service Due updates.

**Base Route**: `/api/maintenance`

**Key Features**:
- Server-side pagination with search and sort
- Automatic Next Service Due calculation
- Updates MasterRegister table immediately
- Comprehensive logging for debugging
- Dynamic table discovery (handles different database schemas)

#### GET /api/maintenance
**Purpose**: Get all maintenance records.

```csharp
[HttpGet]
public async Task<ActionResult<IEnumerable<MaintenanceEntity>>> GetAllMaintenance()
{
    using var connection = _context.CreateConnection();
    var sql = "SELECT * FROM Maintenance ORDER BY ServiceDate DESC";
    var maintenance = await connection.QueryAsync<MaintenanceEntity>(sql);
    return Ok(maintenance);
}
```

**Returns**: List of all maintenance records ordered by service date

#### GET /api/maintenance/paginated/{assetId}
**Purpose**: Get paginated maintenance records for a specific asset with search and sort.

```csharp
[HttpGet("paginated/{assetId}")]
public async Task<ActionResult> GetMaintenancePaginated(
    string assetId,
    [FromQuery] int pageNumber = 1,
    [FromQuery] int pageSize = 5,
    [FromQuery] string? searchText = null,
    [FromQuery] string? sortColumn = null,
    [FromQuery] string? sortDirection = null)
```

**Query Parameters**:
- **assetId**: Asset identifier (route parameter)
- **pageNumber**: Current page (default: 1)
- **pageSize**: Items per page (default: 5)
- **searchText**: Search across all maintenance fields
- **sortColumn**: Column to sort by (serviceDate, serviceProviderCompany, etc.)
- **sortDirection**: 'asc' or 'desc'

**SQL Query Pattern**:
```sql
WITH MaintenanceData AS (
    SELECT * FROM Maintenance
    WHERE AssetId = @AssetId
    AND (@SearchText IS NULL OR 
         ServiceProviderCompany LIKE '%' + @SearchText + '%' OR
         ServiceEngineerName LIKE '%' + @SearchText + '%' OR
         ServiceType LIKE '%' + @SearchText + '%' OR
         -- ... other searchable fields
    )
)
SELECT *, COUNT(*) OVER() AS TotalCount
FROM MaintenanceData
ORDER BY ServiceDate DESC
OFFSET @Offset ROWS
FETCH NEXT @PageSize ROWS ONLY;
```

**Response Format**:
```json
{
  "totalCount": 25,
  "pageNumber": 1,
  "pageSize": 5,
  "totalPages": 5,
  "items": [
    {
      "maintenanceId": 1,
      "assetType": "MMD",
      "assetId": "MMD001",
      "itemName": "Vernier Caliper",
      "serviceDate": "2024-04-06T00:00:00",
      "serviceProviderCompany": "ABC Calibration Lab",
      "serviceEngineerName": "Ravi Kumar",
      "serviceType": "Calibration",
      "nextServiceDue": "2024-12-01T00:00:00",
      "serviceNotes": "Calibration completed successfully",
      "maintenanceStatus": "Completed",
      "cost": 5000.00,
      "responsibleTeam": "Production Team",
      "createdDate": "2024-04-06T10:30:00"
    }
  ]
}
```

#### GET /api/maintenance/{assetId}
**Purpose**: Get all maintenance records for a specific asset (non-paginated).

```csharp
[HttpGet("{assetId}")]
public async Task<ActionResult<IEnumerable<MaintenanceEntity>>> GetMaintenanceByAssetId(string assetId)
{
    using var connection = _context.CreateConnection();
    var sql = "SELECT * FROM Maintenance WHERE AssetId = @AssetId ORDER BY ServiceDate DESC";
    var maintenance = await connection.QueryAsync<MaintenanceEntity>(sql, new { AssetId = assetId });
    return Ok(maintenance);
}
```

**Returns**: List of maintenance records for the specified asset

#### POST /api/maintenance
**Purpose**: Create new maintenance record and update Next Service Due.

```csharp
[HttpPost]
public async Task<ActionResult<MaintenanceEntity>> CreateMaintenance(MaintenanceEntity maintenance)
{
    using var connection = _context.CreateConnection();
    
    // 1. Insert maintenance record
    var sql = @"INSERT INTO Maintenance (AssetType, AssetId, ItemName, ServiceDate, 
                ServiceProviderCompany, ServiceEngineerName, ServiceType, NextServiceDue, 
                ServiceNotes, MaintenanceStatus, Cost, ResponsibleTeam, CreatedDate)
                VALUES (@AssetType, @AssetId, @ItemName, @ServiceDate, 
                @ServiceProviderCompany, @ServiceEngineerName, @ServiceType, @NextServiceDue, 
                @ServiceNotes, @MaintenanceStatus, @Cost, @ResponsibleTeam, @CreatedDate);
                SELECT CAST(SCOPE_IDENTITY() as int)";
    
    var id = await connection.QuerySingleAsync<int>(sql, maintenance);
    maintenance.MaintenanceId = id;
    
    // 2. Update Next Service Due in MasterRegister
    if (maintenance.NextServiceDue != null)
    {
        await UpdateMasterItemNextServiceDue(connection, maintenance.AssetId, 
            maintenance.AssetType, maintenance.NextServiceDue.Value);
    }
    
    return CreatedAtAction(nameof(GetMaintenanceByAssetId), 
        new { assetId = maintenance.AssetId }, maintenance);
}
```

**Request Body Example**:
```json
{
  "assetType": "MMD",
  "assetId": "MMD001",
  "itemName": "Vernier Caliper",
  "serviceDate": "2024-04-06",
  "serviceProviderCompany": "ABC Calibration Lab",
  "serviceEngineerName": "Ravi Kumar",
  "serviceType": "Calibration",
  "nextServiceDue": "2024-12-01",
  "serviceNotes": "Calibration completed successfully",
  "maintenanceStatus": "Completed",
  "cost": 5000.00,
  "responsibleTeam": "Production Team"
}
```

**Critical Flow**:
```
1. Maintenance record created in Maintenance table
   ↓
2. NextServiceDue calculated (ServiceDate + Frequency)
   ↓
3. UpdateMasterItemNextServiceDue() called
   ↓
4. MasterRegister.NextServiceDue updated
   ↓
5. Frontend displays updated date immediately
```

**Helper Method - UpdateMasterItemNextServiceDue**:
```csharp
private async Task UpdateMasterItemNextServiceDue(
    IDbConnection connection, 
    string assetId, 
    string assetType, 
    DateTime nextServiceDue)
{
    string updateSql = "";
    
    switch (assetType?.ToLower())
    {
        case "tool":
            updateSql = "UPDATE ToolsMaster SET NextServiceDue = @NextServiceDue WHERE ToolsId = @AssetId";
            break;
        case "asset":
        case "consumable":
            updateSql = "UPDATE AssetsConsumablesMaster SET NextServiceDue = @NextServiceDue WHERE AssetId = @AssetId";
            break;
        case "mmd":
            updateSql = "UPDATE MmdsMaster SET NextCalibration = @NextServiceDue WHERE MmdId = @AssetId";
            break;
    }
    
    await connection.ExecuteAsync(updateSql, new { AssetId = assetId, NextServiceDue = nextServiceDue });
}
```

**Why This Design?**
- **Immediate Update**: MasterRegister updated in same transaction
- **Type-Specific**: Different tables for different asset types
- **Logging**: Comprehensive console logging for debugging
- **Error Handling**: Doesn't fail if master update fails

#### PUT /api/maintenance/{id}
**Purpose**: Update existing maintenance record.

```csharp
[HttpPut("{id}")]
public async Task<IActionResult> UpdateMaintenance(int id, MaintenanceEntity maintenance)
{
    if (id != maintenance.MaintenanceId)
        return BadRequest("ID mismatch");
    
    using var connection = _context.CreateConnection();
    
    var sql = @"UPDATE Maintenance 
                SET AssetType = @AssetType, ServiceDate = @ServiceDate, 
                    NextServiceDue = @NextServiceDue, Cost = @Cost, ...
                WHERE MaintenanceId = @MaintenanceId";
    
    var affectedRows = await connection.ExecuteAsync(sql, maintenance);
    
    if (affectedRows > 0 && maintenance.NextServiceDue != null)
    {
        await UpdateMasterItemNextServiceDue(connection, maintenance.AssetId, 
            maintenance.AssetType, maintenance.NextServiceDue.Value);
    }
    
    return NoContent();
}
```

#### DELETE /api/maintenance/{id}
**Purpose**: Delete maintenance record.

```csharp
[HttpDelete("{id}")]
public async Task<IActionResult> DeleteMaintenance(int id)
{
    using var connection = _context.CreateConnection();
    var sql = "DELETE FROM Maintenance WHERE MaintenanceId = @Id";
    var affectedRows = await connection.ExecuteAsync(sql, new { Id = id });
    
    if (affectedRows == 0)
        return NotFound();
    
    return NoContent();
}
```

**Note**: Consider soft delete instead of hard delete for audit trail

### 5.6 AllocationController.cs

**Purpose**: Manage asset allocation to employees/teams with availability status tracking.

**Base Route**: `/api/allocation`

**Key Features**:
- Server-side pagination with search and sort
- Automatic availability status updates
- Dynamic table discovery
- Comprehensive logging

#### GET /api/allocation
**Purpose**: Get all allocation records.

```csharp
[HttpGet]
public async Task<ActionResult<IEnumerable<AllocationEntity>>> GetAllAllocations()
{
    using var connection = _context.CreateConnection();
    var sql = "SELECT * FROM Allocation ORDER BY CreatedDate DESC";
    var allocations = await connection.QueryAsync<AllocationEntity>(sql);
    return Ok(allocations);
}
```

#### GET /api/allocation/paginated/{assetId}
**Purpose**: Get paginated allocation records for a specific asset.

```csharp
[HttpGet("paginated/{assetId}")]
public async Task<ActionResult> GetAllocationsPaginated(
    string assetId,
    [FromQuery] int pageNumber = 1,
    [FromQuery] int pageSize = 5,
    [FromQuery] string? searchText = null,
    [FromQuery] string? sortColumn = null,
    [FromQuery] string? sortDirection = null)
```

**SQL Query Pattern**:
```sql
WITH AllocationData AS (
    SELECT * FROM Allocation
    WHERE AssetId = @AssetId
    AND (@SearchText IS NULL OR 
         EmployeeName LIKE '%' + @SearchText + '%' OR
         TeamName LIKE '%' + @SearchText + '%' OR
         Purpose LIKE '%' + @SearchText + '%' OR
         -- ... other searchable fields
    )
)
SELECT *, COUNT(*) OVER() AS TotalCount
FROM AllocationData
ORDER BY IssuedDate DESC
OFFSET @Offset ROWS
FETCH NEXT @PageSize ROWS ONLY;
```

**Response Format**:
```json
{
  "totalCount": 15,
  "pageNumber": 1,
  "pageSize": 5,
  "totalPages": 3,
  "items": [
    {
      "allocationId": 1,
      "assetType": "Tool",
      "assetId": "TOOL001",
      "itemName": "Drill Machine",
      "employeeId": "EMP001",
      "employeeName": "John Doe",
      "teamName": "Production Team",
      "purpose": "Assembly work",
      "issuedDate": "2024-03-01T00:00:00",
      "expectedReturnDate": "2024-03-15T00:00:00",
      "actualReturnDate": null,
      "availabilityStatus": "Allocated",
      "createdDate": "2024-03-01T09:00:00"
    }
  ]
}
```

#### GET /api/allocation/{assetId}
**Purpose**: Get all allocation records for a specific asset.

```csharp
[HttpGet("{assetId}")]
public async Task<ActionResult<IEnumerable<AllocationEntity>>> GetAllocationsByAssetId(string assetId)
{
    using var connection = _context.CreateConnection();
    var sql = "SELECT * FROM Allocation WHERE AssetId = @AssetId ORDER BY IssuedDate DESC";
    var allocations = await connection.QueryAsync<AllocationEntity>(sql, new { AssetId = assetId });
    return Ok(allocations);
}
```

#### POST /api/allocation
**Purpose**: Create new allocation record and update availability status.

```csharp
[HttpPost]
public async Task<ActionResult<AllocationEntity>> CreateAllocation(AllocationEntity allocation)
{
    using var connection = _context.CreateConnection();
    
    allocation.CreatedDate = DateTime.Now;
    
    var sql = @"INSERT INTO Allocation (AssetType, AssetId, ItemName, EmployeeId, 
                EmployeeName, TeamName, Purpose, IssuedDate, ExpectedReturnDate, 
                ActualReturnDate, AvailabilityStatus, CreatedDate)
                VALUES (@AssetType, @AssetId, @ItemName, @EmployeeId, @EmployeeName, 
                @TeamName, @Purpose, @IssuedDate, @ExpectedReturnDate, 
                @ActualReturnDate, @AvailabilityStatus, @CreatedDate);
                SELECT CAST(SCOPE_IDENTITY() as int)";
    
    var id = await connection.QuerySingleAsync<int>(sql, allocation);
    allocation.AllocationId = id;
    
    return CreatedAtAction(nameof(GetAllocationsByAssetId), 
        new { assetId = allocation.AssetId }, allocation);
}
```

**Request Body Example**:
```json
{
  "assetType": "Tool",
  "assetId": "TOOL001",
  "itemName": "Drill Machine",
  "employeeId": "EMP001",
  "employeeName": "John Doe",
  "teamName": "Production Team",
  "purpose": "Assembly work for Project X",
  "issuedDate": "2024-03-01",
  "expectedReturnDate": "2024-03-15",
  "actualReturnDate": null,
  "availabilityStatus": "Allocated"
}
```

**Availability Status Flow**:
```
Asset Created → Available
     ↓
Allocated → In Use / Allocated
     ↓
Returned → Available
     ↓
Under Maintenance → Under Maintenance
```

#### PUT /api/allocation/{id}
**Purpose**: Update allocation record (typically to set actual return date).

```csharp
[HttpPut("{id}")]
public async Task<IActionResult> UpdateAllocation(int id, AllocationEntity allocation)
{
    if (id != allocation.AllocationId)
        return BadRequest("ID mismatch");
    
    using var connection = _context.CreateConnection();
    
    var sql = @"UPDATE Allocation 
                SET EmployeeName = @EmployeeName, TeamName = @TeamName, 
                    Purpose = @Purpose, ExpectedReturnDate = @ExpectedReturnDate, 
                    ActualReturnDate = @ActualReturnDate, 
                    AvailabilityStatus = @AvailabilityStatus
                WHERE AllocationId = @AllocationId";
    
    var affectedRows = await connection.ExecuteAsync(sql, allocation);
    
    if (affectedRows == 0)
        return NotFound();
    
    return NoContent();
}
```

**Use Case**: When asset is returned, set ActualReturnDate and change AvailabilityStatus to 'Available'

#### DELETE /api/allocation/{id}
**Purpose**: Delete allocation record.

```csharp
[HttpDelete("{id}")]
public async Task<IActionResult> DeleteAllocation(int id)
{
    using var connection = _context.CreateConnection();
    var sql = "DELETE FROM Allocation WHERE AllocationId = @Id";
    var affectedRows = await connection.ExecuteAsync(sql, new { Id = id });
    
    if (affectedRows == 0)
        return NotFound();
    
    return NoContent();
}
```


### 5.7 ItemDetailsV2Controller.cs

**Purpose**: Unified API for getting and updating item details across all item types (V2 - improved version).

**Base Route**: `/api/v2/item-details`

**Why V2?**
- **Type-Specific Routing**: Includes itemType in URL
- **Cache-Busting**: Ensures fresh data
- **Better Error Handling**: More detailed error messages
- **Field Structure API**: Returns available fields per type

#### GET /api/v2/item-details/{itemId}/{itemType}
**Purpose**: Get complete item details including master and detailed data.

```csharp
[HttpGet("api/v2/item-details/{itemId}/{itemType}")]
public async Task<IActionResult> GetCompleteItemDetails(string itemId, string itemType)
{
    // Add cache-busting headers
    Response.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate");
    Response.Headers.Add("Pragma", "no-cache");
    Response.Headers.Add("Expires", "0");
    
    // Get master data
    var masterItems = await _masterService.GetEnhancedMasterListAsync();
    var masterItem = masterItems.FirstOrDefault(x => x.ItemID == itemId);
    
    if (masterItem == null)
        return NotFound($"Item with ID {itemId} not found");
    
    // Get detailed data based on type
    object detailedData = null;
    switch (itemType.ToLower())
    {
        case "mmd":
            var mmds = await _mmdsService.GetMmdsAsync();
            detailedData = mmds.FirstOrDefault(x => x.MmdId == itemId);
            break;
        case "tool":
            var tools = await _toolService.GetToolsAsync();
            detailedData = tools.FirstOrDefault(x => x.ToolsId == itemId);
            break;
        case "asset":
        case "consumable":
            var assets = await _assetsService.GetAsync();
            detailedData = assets.FirstOrDefault(x => x.AssetId == itemId);
            break;
    }
    
    return Ok(new
    {
        ItemType = itemType,
        MasterData = masterItem,
        DetailedData = detailedData,
        HasDetailedData = detailedData != null
    });
}
```

**Response Format**:
```json
{
  "itemType": "mmd",
  "masterData": {
    "itemID": "MMD001",
    "itemType": "MMD",
    "itemName": "Vernier Caliper",
    "nextServiceDue": "2024-12-01T00:00:00",
    "availabilityStatus": "Available"
  },
  "detailedData": {
    "mmdId": "MMD001",
    "mmdName": "Vernier Caliper",
    "brandName": "Mitutoyo",
    "calibrationFrequency": "Yearly",
    "cost": 5000.00,
    "totalCost": 5500.00
  },
  "hasDetailedData": true
}
```

#### PUT /api/v2/item-details/{itemId}/{itemType}
**Purpose**: Update complete item details.

```csharp
[HttpPut("api/v2/item-details/{itemId}/{itemType}")]
public async Task<IActionResult> UpdateCompleteItemDetails(
    string itemId, 
    string itemType, 
    [FromBody] JsonElement updateData)
{
    bool success = false;
    
    switch (itemType.ToLower())
    {
        case "mmd":
            var mmdData = JsonSerializer.Deserialize<MmdsEntity>(updateData.GetRawText());
            mmdData.MmdId = itemId;
            success = await _mmdsService.UpdateMmdsAsync(mmdData);
            break;
        case "tool":
            var toolData = JsonSerializer.Deserialize<ToolEntity>(updateData.GetRawText());
            toolData.ToolsId = itemId;
            success = await _toolService.UpdateToolAsync(toolData);
            break;
        case "asset":
        case "consumable":
            var assetData = JsonSerializer.Deserialize<AssetsConsumablesEntity>(updateData.GetRawText());
            assetData.AssetId = itemId;
            success = await _assetsService.UpdateAsync(assetData);
            break;
    }
    
    if (!success)
        return BadRequest("Update failed");
    
    return Ok($"{itemType} with ID {itemId} updated successfully");
}
```

#### GET /api/v2/item-details/{itemId}/{itemType}/fields
**Purpose**: Get field structure for a specific item type.

```csharp
[HttpGet("api/v2/item-details/{itemId}/{itemType}/fields")]
public async Task<IActionResult> GetItemFieldStructure(string itemId, string itemType)
{
    switch (itemType.ToLower())
    {
        case "tool":
            return Ok(new
            {
                ItemType = "tool",
                Fields = new
                {
                    Basic = new[] { "ToolsId", "ToolName", "ToolType", "Vendor", "Location" },
                    Purchase = new[] { "PoNumber", "PoDate", "ToolCost", "ExtraCharges" },
                    Maintenance = new[] { "MaintenanceFrequency", "LastAuditDate", "Lifespan" },
                    Management = new[] { "Status", "ResponsibleTeam", "Notes" }
                }
            });
        case "mmd":
            return Ok(new
            {
                ItemType = "mmd",
                Fields = new
                {
                    Basic = new[] { "MmdId", "MmdName", "BrandName", "Vendor" },
                    Calibration = new[] { "CalibrationFrequency", "LastCalibrationDate" },
                    Technical = new[] { "AccuracyClass", "Specifications" }
                }
            });
        // ... other types
    }
}
```

**Use Case**: Dynamic form generation on frontend

### 5.8 NextServiceController.cs

**Purpose**: Calculate and manage next service due dates based on maintenance frequency.

**Base Route**: `/api/NextService`

#### GET /api/NextService/GetLastServiceDate/{assetId}/{assetType}
**Purpose**: Get the most recent service date for an asset.

```csharp
[HttpGet("GetLastServiceDate/{assetId}/{assetType}")]
public async Task<IActionResult> GetLastServiceDate(string assetId, string assetType)
{
    using var connection = _context.CreateConnection();
    
    var query = @"
        SELECT TOP 1 ServiceDate as LastServiceDate
        FROM Maintenance 
        WHERE AssetId = @AssetId AND AssetType = @AssetType 
        AND ServiceDate IS NOT NULL
        ORDER BY ServiceDate DESC";

    var result = await connection.QueryFirstOrDefaultAsync<DateTime?>(query, 
        new { AssetId = assetId, AssetType = assetType });

    return Ok(new { lastServiceDate = result?.ToString("yyyy-MM-ddTHH:mm:ss.fffZ") });
}
```

**Response**:
```json
{
  "lastServiceDate": "2024-04-06T00:00:00.000Z"
}
```

#### GET /api/NextService/GetMaintenanceFrequency/{assetId}/{assetType}
**Purpose**: Get maintenance frequency for an asset.

```csharp
[HttpGet("GetMaintenanceFrequency/{assetId}/{assetType}")]
public async Task<IActionResult> GetMaintenanceFrequency(string assetId, string assetType)
{
    using var connection = _context.CreateConnection();
    
    string query = assetType.ToLower() switch
    {
        "tool" => "SELECT MaintainanceFrequency as MaintenanceFrequency FROM ToolsMaster WHERE ToolsId = @AssetId",
        "mmd" => "SELECT CalibrationFrequency as MaintenanceFrequency FROM MmdsMaster WHERE MmdId = @AssetId",
        "asset" => "SELECT MaintenanceFrequency FROM AssetsConsumablesMaster WHERE AssetId = @AssetId",
        _ => throw new ArgumentException("Invalid asset type")
    };

    var result = await connection.QueryFirstOrDefaultAsync<string>(query, 
        new { AssetId = assetId });

    return Ok(new { maintenanceFrequency = result });
}
```

**Response**:
```json
{
  "maintenanceFrequency": "Quarterly"
}
```

#### POST /api/NextService/CalculateNextServiceDate
**Purpose**: Calculate next service date based on frequency.

```csharp
[HttpPost("CalculateNextServiceDate")]
public IActionResult CalculateNextServiceDate([FromBody] CalculateNextServiceDateRequest request)
{
    var baseDate = request.LastServiceDate ?? request.CreatedDate;
    var nextServiceDate = CalculateNextServiceDateFromFrequency(baseDate, request.MaintenanceFrequency);

    return Ok(new { nextServiceDate = nextServiceDate.ToString("yyyy-MM-ddTHH:mm:ss.fffZ") });
}

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
```

**Request Body**:
```json
{
  "createdDate": "2024-01-15T00:00:00",
  "lastServiceDate": "2024-04-06T00:00:00",
  "maintenanceFrequency": "Quarterly"
}
```

**Response**:
```json
{
  "nextServiceDate": "2024-07-06T00:00:00.000Z"
}
```

**Calculation Logic**:
```
Base Date = Last Service Date (if exists) OR Created Date
Next Service Date = Base Date + Frequency Interval

Examples:
- Daily: Base + 1 day
- Weekly: Base + 7 days
- Monthly: Base + 1 month
- Quarterly: Base + 3 months
- Half-Yearly: Base + 6 months
- Yearly: Base + 1 year
```

#### POST /api/NextService/UpdateNextServiceDate
**Purpose**: Update next service date in master tables.

```csharp
[HttpPost("UpdateNextServiceDate")]
public async Task<IActionResult> UpdateNextServiceDate([FromBody] UpdateNextServiceDateRequest request)
{
    using var connection = _context.CreateConnection();
    
    string updateQuery = request.AssetType.ToLower() switch
    {
        "tool" => "UPDATE ToolsMaster SET NextServiceDue = @NextServiceDate WHERE ToolsId = @AssetId",
        "mmd" => "UPDATE MmdsMaster SET NextCalibration = @NextServiceDate WHERE MmdId = @AssetId",
        "asset" => "UPDATE AssetsConsumablesMaster SET NextServiceDue = @NextServiceDate WHERE AssetId = @AssetId",
        _ => throw new ArgumentException("Invalid asset type")
    };

    var rowsAffected = await connection.ExecuteAsync(updateQuery, new 
    { 
        AssetId = request.AssetId, 
        NextServiceDate = request.NextServiceDate 
    });

    if (rowsAffected > 0)
        return Ok(new { message = "Next service date updated successfully" });
    else
        return NotFound(new { message = "Asset not found" });
}
```

**Request Body**:
```json
{
  "assetId": "MMD001",
  "assetType": "mmd",
  "nextServiceDate": "2024-12-01T00:00:00"
}
```

### 5.9 QualityController.cs

**Purpose**: Manage Quality Control templates and control points.

**Base Route**: `/api/quality`

#### GET /api/quality/final-products
**Purpose**: Get list of final products for template creation.

```csharp
[HttpGet("final-products")]
public async Task<IActionResult> GetFinalProducts()
{
    var data = await _service.GetFinalProducts();
    return Ok(data);
}
```

**Response**:
```json
[
  {
    "finalProductId": 1,
    "productName": "Product A",
    "productCode": "PROD-A-001",
    "description": "Main product line A"
  },
  {
    "finalProductId": 2,
    "productName": "Product B",
    "productCode": "PROD-B-001",
    "description": "Main product line B"
  }
]
```

#### GET /api/quality/materials/{productId}
**Purpose**: Get materials/components for a specific product.

```csharp
[HttpGet("materials/{productId}")]
public async Task<IActionResult> GetMaterials(int productId)
{
    var data = await _service.GetMaterialsByProduct(productId);
    return Ok(data);
}
```

**Response**:
```json
[
  {
    "materialId": 1,
    "materialName": "Steel Grade A",
    "msiCode": "MSI-001",
    "finalProductId": 1,
    "specifications": "High strength steel"
  },
  {
    "materialId": 2,
    "materialName": "Aluminum Alloy",
    "msiCode": "MSI-002",
    "finalProductId": 1,
    "specifications": "Lightweight alloy"
  }
]
```

#### GET /api/quality/validation-types
**Purpose**: Get validation types for QC templates.

```csharp
[HttpGet("validation-types")]
public async Task<IActionResult> GetValidationTypes()
{
    var data = await _service.GetValidationTypes();
    return Ok(data);
}
```

**Response**:
```json
[
  {
    "validationTypeId": 1,
    "validationTypeName": "Incoming Goods Validation",
    "validationTypeCode": "IG"
  },
  {
    "validationTypeId": 2,
    "validationTypeName": "In-progress/Inprocess Validation",
    "validationTypeCode": "IP"
  },
  {
    "validationTypeId": 3,
    "validationTypeName": "Final Inspection",
    "validationTypeCode": "FI"
  }
]
```

#### GET /api/quality/control-point-types
**Purpose**: Get control point types.

```csharp
[HttpGet("control-point-types")]
public async Task<IActionResult> GetControlPointTypes()
{
    var data = await _service.GetControlPointTypes();
    return Ok(data);
}
```

**Response**:
```json
[
  {
    "controlPointTypeId": 1,
    "controlPointTypeName": "Dimensional",
    "description": "Dimensional measurements"
  },
  {
    "controlPointTypeId": 2,
    "controlPointTypeName": "Visual",
    "description": "Visual inspection"
  },
  {
    "controlPointTypeId": 3,
    "controlPointTypeName": "Functional",
    "description": "Functional testing"
  }
]
```

#### GET /api/quality/units
**Purpose**: Get measurement units.

```csharp
[HttpGet("units")]
public async Task<IActionResult> GetUnits()
{
    var data = await _service.GetUnits();
    return Ok(data);
}
```

**Response**:
```json
[
  {
    "unitId": 1,
    "unitName": "mm",
    "description": "Millimeters"
  },
  {
    "unitId": 2,
    "unitName": "kg",
    "description": "Kilograms"
  },
  {
    "unitId": 3,
    "unitName": "%",
    "description": "Percentage"
  }
]
```

#### GET /api/quality/templates
**Purpose**: Get all QC templates.

```csharp
[HttpGet("templates")]
public async Task<IActionResult> GetTemplates()
{
    var data = await _service.GetAllTemplates();
    return Ok(data);
}
```

**Response**:
```json
[
  {
    "templateId": 1,
    "templateName": "IG - Product A - MSI-001 - Steel Grade A",
    "validationTypeId": 1,
    "finalProductId": 1,
    "materialId": 1,
    "tools": "Caliper, Micrometer",
    "createdDate": "2024-01-15T10:30:00",
    "status": true
  }
]
```

#### POST /api/quality/template
**Purpose**: Create new QC template.

```csharp
[HttpPost("template")]
public async Task<IActionResult> CreateTemplate([FromBody] QCTemplateDto dto)
{
    int templateId = await _service.CreateTemplate(dto);
    return Ok(new { templateId });
}
```

**Request Body**:
```json
{
  "templateName": "IG - Product A - MSI-001 - Steel Grade A",
  "validationTypeId": 1,
  "finalProductId": 1,
  "materialId": 1,
  "tools": "Caliper, Micrometer, Gauge"
}
```

**Response**:
```json
{
  "templateId": 5
}
```

#### POST /api/quality/control-point
**Purpose**: Add control point to template.

```csharp
[HttpPost("control-point")]
public async Task<IActionResult> AddControlPoint([FromBody] QCControlPointDto dto)
{
    await _service.AddControlPoint(dto);
    return Ok("Control point added");
}
```

**Request Body**:
```json
{
  "templateId": 5,
  "controlPointTypeId": 1,
  "controlPointName": "Length Measurement",
  "targetValue": "100",
  "unitId": 1,
  "tolerancePlus": "0.5",
  "toleranceMinus": "0.5",
  "sequenceNumber": 1
}
```

#### GET /api/quality/control-points/{templateId}
**Purpose**: Get all control points for a template.

```csharp
[HttpGet("control-points/{templateId}")]
public async Task<IActionResult> GetControlPoints(int templateId)
{
    var data = await _service.GetControlPoints(templateId);
    return Ok(data);
}
```

**Response**:
```json
[
  {
    "controlPointId": 1,
    "templateId": 5,
    "controlPointTypeId": 1,
    "controlPointName": "Length Measurement",
    "targetValue": "100",
    "unitId": 1,
    "unitName": "mm",
    "tolerancePlus": "0.5",
    "toleranceMinus": "0.5",
    "sequenceNumber": 1
  },
  {
    "controlPointId": 2,
    "templateId": 5,
    "controlPointTypeId": 2,
    "controlPointName": "Surface Finish",
    "targetValue": "Smooth",
    "unitId": null,
    "unitName": null,
    "tolerancePlus": null,
    "toleranceMinus": null,
    "sequenceNumber": 2
  }
]
```

#### DELETE /api/quality/control-point/{id}
**Purpose**: Delete control point.

```csharp
[HttpDelete("control-point/{id}")]
public async Task<IActionResult> DeleteControlPoint(int id)
{
    await _service.DeleteControlPoint(id);
    return Ok("Deleted");
}
```

**Template Naming Convention**:
```
Format: {ValidationTypeCode} - {ProductName} - {MSICode} - {MaterialName}

Examples:
- IG - Product A - MSI-001 - Steel Grade A
- IP - Product B - MSI-002 - Aluminum Alloy
- FI - Product C - MSI-003 - Plastic Component
```

**Unique Material Constraint**:
- Each material can have only ONE template
- Prevents duplicate templates for the same material
- Database constraint: `CONSTRAINT UQ_Material_Template UNIQUE (MaterialId)`


## 6. API Endpoints Summary

### Master Register Endpoints
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/master-list` | Get all inventory items |
| GET | `/api/enhanced-master-list` | Get enhanced list with calculations |
| GET | `/api/enhanced-master-list/paginated` | Get paginated, searchable, sortable list |
| GET | `/api/debug-next-service` | Debug next service calculations |

### MMD Endpoints
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/mmds` | Get all MMDs |
| POST | `/api/addmmds` | Create new MMD |
| PUT | `/api/updatemmds` | Update MMD |
| DELETE | `/api/Mmds/{id}` | Delete MMD |

### Tool Endpoints
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/tools` | Get all tools |
| POST | `/api/addtools` | Create new tool |
| DELETE | `/api/Tools/{id}` | Delete tool |

### Asset/Consumable Endpoints
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/assets-consumables` | Get all assets/consumables |
| GET | `/api/asset-full-details` | Get complete asset details |
| POST | `/api/add-assets-consumables` | Create new asset/consumable |
| PUT | `/api/update-assets-consumables` | Update asset/consumable |
| DELETE | `/api/AssetsConsumables/{id}` | Delete asset/consumable |

### Maintenance Endpoints
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/maintenance` | Get all maintenance records |
| GET | `/api/maintenance/{assetId}` | Get maintenance by asset |
| GET | `/api/maintenance/paginated/{assetId}` | Get paginated maintenance |
| POST | `/api/maintenance` | Create maintenance record |
| PUT | `/api/maintenance/{id}` | Update maintenance record |
| DELETE | `/api/maintenance/{id}` | Delete maintenance record |

### Allocation Endpoints
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/allocation` | Get all allocations |
| GET | `/api/allocation/{assetId}` | Get allocations by asset |
| GET | `/api/allocation/paginated/{assetId}` | Get paginated allocations |
| POST | `/api/allocation` | Create allocation record |
| PUT | `/api/allocation/{id}` | Update allocation record |
| DELETE | `/api/allocation/{id}` | Delete allocation record |

### Item Details Endpoints (V2)
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v2/item-details/{itemId}/{itemType}` | Get complete item details |
| PUT | `/api/v2/item-details/{itemId}/{itemType}` | Update complete item details |
| GET | `/api/v2/item-details/{itemId}/{itemType}/fields` | Get field structure |

### Next Service Endpoints
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/NextService/GetLastServiceDate/{assetId}/{assetType}` | Get last service date |
| GET | `/api/NextService/GetMaintenanceFrequency/{assetId}/{assetType}` | Get maintenance frequency |
| POST | `/api/NextService/CalculateNextServiceDate` | Calculate next service date |
| POST | `/api/NextService/UpdateNextServiceDate` | Update next service date |

### Quality Control Endpoints
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/quality/final-products` | Get final products |
| GET | `/api/quality/materials/{productId}` | Get materials by product |
| GET | `/api/quality/validation-types` | Get validation types |
| GET | `/api/quality/control-point-types` | Get control point types |
| GET | `/api/quality/units` | Get measurement units |
| GET | `/api/quality/templates` | Get all templates |
| GET | `/api/quality/control-points/{templateId}` | Get control points |
| POST | `/api/quality/template` | Create template |
| POST | `/api/quality/control-point` | Add control point |
| DELETE | `/api/quality/control-point/{id}` | Delete control point |

## 7. Data Flow & Patterns

### 7.1 Request-Response Flow

```
Client (Flutter)
    ↓ HTTP Request
Controller (Presentation Layer)
    ↓ Call Service Method
Service (Business Logic Layer)
    ↓ Call Repository Method
Repository (Data Access Layer)
    ↓ Execute SQL Query
Database (SQL Server)
    ↓ Return Data
Repository (Map to Entity)
    ↓ Return Entity
Service (Apply Business Rules)
    ↓ Return DTO
Controller (Format Response)
    ↓ HTTP Response
Client (Flutter)
```

### 7.2 Maintenance Creation Flow

```
1. Frontend submits maintenance form
   ↓
2. MaintenanceController.CreateMaintenance()
   ↓
3. Insert into Maintenance table
   ↓
4. Get MaintenanceId from SCOPE_IDENTITY()
   ↓
5. UpdateMasterItemNextServiceDue() called
   ↓
6. Update MasterRegister.NextServiceDue
   ↓
7. Return maintenance record with ID
   ↓
8. Frontend updates reactive state
   ↓
9. Frontend refreshes master list
   ↓
10. User sees updated Next Service Due immediately
```

### 7.3 Pagination Pattern

**Server-Side Pagination Benefits**:
- Reduces data transfer
- Improves performance with large datasets
- Enables server-side search and sort
- Consistent with REST best practices

**SQL Pattern**:
```sql
WITH FilteredData AS (
    SELECT * FROM Table
    WHERE (@SearchText IS NULL OR Column LIKE '%' + @SearchText + '%')
)
SELECT *, COUNT(*) OVER() AS TotalCount
FROM FilteredData
ORDER BY Column
OFFSET @Offset ROWS
FETCH NEXT @PageSize ROWS ONLY;
```

**Response Pattern**:
```json
{
  "totalCount": 150,
  "pageNumber": 1,
  "pageSize": 10,
  "totalPages": 15,
  "items": [...]
}
```

### 7.4 Search Pattern

**Multi-Column Search**:
```sql
WHERE (@SearchText IS NULL OR @SearchText = '' OR
    Column1 LIKE '%' + @SearchText + '%' OR
    Column2 LIKE '%' + @SearchText + '%' OR
    Column3 LIKE '%' + @SearchText + '%' OR
    CONVERT(VARCHAR, DateColumn, 120) LIKE '%' + @SearchText + '%')
```

**Why This Pattern?**
- Searches across all relevant columns
- Handles NULL search text
- Converts dates to searchable format
- Case-insensitive by default

### 7.5 Sorting Pattern

**Dynamic ORDER BY**:
```csharp
var columnMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
{
    { "serviceDate", "ServiceDate" },
    { "cost", "Cost" },
    { "status", "Status" }
};

var orderByClause = "ORDER BY CreatedDate DESC"; // Default

if (!string.IsNullOrEmpty(sortColumn) && columnMap.TryGetValue(sortColumn, out var dbColumn))
{
    var direction = sortDirection?.ToUpper() == "DESC" ? "DESC" : "ASC";
    orderByClause = $"ORDER BY {dbColumn} {direction}";
}

query = query.Replace("{ORDER_BY_CLAUSE}", orderByClause);
```

**Why This Pattern?**
- Prevents SQL injection
- Maps frontend column names to database columns
- Provides default sorting
- Case-insensitive column matching

## 8. Error Handling & Logging

### 8.1 Error Handling Pattern

**Controller Level**:
```csharp
try
{
    var data = await _service.GetData();
    return Ok(data);
}
catch (Exception ex)
{
    Console.WriteLine($"Error: {ex.Message}");
    Console.WriteLine($"Stack trace: {ex.StackTrace}");
    return StatusCode(500, new { error = "Internal server error", message = ex.Message });
}
```

**Why This Pattern?**
- Catches all exceptions
- Logs to console for debugging
- Returns user-friendly error message
- Includes stack trace for troubleshooting
- Returns appropriate HTTP status code

### 8.2 Logging Pattern

**Console Logging**:
```csharp
Console.WriteLine("=== OPERATION START ===");
Console.WriteLine($"Parameter: {value}");
Console.WriteLine($"✓ SUCCESS! Result: {result}");
Console.WriteLine($"⚠️  WARNING: Issue detected");
Console.WriteLine($"❌ ERROR: {ex.Message}");
Console.WriteLine("=== OPERATION END ===");
```

**Why Console Logging?**
- Simple and effective for development
- Easy to read in Visual Studio output
- No additional dependencies
- Can be replaced with proper logging framework (Serilog, NLog) in production

### 8.3 Validation Pattern

**Input Validation**:
```csharp
if (pageNumber < 1) pageNumber = 1;
if (pageSize < 1) pageSize = 10;
if (pageSize > 100) pageSize = 100; // Max limit

if (id != entity.Id)
    return BadRequest("ID mismatch");

if (string.IsNullOrEmpty(requiredField))
    return BadRequest("Required field is missing");
```

**Why This Pattern?**
- Prevents invalid input
- Protects against abuse (e.g., huge page sizes)
- Returns clear error messages
- Validates before database operations

## 9. Best Practices & Guidelines

### 9.1 Controller Best Practices

**DO**:
- ✅ Keep controllers thin (delegate to services)
- ✅ Use async/await for all database operations
- ✅ Return appropriate HTTP status codes
- ✅ Validate input parameters
- ✅ Use route attributes for clear API structure
- ✅ Add cache-busting headers for fresh data
- ✅ Log important operations

**DON'T**:
- ❌ Put business logic in controllers
- ❌ Access database directly from controllers
- ❌ Return raw exceptions to clients
- ❌ Use magic strings (use constants)
- ❌ Ignore error handling

### 9.2 Service Best Practices

**DO**:
- ✅ Implement interfaces for testability
- ✅ Keep services focused (Single Responsibility)
- ✅ Use dependency injection
- ✅ Validate business rules
- ✅ Return DTOs, not entities
- ✅ Handle exceptions appropriately

**DON'T**:
- ❌ Mix data access with business logic
- ❌ Return database entities directly
- ❌ Swallow exceptions silently
- ❌ Create circular dependencies

### 9.3 Repository Best Practices

**DO**:
- ✅ Use Dapper for performance
- ✅ Use parameterized queries (prevent SQL injection)
- ✅ Dispose connections properly (using statement)
- ✅ Map database results to entities
- ✅ Handle NULL values gracefully
- ✅ Use transactions for multi-step operations

**DON'T**:
- ❌ Concatenate SQL strings with user input
- ❌ Leave connections open
- ❌ Return anonymous types
- ❌ Ignore database errors

### 9.4 Database Best Practices

**DO**:
- ✅ Use stored procedures for complex operations
- ✅ Create indexes on frequently queried columns
- ✅ Use foreign keys for referential integrity
- ✅ Implement soft deletes (Status field)
- ✅ Use computed columns for calculated fields
- ✅ Add default values where appropriate

**DON'T**:
- ❌ Use SELECT * in production code
- ❌ Store sensitive data in plain text
- ❌ Create tables without primary keys
- ❌ Ignore normalization principles
- ❌ Hard delete records (use soft delete)

### 9.5 API Design Best Practices

**DO**:
- ✅ Use RESTful conventions
- ✅ Version your APIs (v1, v2)
- ✅ Return consistent response formats
- ✅ Use proper HTTP methods (GET, POST, PUT, DELETE)
- ✅ Implement pagination for large datasets
- ✅ Add Swagger documentation
- ✅ Enable CORS for cross-origin requests

**DON'T**:
- ❌ Use verbs in endpoint names (use nouns)
- ❌ Return different formats for same endpoint
- ❌ Ignore HTTP status codes
- ❌ Return entire database tables
- ❌ Expose internal implementation details

### 9.6 Security Best Practices

**DO**:
- ✅ Use parameterized queries
- ✅ Validate all input
- ✅ Implement authentication/authorization
- ✅ Use HTTPS in production
- ✅ Store connection strings securely
- ✅ Implement rate limiting
- ✅ Log security events

**DON'T**:
- ❌ Trust user input
- ❌ Store passwords in plain text
- ❌ Expose stack traces to clients
- ❌ Use default credentials
- ❌ Ignore SQL injection risks

## 10. Conclusion

This Inventory Management Backend demonstrates modern ASP.NET Core development practices with:

- **Clean Architecture**: Clear separation of concerns across layers
- **RESTful API Design**: Consistent, predictable endpoints
- **Performance**: Dapper for fast data access, server-side pagination
- **Maintainability**: Well-organized code structure, dependency injection
- **Scalability**: Stateless design, connection pooling
- **Debugging**: Comprehensive logging throughout
- **Flexibility**: Dynamic table discovery, type-specific handling

### Key Takeaways

1. **Use Dapper for Performance** - Micro-ORM provides speed without sacrificing control
2. **Implement Server-Side Pagination** - Essential for large datasets
3. **Separate Concerns** - Controllers, Services, Repositories each have specific roles
4. **Log Everything** - Console logging helps debug issues quickly
5. **Validate Input** - Protect against invalid data and SQL injection
6. **Handle Errors Gracefully** - Return user-friendly messages, log details
7. **Use Dependency Injection** - Makes code testable and maintainable
8. **Follow REST Conventions** - Makes API predictable and easy to use

### Next Steps for Developers

1. **Understand the Architecture** - Study the layered approach
2. **Learn Dapper** - Understand how queries are executed
3. **Study the Controllers** - See how endpoints are structured
4. **Explore the Database** - Understand table relationships
5. **Test the APIs** - Use Swagger UI to test endpoints
6. **Read the Logs** - Console output shows what's happening
7. **Follow the Patterns** - Use existing code as templates

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Maintained By**: Development Team

**Technologies Used**:
- ASP.NET Core 8.0/9.0
- C# 12
- Dapper
- SQL Server
- Swagger/OpenAPI

**Database**: ManufacturingApp (SQL Server)

**API Base URL**: `http://localhost:5069/api`

**Swagger UI**: `http://localhost:5069/swagger`
