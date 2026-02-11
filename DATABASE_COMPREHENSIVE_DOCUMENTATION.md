# DATABASE COMPREHENSIVE DOCUMENTATION
# Inventory Management System - SQL Server Database

## Table of Contents
1. [Database Overview](#database-overview)
2. [Database Architecture](#database-architecture)
3. [Tables Documentation](#tables-documentation)
4. [Stored Procedures](#stored-procedures)
5. [Indexes & Constraints](#indexes--constraints)
6. [Relationships & Foreign Keys](#relationships--foreign-keys)
7. [Data Flow & Triggers](#data-flow--triggers)
8. [SQL Scripts Reference](#sql-scripts-reference)
9. [Database Maintenance](#database-maintenance)
10. [Best Practices](#best-practices)

---

## 1. Database Overview

### Database Information
- **Database Name**: ManufacturingApp
- **Server**: RISHIVASAN-PC
- **DBMS**: Microsoft SQL Server
- **Authentication**: SQL Server Authentication
- **Collation**: SQL_Latin1_General_CP1_CI_AS (default)

### Purpose
The ManufacturingApp database is designed to manage:
- Inventory items (MMDs, Tools, Assets, Consumables)
- Maintenance and service records
- Asset allocation tracking
- Quality control templates and control points
- Master data for products, materials, and validation types

### Database Size & Performance
- **Estimated Size**: 100-500 MB (depending on data volume)
- **Expected Growth**: ~10-20 MB per month
- **Concurrent Users**: 10-50 users
- **Transaction Volume**: Low to Medium

### Why SQL Server?
- **Enterprise-Grade**: Reliable and scalable
- **ACID Compliance**: Ensures data integrity
- **Rich Feature Set**: Stored procedures, triggers, indexes
- **Integration**: Works seamlessly with ASP.NET Core
- **Performance**: Optimized query execution
- **Security**: Role-based access control

---

## 2. Database Architecture

### Entity Relationship Diagram (ERD)

```
┌─────────────────────┐
│   MasterRegister    │ (Central Registry)
│  ─────────────────  │
│  ItemID (PK)        │
│  ItemType           │
│  ItemName           │
│  NextServiceDue     │
│  AvailabilityStatus │
└──────────┬──────────┘
           │
           │ Referenced by
           │
    ┌──────┴──────┬──────────────┬──────────────┐
    │             │              │              │
┌───▼────┐  ┌────▼────┐  ┌──────▼─────┐  ┌────▼────┐
│  MMDs  │  │  Tools  │  │   Assets   │  │Consumab.│
│        │  │         │  │            │  │         │
└────────┘  └─────────┘  └────────────┘  └─────────┘
    │             │              │              │
    └─────────────┴──────────────┴──────────────┘
                  │
          ┌───────┴───────┐
          │               │
    ┌─────▼──────┐  ┌────▼──────┐
    │Maintenance │  │ Allocation│
    │            │  │           │
    └────────────┘  └───────────┘
```

### Quality Control Module

```
┌──────────────────┐
│ ValidationTypes  │
└────────┬─────────┘
         │
    ┌────▼────────┐      ┌─────────────────┐
    │FinalProducts│      │ControlPointTypes│
    └────┬────────┘      └────────┬────────┘
         │                        │
    ┌────▼────────┐               │
    │  Materials  │               │
    └────┬────────┘               │
         │                        │
    ┌────▼────────┐               │
    │ QCTemplates │               │
    └────┬────────┘               │
         │                        │
    ┌────▼────────────────────────▼───┐
    │      QCControlPoints            │
    └─────────────────────────────────┘
```

### Database Layers

```
┌─────────────────────────────────────────┐
│         Application Layer               │
│  (ASP.NET Core Controllers/Services)    │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      Stored Procedures Layer            │
│  (Business Logic in Database)           │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│         Tables Layer                    │
│  (Data Storage)                         │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      Indexes & Constraints              │
│  (Performance & Data Integrity)         │
└─────────────────────────────────────────┘
```


## 3. Tables Documentation

### 3.1 MasterRegister Table

**Purpose**: Central registry of all inventory items across different types.

**Why This Table?**
- **Single Source of Truth**: All items in one place
- **Unified View**: Easy to query all inventory
- **Type Discrimination**: ItemType field determines specific table
- **Quick Access**: Denormalized fields for performance

**Schema**:
```sql
CREATE TABLE MasterRegister (
    ItemID NVARCHAR(50) PRIMARY KEY,
    ItemType NVARCHAR(20) NOT NULL,  -- 'MMD', 'Tool', 'Asset', 'Consumable'
    RefId NVARCHAR(50),
    Type NVARCHAR(100),
    ItemName NVARCHAR(200) NOT NULL,
    Supplier NVARCHAR(200),
    Location NVARCHAR(200),
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ResponsibleTeam NVARCHAR(200),
    NextServiceDue DATETIME NULL,
    AvailabilityStatus NVARCHAR(50) DEFAULT 'Available',
    Status BIT DEFAULT 1
);
```

**Field Descriptions**:

| Field | Type | Description | Why This Design |
|-------|------|-------------|-----------------|
| ItemID | NVARCHAR(50) | Unique identifier (PK) | Alphanumeric IDs like MMD001, TOOL001 |
| ItemType | NVARCHAR(20) | Discriminator field | Determines which detail table to join |
| RefId | NVARCHAR(50) | Reference/Serial number | External reference tracking |
| Type | NVARCHAR(100) | Category/Classification | Grouping similar items |
| ItemName | NVARCHAR(200) | Display name | User-friendly name |
| Supplier | NVARCHAR(200) | Vendor/Manufacturer | Procurement tracking |
| Location | NVARCHAR(200) | Storage location | Physical location tracking |
| CreatedDate | DATETIME | Creation timestamp | Audit trail |
| ResponsibleTeam | NVARCHAR(200) | Owning team | Accountability |
| NextServiceDue | DATETIME | Next service date | Denormalized for performance |
| AvailabilityStatus | NVARCHAR(50) | Current status | 'Available', 'In Use', 'Under Maintenance' |
| Status | BIT | Active/Inactive | Soft delete (1=Active, 0=Inactive) |

**Indexes**:
```sql
-- Primary Key (Clustered)
CREATE UNIQUE CLUSTERED INDEX PK_MasterRegister ON MasterRegister(ItemID);

-- Non-Clustered Indexes for Performance
CREATE NONCLUSTERED INDEX IX_MasterRegister_ItemType ON MasterRegister(ItemType);
CREATE NONCLUSTERED INDEX IX_MasterRegister_NextServiceDue ON MasterRegister(NextServiceDue);
CREATE NONCLUSTERED INDEX IX_MasterRegister_Status ON MasterRegister(Status);
```

**Why These Indexes?**
- **ItemType**: Frequently filtered by type
- **NextServiceDue**: Sorted and filtered for upcoming services
- **Status**: Filtered to show only active items

**Sample Data**:
```sql
INSERT INTO MasterRegister (ItemID, ItemType, ItemName, Supplier, Location, NextServiceDue, AvailabilityStatus)
VALUES 
('MMD001', 'MMD', 'Vernier Caliper', 'Mitutoyo', 'Warehouse A', '2024-12-01', 'Available'),
('TOOL001', 'Tool', 'Drill Machine', 'Bosch', 'Workshop', '2024-11-15', 'In Use'),
('ASSET001', 'Asset', 'Dell Laptop', 'Dell', 'IT Room', NULL, 'Allocated'),
('CON001', 'Consumable', 'Safety Gloves', 'Safety Co', 'Store Room', NULL, 'Available');
```

### 3.2 MMDs Table (Measuring & Monitoring Devices)

**Purpose**: Store detailed information about calibration equipment and measuring devices.

**Why Separate Table?**
- **Specific Fields**: Calibration-specific data
- **Normalization**: Avoid NULL fields in master table
- **Performance**: Only load when needed

**Schema**:
```sql
CREATE TABLE MMDs (
    MmdId NVARCHAR(50) PRIMARY KEY,
    MmdName NVARCHAR(200) NOT NULL,
    BrandName NVARCHAR(200),
    AccuracyClass NVARCHAR(50),
    Supplier NVARCHAR(200),
    CalibratedBy NVARCHAR(200),
    Specifications NVARCHAR(MAX),
    ModelNumber NVARCHAR(100),
    SerialNumber NVARCHAR(100),
    Quantity INT DEFAULT 1,
    CertificateNumber NVARCHAR(100),
    Location NVARCHAR(200),
    
    -- Purchase Information
    PoNumber NVARCHAR(100),
    PoDate DATETIME,
    InvoiceNumber NVARCHAR(100),
    InvoiceDate DATETIME,
    Cost DECIMAL(18,2),
    ExtraCharges DECIMAL(18,2),
    TotalCost AS (Cost + ISNULL(ExtraCharges, 0)) PERSISTED,
    
    -- Calibration Information
    CalibrationFrequency NVARCHAR(50),  -- 'Monthly', 'Quarterly', 'Yearly'
    LastCalibrationDate DATETIME,
    NextCalibrationDate DATETIME,
    WarrantyPeriod NVARCHAR(100),
    CalibrationStatus NVARCHAR(50),
    
    -- Management
    ResponsiblePerson NVARCHAR(200),
    OperatingManual NVARCHAR(500),
    StockMsiAsset NVARCHAR(100),
    AdditionalNotes NVARCHAR(MAX),
    Status BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_MMDs_MasterRegister FOREIGN KEY (MmdId) 
        REFERENCES MasterRegister(ItemID)
);
```

**Key Features**:

1. **Computed Column - TotalCost**:
```sql
TotalCost AS (Cost + ISNULL(ExtraCharges, 0)) PERSISTED
```
**Why?**
- Automatically calculated
- PERSISTED: Stored physically for faster queries
- ISNULL: Handles NULL extra charges

2. **Calibration Tracking**:
- **CalibrationFrequency**: How often calibration is needed
- **LastCalibrationDate**: When last calibrated
- **NextCalibrationDate**: When next calibration is due
- **CalibrationStatus**: 'Calibrated', 'Overdue', 'Pending'

3. **Foreign Key Constraint**:
```sql
CONSTRAINT FK_MMDs_MasterRegister FOREIGN KEY (MmdId) 
    REFERENCES MasterRegister(ItemID)
```
**Why?**
- Ensures referential integrity
- MmdId must exist in MasterRegister
- Prevents orphaned records

**Indexes**:
```sql
CREATE NONCLUSTERED INDEX IX_MMDs_CalibrationFrequency ON MMDs(CalibrationFrequency);
CREATE NONCLUSTERED INDEX IX_MMDs_NextCalibrationDate ON MMDs(NextCalibrationDate);
CREATE NONCLUSTERED INDEX IX_MMDs_Status ON MMDs(Status);
```

**Sample Data**:
```sql
INSERT INTO MMDs (MmdId, MmdName, BrandName, AccuracyClass, Supplier, CalibrationFrequency, 
                  LastCalibrationDate, NextCalibrationDate, Cost, ExtraCharges, CalibrationStatus)
VALUES 
('MMD001', 'Vernier Caliper', 'Mitutoyo', '0.02mm', 'ABC Instruments', 'Yearly', 
 '2024-01-15', '2025-01-15', 5000.00, 500.00, 'Calibrated'),
('MMD002', 'Pressure Gauge', 'WIKA', 'Class 0.6', 'XYZ Tools', 'Half-Yearly', 
 '2024-06-01', '2024-12-01', 8000.00, 800.00, 'Calibrated'),
('MMD003', 'Torque Wrench', 'Norbar', '±3%', 'Tool Suppliers Inc', 'Yearly', 
 '2024-03-20', '2025-03-20', 12000.00, 1200.00, 'Calibrated');
```

### 3.3 Tools Table

**Purpose**: Manage tools inventory with maintenance tracking.

**Schema**:
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
    
    -- Purchase Information
    PoNumber NVARCHAR(100),
    PoDate DATETIME,
    InvoiceNumber NVARCHAR(100),
    InvoiceDate DATETIME,
    ToolCost DECIMAL(18,2),
    ExtraCharges DECIMAL(18,2),
    TotalCost AS (ToolCost + ISNULL(ExtraCharges, 0)) PERSISTED,
    
    -- Maintenance Information
    Lifespan NVARCHAR(100),
    AuditInterval NVARCHAR(50),
    MaintenanceFrequency NVARCHAR(50),  -- 'Daily', 'Weekly', 'Monthly', 'Quarterly', 'Yearly'
    HandlingCertificate NVARCHAR(500),
    LastAuditDate DATETIME,
    LastAuditNotes NVARCHAR(MAX),
    MaxOutput NVARCHAR(100),
    
    -- Management
    Status BIT DEFAULT 1,
    ResponsibleTeam NVARCHAR(200),
    MsiAsset NVARCHAR(100),
    KernAsset NVARCHAR(100),
    Notes NVARCHAR(MAX),
    CreatedDate DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Tools_MasterRegister FOREIGN KEY (ToolsId) 
        REFERENCES MasterRegister(ItemID)
);
```

**Key Features**:

1. **Maintenance Frequency Options**:
- Daily
- Weekly
- Monthly
- Quarterly
- Half-Yearly
- Yearly
- 2nd Year
- 3rd Year

2. **Asset Tracking**:
- **MsiAsset**: MSI asset identifier
- **KernAsset**: Kern asset identifier
- **ArticleCode**: Internal article code

3. **Audit Trail**:
- **LastAuditDate**: When last audited
- **LastAuditNotes**: Audit findings
- **AuditInterval**: How often to audit

**Indexes**:
```sql
CREATE NONCLUSTERED INDEX IX_Tools_MaintenanceFrequency ON Tools(MaintenanceFrequency);
CREATE NONCLUSTERED INDEX IX_Tools_LastAuditDate ON Tools(LastAuditDate);
CREATE NONCLUSTERED INDEX IX_Tools_Status ON Tools(Status);
```

**Sample Data**:
```sql
INSERT INTO Tools (ToolsId, ToolName, ToolType, Vendor, MaintenanceFrequency, 
                   LastAuditDate, ToolCost, ExtraCharges, ResponsibleTeam)
VALUES 
('TOOL001', 'Drill Machine', 'Power Tool', 'Bosch', 'Quarterly', 
 '2024-07-01', 15000.00, 1000.00, 'Maintenance Team'),
('TOOL002', 'Angle Grinder', 'Power Tool', 'Makita', 'Monthly', 
 '2024-09-15', 8000.00, 500.00, 'Workshop Team'),
('TOOL003', 'Hydraulic Press', 'Heavy Equipment', 'Atlas', 'Yearly', 
 '2024-01-10', 150000.00, 10000.00, 'Production Team');
```

### 3.4 AssetsConsumables Table

**Purpose**: Track assets and consumable items with stock levels.

**Schema**:
```sql
CREATE TABLE AssetsConsumables (
    AssetId NVARCHAR(50) PRIMARY KEY,
    AssetName NVARCHAR(200) NOT NULL,
    AssetType NVARCHAR(20) NOT NULL,  -- 'Asset' or 'Consumable'
    Category NVARCHAR(100),
    Vendor NVARCHAR(200),
    StorageLocation NVARCHAR(200),
    Specifications NVARCHAR(MAX),
    
    -- Purchase Information
    PoNumber NVARCHAR(100),
    PoDate DATETIME,
    InvoiceNumber NVARCHAR(100),
    InvoiceDate DATETIME,
    AssetCost DECIMAL(18,2),
    ExtraCharges DECIMAL(18,2),
    TotalCost AS (AssetCost + ISNULL(ExtraCharges, 0)) PERSISTED,
    
    -- Stock Management (for Consumables)
    CurrentStock INT DEFAULT 0,
    MinimumStock INT DEFAULT 0,
    MaximumStock INT DEFAULT 0,
    ReorderLevel INT DEFAULT 0,
    
    -- Management
    Status BIT DEFAULT 1,
    ResponsibleTeam NVARCHAR(200),
    MsiAsset NVARCHAR(100),
    KernAsset NVARCHAR(100),
    Notes NVARCHAR(MAX),
    CreatedDate DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_AssetsConsumables_MasterRegister FOREIGN KEY (AssetId) 
        REFERENCES MasterRegister(ItemID),
    CONSTRAINT CHK_AssetType CHECK (AssetType IN ('Asset', 'Consumable'))
);
```

**Key Features**:

1. **Stock Management**:
```sql
CurrentStock INT DEFAULT 0,
MinimumStock INT DEFAULT 0,
MaximumStock INT DEFAULT 0,
ReorderLevel INT DEFAULT 0
```
**Why?**
- **CurrentStock**: Current quantity in stock
- **MinimumStock**: Minimum acceptable level
- **MaximumStock**: Maximum storage capacity
- **ReorderLevel**: Trigger point for reordering

2. **Check Constraint**:
```sql
CONSTRAINT CHK_AssetType CHECK (AssetType IN ('Asset', 'Consumable'))
```
**Why?**
- Ensures only valid types
- Prevents data entry errors
- Database-level validation

3. **Stock Alert Logic**:
```sql
-- Low stock alert
SELECT * FROM AssetsConsumables 
WHERE CurrentStock <= ReorderLevel AND AssetType = 'Consumable';

-- Overstock alert
SELECT * FROM AssetsConsumables 
WHERE CurrentStock > MaximumStock AND AssetType = 'Consumable';
```

**Indexes**:
```sql
CREATE NONCLUSTERED INDEX IX_AssetsConsumables_AssetType ON AssetsConsumables(AssetType);
CREATE NONCLUSTERED INDEX IX_AssetsConsumables_CurrentStock ON AssetsConsumables(CurrentStock);
CREATE NONCLUSTERED INDEX IX_AssetsConsumables_Status ON AssetsConsumables(Status);
```

**Sample Data**:
```sql
-- Assets
INSERT INTO AssetsConsumables (AssetId, AssetName, AssetType, Category, Vendor, 
                                AssetCost, ExtraCharges, ResponsibleTeam)
VALUES 
('ASSET001', 'Dell Laptop', 'Asset', 'IT Equipment', 'Dell', 
 45000.00, 2000.00, 'IT Team'),
('ASSET002', 'Office Chair', 'Asset', 'Furniture', 'Furniture Co', 
 8000.00, 500.00, 'Admin Team');

-- Consumables
INSERT INTO AssetsConsumables (AssetId, AssetName, AssetType, Category, Vendor, 
                                CurrentStock, MinimumStock, MaximumStock, ReorderLevel,
                                AssetCost, ResponsibleTeam)
VALUES 
('CON001', 'Safety Gloves', 'Consumable', 'PPE', 'Safety Supplies', 
 100, 20, 200, 30, 50.00, 'Safety Team'),
('CON002', 'A4 Paper', 'Consumable', 'Stationery', 'Office Mart', 
 500, 100, 1000, 150, 5.00, 'Admin Team'),
('CON003', 'Welding Rods', 'Consumable', 'Welding Supplies', 'Welding Co', 
 250, 50, 500, 75, 15.00, 'Production Team');
```


### 3.5 Maintenance Table

**Purpose**: Record all maintenance and service activities with automatic Next Service Due updates.

**Why This Table?**
- **Service History**: Complete maintenance records
- **Next Service Calculation**: Automatic date calculation
- **Cost Tracking**: Maintenance cost per service
- **Compliance**: Audit trail for regulatory requirements

**Schema**:
```sql
CREATE TABLE Maintenance (
    MaintenanceId INT IDENTITY(1,1) PRIMARY KEY,
    AssetType NVARCHAR(50) NOT NULL,
    AssetId NVARCHAR(50) NOT NULL,
    ItemName NVARCHAR(255),
    ServiceDate DATETIME,
    ServiceProviderCompany NVARCHAR(255),
    ServiceEngineerName NVARCHAR(255),
    ServiceType NVARCHAR(100),  -- 'Preventive', 'Corrective', 'Calibration', 'Inspection'
    NextServiceDue DATETIME,
    ServiceNotes NVARCHAR(MAX),
    MaintenanceStatus NVARCHAR(50) DEFAULT 'Completed',  -- 'Scheduled', 'In Progress', 'Completed', 'Cancelled'
    Cost DECIMAL(18,2) DEFAULT 0,
    ResponsibleTeam NVARCHAR(255),
    CreatedDate DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Maintenance_MasterRegister FOREIGN KEY (AssetId) 
        REFERENCES MasterRegister(ItemID)
);
```

**Field Descriptions**:

| Field | Type | Description | Why This Design |
|-------|------|-------------|-----------------|
| MaintenanceId | INT IDENTITY | Auto-increment PK | Unique identifier for each service |
| AssetType | NVARCHAR(50) | Type of asset | Determines which table to update |
| AssetId | NVARCHAR(50) | Asset identifier (FK) | Links to MasterRegister |
| ItemName | NVARCHAR(255) | Item name (denormalized) | Quick reference without join |
| ServiceDate | DATETIME | When service was performed | Actual service date |
| ServiceProviderCompany | NVARCHAR(255) | Service provider | Vendor tracking |
| ServiceEngineerName | NVARCHAR(255) | Engineer who performed service | Accountability |
| ServiceType | NVARCHAR(100) | Type of service | Categorization |
| NextServiceDue | DATETIME | Calculated next service date | Updates MasterRegister |
| ServiceNotes | NVARCHAR(MAX) | Service details | Detailed notes |
| MaintenanceStatus | NVARCHAR(50) | Current status | Workflow tracking |
| Cost | DECIMAL(18,2) | Service cost | Financial tracking |
| ResponsibleTeam | NVARCHAR(255) | Responsible team | Ownership |
| CreatedDate | DATETIME | Record creation date | Audit trail |

**Service Types**:
1. **Preventive**: Scheduled maintenance to prevent failures
2. **Corrective**: Repair after failure
3. **Calibration**: Accuracy verification and adjustment
4. **Inspection**: Visual and functional checks
5. **Overhaul**: Complete disassembly and rebuild
6. **Upgrade**: Enhancement or modification

**Maintenance Status Flow**:
```
Scheduled → In Progress → Completed
                ↓
            Cancelled
```

**Indexes**:
```sql
CREATE NONCLUSTERED INDEX IX_Maintenance_AssetId ON Maintenance(AssetId);
CREATE NONCLUSTERED INDEX IX_Maintenance_ServiceDate ON Maintenance(ServiceDate DESC);
CREATE NONCLUSTERED INDEX IX_Maintenance_NextServiceDue ON Maintenance(NextServiceDue);
CREATE NONCLUSTERED INDEX IX_Maintenance_MaintenanceStatus ON Maintenance(MaintenanceStatus);
```

**Why These Indexes?**
- **AssetId**: Frequently queried to get maintenance history
- **ServiceDate**: Sorted by date (DESC for recent first)
- **NextServiceDue**: Filtered for upcoming services
- **MaintenanceStatus**: Filtered by status

**Critical Flow - Next Service Due Update**:
```sql
-- 1. Insert maintenance record
INSERT INTO Maintenance (AssetType, AssetId, ServiceDate, NextServiceDue, ...)
VALUES ('MMD', 'MMD001', '2024-04-06', '2024-12-01', ...);

-- 2. Update MasterRegister (done by backend)
UPDATE MasterRegister 
SET NextServiceDue = '2024-12-01'
WHERE ItemID = 'MMD001';

-- 3. Update specific table (done by backend)
UPDATE MMDs 
SET NextCalibrationDate = '2024-12-01'
WHERE MmdId = 'MMD001';
```

**Sample Data**:
```sql
INSERT INTO Maintenance (AssetType, AssetId, ItemName, ServiceDate, ServiceProviderCompany, 
                         ServiceEngineerName, ServiceType, NextServiceDue, ServiceNotes, 
                         MaintenanceStatus, Cost, ResponsibleTeam)
VALUES 
-- MMD Calibration
('MMD', 'MMD001', 'Vernier Caliper', '2024-04-06', 'ABC Calibration Lab', 
 'Ravi Kumar', 'Calibration', '2024-12-01', 'Annual calibration completed successfully. All measurements within tolerance.', 
 'Completed', 5000.00, 'Production Team'),

-- Tool Maintenance
('Tool', 'TOOL001', 'Drill Machine', '2024-07-15', 'Bosch Service Center', 
 'John Smith', 'Preventive', '2024-10-15', 'Quarterly maintenance completed. Replaced worn parts.', 
 'Completed', 3000.00, 'Maintenance Team'),

-- Asset Repair
('Asset', 'ASSET001', 'Dell Laptop', '2024-08-20', 'Dell Service', 
 'Mike Johnson', 'Corrective', NULL, 'Hard drive replaced. System restored.', 
 'Completed', 8000.00, 'IT Team'),

-- Upcoming Service
('MMD', 'MMD002', 'Pressure Gauge', '2024-06-01', 'WIKA Service', 
 'David Wilson', 'Calibration', '2024-12-01', 'Half-yearly calibration completed.', 
 'Completed', 4500.00, 'Production Team');
```

**Query Examples**:

1. **Get Maintenance History for an Asset**:
```sql
SELECT 
    MaintenanceId,
    ServiceDate,
    ServiceProviderCompany,
    ServiceEngineerName,
    ServiceType,
    NextServiceDue,
    Cost,
    MaintenanceStatus
FROM Maintenance
WHERE AssetId = 'MMD001'
ORDER BY ServiceDate DESC;
```

2. **Get Upcoming Services (Next 30 Days)**:
```sql
SELECT 
    m.AssetId,
    mr.ItemName,
    m.NextServiceDue,
    DATEDIFF(DAY, GETDATE(), m.NextServiceDue) AS DaysUntilService
FROM Maintenance m
INNER JOIN MasterRegister mr ON m.AssetId = mr.ItemID
WHERE m.NextServiceDue BETWEEN GETDATE() AND DATEADD(DAY, 30, GETDATE())
ORDER BY m.NextServiceDue;
```

3. **Get Overdue Services**:
```sql
SELECT 
    m.AssetId,
    mr.ItemName,
    m.NextServiceDue,
    DATEDIFF(DAY, m.NextServiceDue, GETDATE()) AS DaysOverdue
FROM Maintenance m
INNER JOIN MasterRegister mr ON m.AssetId = mr.ItemID
WHERE m.NextServiceDue < GETDATE()
ORDER BY m.NextServiceDue;
```

4. **Get Maintenance Cost Summary**:
```sql
SELECT 
    AssetType,
    COUNT(*) AS TotalServices,
    SUM(Cost) AS TotalCost,
    AVG(Cost) AS AverageCost,
    MIN(Cost) AS MinCost,
    MAX(Cost) AS MaxCost
FROM Maintenance
WHERE YEAR(ServiceDate) = 2024
GROUP BY AssetType
ORDER BY TotalCost DESC;
```

### 3.6 Allocation Table

**Purpose**: Track asset allocation to employees/teams with availability status tracking.

**Why This Table?**
- **Asset Tracking**: Know who has what
- **Return Management**: Track expected vs actual returns
- **Availability Status**: Update asset availability
- **Accountability**: Employee responsibility

**Schema**:
```sql
CREATE TABLE Allocation (
    AllocationId INT IDENTITY(1,1) PRIMARY KEY,
    AssetType NVARCHAR(50) NOT NULL,
    AssetId NVARCHAR(50) NOT NULL,
    ItemName NVARCHAR(255),
    EmployeeId NVARCHAR(50),
    EmployeeName NVARCHAR(200),
    TeamName NVARCHAR(200),
    Purpose NVARCHAR(500),
    IssuedDate DATETIME,
    ExpectedReturnDate DATETIME,
    ActualReturnDate DATETIME NULL,
    AvailabilityStatus NVARCHAR(50),  -- 'Allocated', 'Returned', 'Overdue', 'Lost'
    CreatedDate DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Allocation_MasterRegister FOREIGN KEY (AssetId) 
        REFERENCES MasterRegister(ItemID)
);
```

**Field Descriptions**:

| Field | Type | Description | Why This Design |
|-------|------|-------------|-----------------|
| AllocationId | INT IDENTITY | Auto-increment PK | Unique identifier |
| AssetType | NVARCHAR(50) | Type of asset | Quick reference |
| AssetId | NVARCHAR(50) | Asset identifier (FK) | Links to MasterRegister |
| ItemName | NVARCHAR(255) | Item name (denormalized) | Quick reference |
| EmployeeId | NVARCHAR(50) | Employee identifier | Employee tracking |
| EmployeeName | NVARCHAR(200) | Employee name | User-friendly display |
| TeamName | NVARCHAR(200) | Team name | Department tracking |
| Purpose | NVARCHAR(500) | Reason for allocation | Justification |
| IssuedDate | DATETIME | When issued | Start of allocation |
| ExpectedReturnDate | DATETIME | Expected return date | Planning |
| ActualReturnDate | DATETIME | Actual return date | NULL if not returned |
| AvailabilityStatus | NVARCHAR(50) | Current status | Workflow tracking |
| CreatedDate | DATETIME | Record creation | Audit trail |

**Availability Status Flow**:
```
Available → Allocated → Returned → Available
                ↓
            Overdue (if ExpectedReturnDate < GETDATE() AND ActualReturnDate IS NULL)
                ↓
            Lost (if not returned after extended period)
```

**Indexes**:
```sql
CREATE NONCLUSTERED INDEX IX_Allocation_AssetId ON Allocation(AssetId);
CREATE NONCLUSTERED INDEX IX_Allocation_EmployeeId ON Allocation(EmployeeId);
CREATE NONCLUSTERED INDEX IX_Allocation_IssuedDate ON Allocation(IssuedDate DESC);
CREATE NONCLUSTERED INDEX IX_Allocation_ExpectedReturnDate ON Allocation(ExpectedReturnDate);
CREATE NONCLUSTERED INDEX IX_Allocation_AvailabilityStatus ON Allocation(AvailabilityStatus);
```

**Sample Data**:
```sql
INSERT INTO Allocation (AssetType, AssetId, ItemName, EmployeeId, EmployeeName, TeamName, 
                        Purpose, IssuedDate, ExpectedReturnDate, ActualReturnDate, AvailabilityStatus)
VALUES 
-- Returned allocation
('MMD', 'MMD001', 'Vernier Caliper', 'EMP001', 'John Doe', 'Quality Team', 
 'Calibration work for Project X', '2024-01-15', '2024-01-30', '2024-01-28', 'Returned'),

-- Current allocation
('Asset', 'ASSET001', 'Dell Laptop', 'EMP002', 'Jane Smith', 'Development Team', 
 'Software development for new module', '2024-01-01', '2024-12-31', NULL, 'Allocated'),

-- Overdue allocation
('Tool', 'TOOL001', 'Drill Machine', 'EMP003', 'Mike Johnson', 'Maintenance Team', 
 'Equipment installation', '2024-09-01', '2024-09-15', NULL, 'Overdue'),

-- Short-term allocation
('Consumable', 'CON001', 'Safety Gloves', 'EMP004', 'Sarah Lee', 'Production Team', 
 'Assembly work', '2024-10-01', '2024-10-05', '2024-10-04', 'Returned');
```

**Query Examples**:

1. **Get Current Allocations**:
```sql
SELECT 
    a.AssetId,
    a.ItemName,
    a.EmployeeName,
    a.TeamName,
    a.IssuedDate,
    a.ExpectedReturnDate,
    DATEDIFF(DAY, GETDATE(), a.ExpectedReturnDate) AS DaysUntilReturn
FROM Allocation a
WHERE a.ActualReturnDate IS NULL
ORDER BY a.ExpectedReturnDate;
```

2. **Get Overdue Allocations**:
```sql
SELECT 
    a.AssetId,
    a.ItemName,
    a.EmployeeName,
    a.TeamName,
    a.ExpectedReturnDate,
    DATEDIFF(DAY, a.ExpectedReturnDate, GETDATE()) AS DaysOverdue
FROM Allocation a
WHERE a.ActualReturnDate IS NULL 
  AND a.ExpectedReturnDate < GETDATE()
ORDER BY a.ExpectedReturnDate;
```

3. **Get Allocation History for Employee**:
```sql
SELECT 
    a.AssetId,
    a.ItemName,
    a.IssuedDate,
    a.ExpectedReturnDate,
    a.ActualReturnDate,
    CASE 
        WHEN a.ActualReturnDate IS NULL THEN 'Not Returned'
        WHEN a.ActualReturnDate <= a.ExpectedReturnDate THEN 'On Time'
        ELSE 'Late'
    END AS ReturnStatus
FROM Allocation a
WHERE a.EmployeeId = 'EMP001'
ORDER BY a.IssuedDate DESC;
```

4. **Get Asset Utilization**:
```sql
SELECT 
    a.AssetId,
    mr.ItemName,
    COUNT(*) AS TotalAllocations,
    SUM(CASE WHEN a.ActualReturnDate IS NULL THEN 1 ELSE 0 END) AS CurrentAllocations,
    SUM(CASE WHEN a.ActualReturnDate > a.ExpectedReturnDate THEN 1 ELSE 0 END) AS LateReturns
FROM Allocation a
INNER JOIN MasterRegister mr ON a.AssetId = mr.ItemID
GROUP BY a.AssetId, mr.ItemName
ORDER BY TotalAllocations DESC;
```

**Trigger for Availability Status Update** (Optional):
```sql
CREATE TRIGGER trg_UpdateAvailabilityStatus
ON Allocation
AFTER INSERT, UPDATE
AS
BEGIN
    -- Update MasterRegister availability status when allocation changes
    UPDATE mr
    SET mr.AvailabilityStatus = CASE 
        WHEN i.ActualReturnDate IS NOT NULL THEN 'Available'
        WHEN i.ActualReturnDate IS NULL AND i.ExpectedReturnDate < GETDATE() THEN 'Overdue'
        WHEN i.ActualReturnDate IS NULL THEN 'Allocated'
        ELSE 'Available'
    END
    FROM MasterRegister mr
    INNER JOIN inserted i ON mr.ItemID = i.AssetId;
END;
```

**Why This Trigger?**
- **Automatic Updates**: No manual status updates needed
- **Data Consistency**: Status always reflects current state
- **Real-Time**: Updates immediately on allocation changes


### 3.7 Quality Control Tables

#### 3.7.1 ValidationTypes Table

**Purpose**: Define types of quality validation (Incoming, In-Process, Final).

**Schema**:
```sql
CREATE TABLE ValidationTypes (
    ValidationTypeId INT IDENTITY(1,1) PRIMARY KEY,
    ValidationTypeName NVARCHAR(200) NOT NULL,
    ValidationTypeCode NVARCHAR(10) NOT NULL,  -- 'IG', 'IP', 'FI'
    Description NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
```

**Sample Data**:
```sql
INSERT INTO ValidationTypes (ValidationTypeName, ValidationTypeCode, Description)
VALUES 
('Incoming Goods Validation', 'IG', 'Quality check for incoming materials and components'),
('In-progress/Inprocess Validation', 'IP', 'Quality check during manufacturing process'),
('Final Inspection', 'FI', 'Final quality check before product release');
```

#### 3.7.2 FinalProducts Table

**Purpose**: Store final products for which QC templates are created.

**Schema**:
```sql
CREATE TABLE FinalProducts (
    FinalProductId INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(200) NOT NULL,
    ProductCode NVARCHAR(100),
    Description NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
```

**Sample Data**:
```sql
INSERT INTO FinalProducts (ProductName, ProductCode, Description)
VALUES 
('Product A', 'PROD-A-001', 'Main product line A'),
('Product B', 'PROD-B-001', 'Main product line B'),
('Product C', 'PROD-C-001', 'Main product line C');
```

#### 3.7.3 Materials Table

**Purpose**: Store materials/components used in products.

**Schema**:
```sql
CREATE TABLE Materials (
    MaterialId INT IDENTITY(1,1) PRIMARY KEY,
    MaterialName NVARCHAR(200) NOT NULL,
    MSICode NVARCHAR(100),  -- Material Stock Identification Code
    FinalProductId INT NOT NULL,
    Specifications NVARCHAR(MAX),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Materials_FinalProducts FOREIGN KEY (FinalProductId) 
        REFERENCES FinalProducts(FinalProductId)
);
```

**Sample Data**:
```sql
INSERT INTO Materials (MaterialName, MSICode, FinalProductId, Specifications)
VALUES 
('Steel Grade A', 'MSI-001', 1, 'High strength steel for structural components'),
('Aluminum Alloy', 'MSI-002', 1, 'Lightweight alloy for body panels'),
('Plastic Component', 'MSI-003', 2, 'ABS plastic for housing'),
('Copper Wire', 'MSI-004', 2, 'Electrical wiring component'),
('Rubber Seal', 'MSI-005', 3, 'Waterproof sealing component');
```

#### 3.7.4 ControlPointTypes Table

**Purpose**: Define types of control points (Dimensional, Visual, Functional).

**Schema**:
```sql
CREATE TABLE ControlPointTypes (
    ControlPointTypeId INT IDENTITY(1,1) PRIMARY KEY,
    ControlPointTypeName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
```

**Sample Data**:
```sql
INSERT INTO ControlPointTypes (ControlPointTypeName, Description)
VALUES 
('Dimensional', 'Dimensional measurements and tolerances'),
('Visual', 'Visual inspection for defects, color, finish'),
('Functional', 'Functional testing and performance checks'),
('Material Analysis', 'Material properties and composition analysis'),
('Electrical', 'Electrical parameters and safety checks'),
('Mechanical', 'Mechanical properties and strength tests');
```

#### 3.7.5 Units Table

**Purpose**: Store measurement units for control points.

**Schema**:
```sql
CREATE TABLE Units (
    UnitId INT IDENTITY(1,1) PRIMARY KEY,
    UnitName NVARCHAR(50) NOT NULL,
    UnitSymbol NVARCHAR(20),
    Description NVARCHAR(200),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
```

**Sample Data**:
```sql
INSERT INTO Units (UnitName, UnitSymbol, Description)
VALUES 
('Millimeter', 'mm', 'Length measurement'),
('Centimeter', 'cm', 'Length measurement'),
('Meter', 'm', 'Length measurement'),
('Kilogram', 'kg', 'Weight measurement'),
('Gram', 'g', 'Weight measurement'),
('Degree Celsius', '°C', 'Temperature measurement'),
('Percentage', '%', 'Percentage measurement'),
('Pieces', 'pcs', 'Count measurement'),
('Volt', 'V', 'Electrical voltage'),
('Ampere', 'A', 'Electrical current'),
('Hertz', 'Hz', 'Frequency'),
('Pascal', 'Pa', 'Pressure'),
('Bar', 'bar', 'Pressure'),
('PSI', 'psi', 'Pressure'),
('RPM', 'rpm', 'Rotational speed'),
('Decibel', 'dB', 'Sound level'),
('Lux', 'lux', 'Light intensity'),
('pH', 'pH', 'Acidity/Alkalinity'),
('Ohm', 'Ω', 'Electrical resistance'),
('Watt', 'W', 'Power');
```

#### 3.7.6 QCTemplates Table

**Purpose**: Store quality control templates for materials.

**Why This Table?**
- **Template-Based QC**: Reusable quality checks
- **Material-Specific**: Each material has its own template
- **Unique Constraint**: One template per material
- **Auto-Naming**: Template name generated from metadata

**Schema**:
```sql
CREATE TABLE QCTemplates (
    QCTemplateId INT IDENTITY(1,1) PRIMARY KEY,
    TemplateName NVARCHAR(500) NOT NULL,
    ValidationTypeId INT NOT NULL,
    FinalProductId INT NOT NULL,
    MaterialId INT NOT NULL,
    ToolsToQualityCheck NVARCHAR(500),  -- Tools required for quality check
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),
    Status BIT DEFAULT 1,
    
    CONSTRAINT FK_QCTemplates_ValidationTypes FOREIGN KEY (ValidationTypeId) 
        REFERENCES ValidationTypes(ValidationTypeId),
    CONSTRAINT FK_QCTemplates_FinalProducts FOREIGN KEY (FinalProductId) 
        REFERENCES FinalProducts(FinalProductId),
    CONSTRAINT FK_QCTemplates_Materials FOREIGN KEY (MaterialId) 
        REFERENCES Materials(MaterialId),
    CONSTRAINT UQ_QCTemplate_MaterialId UNIQUE (MaterialId)  -- One template per material
);
```

**Key Features**:

1. **Unique Material Constraint**:
```sql
CONSTRAINT UQ_QCTemplate_MaterialId UNIQUE (MaterialId)
```
**Why?**
- Prevents duplicate templates for same material
- Ensures data consistency
- Simplifies template management

2. **Template Naming Convention**:
```
Format: {ValidationTypeCode} - {ProductName} - {MSICode} - {MaterialName}

Examples:
- IG - Product A - MSI-001 - Steel Grade A
- IP - Product B - MSI-002 - Aluminum Alloy
- FI - Product C - MSI-003 - Plastic Component
```

3. **Tools Field**:
- Stores comma-separated list of tools
- Example: "Caliper, Micrometer, Gauge"
- Used for quality check equipment tracking

**Indexes**:
```sql
CREATE NONCLUSTERED INDEX IX_QCTemplates_ValidationTypeId ON QCTemplates(ValidationTypeId);
CREATE NONCLUSTERED INDEX IX_QCTemplates_FinalProductId ON QCTemplates(FinalProductId);
CREATE UNIQUE NONCLUSTERED INDEX IX_QCTemplates_MaterialId ON QCTemplates(MaterialId);
CREATE NONCLUSTERED INDEX IX_QCTemplates_Status ON QCTemplates(Status);
```

**Sample Data**:
```sql
INSERT INTO QCTemplates (TemplateName, ValidationTypeId, FinalProductId, MaterialId, ToolsToQualityCheck)
VALUES 
('IG - Product A - MSI-001 - Steel Grade A', 1, 1, 1, 'Caliper, Micrometer, Hardness Tester'),
('IP - Product A - MSI-002 - Aluminum Alloy', 2, 1, 2, 'Caliper, Surface Roughness Tester'),
('FI - Product B - MSI-003 - Plastic Component', 3, 2, 3, 'Caliper, Visual Inspection Tools'),
('IG - Product B - MSI-004 - Copper Wire', 1, 2, 4, 'Multimeter, Resistance Tester'),
('FI - Product C - MSI-005 - Rubber Seal', 3, 3, 5, 'Pressure Tester, Visual Inspection');
```

#### 3.7.7 QCControlPoints Table

**Purpose**: Store individual control points for each QC template.

**Why This Table?**
- **Multiple Checkpoints**: Each template has multiple control points
- **Detailed Specifications**: Target values, tolerances, units
- **Sequence Management**: Order of control points
- **Cascade Delete**: Deleting template removes all control points

**Schema**:
```sql
CREATE TABLE QCControlPoints (
    ControlPointId INT IDENTITY(1,1) PRIMARY KEY,
    QCTemplateId INT NOT NULL,
    ControlPointTypeId INT NOT NULL,
    ControlPointName NVARCHAR(200) NOT NULL,
    TargetValue NVARCHAR(100),
    UnitId INT,
    TolerancePlus NVARCHAR(50),
    ToleranceMinus NVARCHAR(50),
    SequenceNumber INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_QCControlPoints_QCTemplates FOREIGN KEY (QCTemplateId) 
        REFERENCES QCTemplates(QCTemplateId) ON DELETE CASCADE,
    CONSTRAINT FK_QCControlPoints_ControlPointTypes FOREIGN KEY (ControlPointTypeId) 
        REFERENCES ControlPointTypes(ControlPointTypeId),
    CONSTRAINT FK_QCControlPoints_Units FOREIGN KEY (UnitId) 
        REFERENCES Units(UnitId)
);
```

**Field Descriptions**:

| Field | Type | Description | Why This Design |
|-------|------|-------------|-----------------|
| ControlPointId | INT IDENTITY | Auto-increment PK | Unique identifier |
| QCTemplateId | INT | Template reference (FK) | Links to template |
| ControlPointTypeId | INT | Type of control point (FK) | Categorization |
| ControlPointName | NVARCHAR(200) | Name of checkpoint | User-friendly name |
| TargetValue | NVARCHAR(100) | Expected value | Specification |
| UnitId | INT | Measurement unit (FK) | Unit reference |
| TolerancePlus | NVARCHAR(50) | Upper tolerance | Acceptable deviation |
| ToleranceMinus | NVARCHAR(50) | Lower tolerance | Acceptable deviation |
| SequenceNumber | INT | Display order | Ordered list |
| CreatedDate | DATETIME | Creation timestamp | Audit trail |

**Key Features**:

1. **Cascade Delete**:
```sql
CONSTRAINT FK_QCControlPoints_QCTemplates FOREIGN KEY (QCTemplateId) 
    REFERENCES QCTemplates(QCTemplateId) ON DELETE CASCADE
```
**Why?**
- Deleting template automatically deletes all control points
- Maintains referential integrity
- Prevents orphaned records

2. **Tolerance Specification**:
```
Target Value: 100 mm
Tolerance Plus: +0.5 mm
Tolerance Minus: -0.5 mm
Acceptable Range: 99.5 mm to 100.5 mm
```

3. **Sequence Numbering**:
- Controls display order
- Example: 1, 2, 3, 4...
- Allows reordering without changing IDs

**Indexes**:
```sql
CREATE NONCLUSTERED INDEX IX_QCControlPoints_QCTemplateId ON QCControlPoints(QCTemplateId);
CREATE NONCLUSTERED INDEX IX_QCControlPoints_ControlPointTypeId ON QCControlPoints(ControlPointTypeId);
CREATE NONCLUSTERED INDEX IX_QCControlPoints_SequenceNumber ON QCControlPoints(SequenceNumber);
```

**Sample Data**:
```sql
-- Control points for Template 1 (Steel Grade A)
INSERT INTO QCControlPoints (QCTemplateId, ControlPointTypeId, ControlPointName, 
                             TargetValue, UnitId, TolerancePlus, ToleranceMinus, SequenceNumber)
VALUES 
(1, 1, 'Length Measurement', '100', 1, '0.5', '0.5', 1),
(1, 1, 'Width Measurement', '50', 1, '0.3', '0.3', 2),
(1, 1, 'Thickness Measurement', '10', 1, '0.2', '0.2', 3),
(1, 2, 'Surface Finish Check', 'Smooth', NULL, NULL, NULL, 4),
(1, 4, 'Hardness Test', '200', NULL, '10', '10', 5);

-- Control points for Template 2 (Aluminum Alloy)
INSERT INTO QCControlPoints (QCTemplateId, ControlPointTypeId, ControlPointName, 
                             TargetValue, UnitId, TolerancePlus, ToleranceMinus, SequenceNumber)
VALUES 
(2, 1, 'Diameter Measurement', '25', 1, '0.1', '0.1', 1),
(2, 2, 'Visual Inspection', 'No defects', NULL, NULL, NULL, 2),
(2, 3, 'Weight Check', '500', 5, '5', '5', 3);

-- Control points for Template 3 (Plastic Component)
INSERT INTO QCControlPoints (QCTemplateId, ControlPointTypeId, ControlPointName, 
                             TargetValue, UnitId, TolerancePlus, ToleranceMinus, SequenceNumber)
VALUES 
(3, 1, 'Overall Length', '150', 1, '1.0', '1.0', 1),
(3, 2, 'Color Check', 'Black', NULL, NULL, NULL, 2),
(3, 2, 'Surface Defects', 'None', NULL, NULL, NULL, 3),
(3, 3, 'Fit Test', 'Pass', NULL, NULL, NULL, 4);
```

**Query Examples**:

1. **Get Complete Template with Control Points**:
```sql
SELECT 
    t.QCTemplateId,
    t.TemplateName,
    vt.ValidationTypeName,
    fp.ProductName,
    m.MaterialName,
    m.MSICode,
    t.ToolsToQualityCheck,
    cp.ControlPointId,
    cp.ControlPointName,
    cpt.ControlPointTypeName,
    cp.TargetValue,
    u.UnitSymbol,
    cp.TolerancePlus,
    cp.ToleranceMinus,
    cp.SequenceNumber
FROM QCTemplates t
INNER JOIN ValidationTypes vt ON t.ValidationTypeId = vt.ValidationTypeId
INNER JOIN FinalProducts fp ON t.FinalProductId = fp.FinalProductId
INNER JOIN Materials m ON t.MaterialId = m.MaterialId
LEFT JOIN QCControlPoints cp ON t.QCTemplateId = cp.QCTemplateId
LEFT JOIN ControlPointTypes cpt ON cp.ControlPointTypeId = cpt.ControlPointTypeId
LEFT JOIN Units u ON cp.UnitId = u.UnitId
WHERE t.QCTemplateId = 1
ORDER BY cp.SequenceNumber;
```

2. **Get Templates by Product**:
```sql
SELECT 
    t.QCTemplateId,
    t.TemplateName,
    vt.ValidationTypeCode,
    m.MaterialName,
    COUNT(cp.ControlPointId) AS TotalControlPoints
FROM QCTemplates t
INNER JOIN ValidationTypes vt ON t.ValidationTypeId = vt.ValidationTypeId
INNER JOIN Materials m ON t.MaterialId = m.MaterialId
LEFT JOIN QCControlPoints cp ON t.QCTemplateId = cp.QCTemplateId
WHERE t.FinalProductId = 1
GROUP BY t.QCTemplateId, t.TemplateName, vt.ValidationTypeCode, m.MaterialName
ORDER BY t.TemplateName;
```

3. **Check for Duplicate Material Template**:
```sql
SELECT MaterialId, COUNT(*) AS TemplateCount
FROM QCTemplates
WHERE Status = 1
GROUP BY MaterialId
HAVING COUNT(*) > 1;
```


---

## 4. Stored Procedures

For complete stored procedures documentation, see **DATABASE_STORED_PROCEDURES.md**.

### Overview of Stored Procedures

The system uses 16 stored procedures for database operations:

**Quality Control (11 procedures)**:
- `sp_CreateQCTemplate` - Create QC templates with duplicate prevention
- `sp_GetAllQCTemplates` - Retrieve all templates with related data
- `sp_UpdateQCTemplate` - Update template fields
- `sp_AddQCControlPoint` - Add control points with auto-sequencing
- `sp_GetQCControlPointsByTemplate` - Get control points for template
- `sp_DeleteQCControlPoint` - Delete control points
- `sp_GetFinalProducts` - Get all final products
- `sp_GetMaterialsByFinalProduct` - Get materials by product
- `sp_GetValidationTypes` - Get validation types (IG, IP, FI)
- `sp_GetUnits` - Get measurement units
- `sp_GetQCControlPointTypes` - Get control point types

**Master Register (1 procedure)**:
- `sp_GetMasterListPaginated` - Paginated list with search/sort/filter

**Maintenance & Allocation (4 procedures)**:
- `sp_AddMaintenance` - Add maintenance with cascading updates
- `sp_GetMaintenancePaginated` - Paginated maintenance records
- `sp_AddAllocation` - Add allocation with status update
- `sp_ReturnAllocation` - Return allocation with smart status

### Key Features

1. **Error Handling**: All procedures use TRY-CATCH blocks
2. **Transactions**: Multi-table updates use transactions
3. **Output Parameters**: Return generated IDs
4. **Pagination**: Support for large datasets
5. **Search & Sort**: Flexible querying
6. **Cascading Updates**: Automatic related table updates
7. **Duplicate Prevention**: Unique constraints enforced
8. **Parameter Validation**: Input validation

---

## 5. Indexes & Constraints

### 5.1 Primary Keys (Clustered Indexes)

**Why Clustered Indexes?**
- Physical ordering of data
- Fastest access by primary key
- One per table
- Automatically created with PRIMARY KEY

**All Primary Keys**:
```sql
-- MasterRegister
ALTER TABLE MasterRegister ADD CONSTRAINT PK_MasterRegister PRIMARY KEY CLUSTERED (ItemID);

-- MMDs
ALTER TABLE MMDs ADD CONSTRAINT PK_MMDs PRIMARY KEY CLUSTERED (MmdId);

-- Tools
ALTER TABLE Tools ADD CONSTRAINT PK_Tools PRIMARY KEY CLUSTERED (ToolsId);

-- AssetsConsumables
ALTER TABLE AssetsConsumables ADD CONSTRAINT PK_AssetsConsumables PRIMARY KEY CLUSTERED (AssetId);

-- Maintenance
ALTER TABLE Maintenance ADD CONSTRAINT PK_Maintenance PRIMARY KEY CLUSTERED (MaintenanceId);

-- Allocation
ALTER TABLE Allocation ADD CONSTRAINT PK_Allocation PRIMARY KEY CLUSTERED (AllocationId);

-- QC Tables
ALTER TABLE ValidationTypes ADD CONSTRAINT PK_ValidationTypes PRIMARY KEY CLUSTERED (ValidationTypeId);
ALTER TABLE FinalProducts ADD CONSTRAINT PK_FinalProducts PRIMARY KEY CLUSTERED (FinalProductId);
ALTER TABLE Materials ADD CONSTRAINT PK_Materials PRIMARY KEY CLUSTERED (MaterialId);
ALTER TABLE ControlPointTypes ADD CONSTRAINT PK_ControlPointTypes PRIMARY KEY CLUSTERED (ControlPointTypeId);
ALTER TABLE Units ADD CONSTRAINT PK_Units PRIMARY KEY CLUSTERED (UnitId);
ALTER TABLE QCTemplates ADD CONSTRAINT PK_QCTemplates PRIMARY KEY CLUSTERED (QCTemplateId);
ALTER TABLE QCControlPoints ADD CONSTRAINT PK_QCControlPoints PRIMARY KEY CLUSTERED (ControlPointId);
```


### 5.2 Non-Clustered Indexes

**Why Non-Clustered Indexes?**
- Faster queries on frequently filtered columns
- Multiple per table
- Separate structure from data
- Trade-off: Faster reads, slower writes

**MasterRegister Indexes**:
```sql
CREATE NONCLUSTERED INDEX IX_MasterRegister_ItemType ON MasterRegister(ItemType);
CREATE NONCLUSTERED INDEX IX_MasterRegister_NextServiceDue ON MasterRegister(NextServiceDue);
CREATE NONCLUSTERED INDEX IX_MasterRegister_Status ON MasterRegister(Status);
CREATE NONCLUSTERED INDEX IX_MasterRegister_AvailabilityStatus ON MasterRegister(AvailabilityStatus);
```

**Why These Indexes?**
- **ItemType**: Frequently filtered (MMD, Tool, Asset, Consumable)
- **NextServiceDue**: Sorted for upcoming services
- **Status**: Filtered for active/inactive items
- **AvailabilityStatus**: Filtered for available items

**MMDs Indexes**:
```sql
CREATE NONCLUSTERED INDEX IX_MMDs_CalibrationFrequency ON MMDs(CalibrationFrequency);
CREATE NONCLUSTERED INDEX IX_MMDs_NextCalibrationDate ON MMDs(NextCalibrationDate);
CREATE NONCLUSTERED INDEX IX_MMDs_Status ON MMDs(Status);
CREATE NONCLUSTERED INDEX IX_MMDs_Location ON MMDs(Location);
```

**Tools Indexes**:
```sql
CREATE NONCLUSTERED INDEX IX_Tools_MaintenanceFrequency ON Tools(MaintenanceFrequency);
CREATE NONCLUSTERED INDEX IX_Tools_LastAuditDate ON Tools(LastAuditDate);
CREATE NONCLUSTERED INDEX IX_Tools_Status ON Tools(Status);
CREATE NONCLUSTERED INDEX IX_Tools_StorageLocation ON Tools(StorageLocation);
```

**AssetsConsumables Indexes**:
```sql
CREATE NONCLUSTERED INDEX IX_AssetsConsumables_AssetType ON AssetsConsumables(AssetType);
CREATE NONCLUSTERED INDEX IX_AssetsConsumables_CurrentStock ON AssetsConsumables(CurrentStock);
CREATE NONCLUSTERED INDEX IX_AssetsConsumables_Status ON AssetsConsumables(Status);
CREATE NONCLUSTERED INDEX IX_AssetsConsumables_StorageLocation ON AssetsConsumables(StorageLocation);
```

**Maintenance Indexes**:
```sql
CREATE NONCLUSTERED INDEX IX_Maintenance_AssetId ON Maintenance(AssetId);
CREATE NONCLUSTERED INDEX IX_Maintenance_ServiceDate ON Maintenance(ServiceDate DESC);
CREATE NONCLUSTERED INDEX IX_Maintenance_NextServiceDue ON Maintenance(NextServiceDue);
CREATE NONCLUSTERED INDEX IX_Maintenance_MaintenanceStatus ON Maintenance(MaintenanceStatus);
CREATE NONCLUSTERED INDEX IX_Maintenance_AssetType ON Maintenance(AssetType);
```

**Allocation Indexes**:
```sql
CREATE NONCLUSTERED INDEX IX_Allocation_AssetId ON Allocation(AssetId);
CREATE NONCLUSTERED INDEX IX_Allocation_EmployeeId ON Allocation(EmployeeId);
CREATE NONCLUSTERED INDEX IX_Allocation_IssuedDate ON Allocation(IssuedDate DESC);
CREATE NONCLUSTERED INDEX IX_Allocation_ExpectedReturnDate ON Allocation(ExpectedReturnDate);
CREATE NONCLUSTERED INDEX IX_Allocation_AvailabilityStatus ON Allocation(AvailabilityStatus);
```

**QC Tables Indexes**:
```sql
-- QCTemplates
CREATE NONCLUSTERED INDEX IX_QCTemplates_ValidationTypeId ON QCTemplates(ValidationTypeId);
CREATE NONCLUSTERED INDEX IX_QCTemplates_FinalProductId ON QCTemplates(FinalProductId);
CREATE UNIQUE NONCLUSTERED INDEX IX_QCTemplates_MaterialId ON QCTemplates(MaterialId);
CREATE NONCLUSTERED INDEX IX_QCTemplates_Status ON QCTemplates(Status);

-- QCControlPoints
CREATE NONCLUSTERED INDEX IX_QCControlPoints_QCTemplateId ON QCControlPoints(QCTemplateId);
CREATE NONCLUSTERED INDEX IX_QCControlPoints_ControlPointTypeId ON QCControlPoints(ControlPointTypeId);
CREATE NONCLUSTERED INDEX IX_QCControlPoints_SequenceNumber ON QCControlPoints(SequenceNumber);

-- Materials
CREATE NONCLUSTERED INDEX IX_Materials_FinalProductId ON Materials(FinalProductId);
CREATE NONCLUSTERED INDEX IX_Materials_MSICode ON Materials(MSICode);
```

### 5.3 Unique Constraints

**QCTemplates - Unique Material Constraint**:
```sql
ALTER TABLE QCTemplates
ADD CONSTRAINT UQ_QCTemplate_MaterialId UNIQUE (MaterialId);
```

**Why?**
- Prevents duplicate templates for same material
- Enforces business rule: One template per material
- Database-level validation
- Prevents data inconsistency

**Check Constraint Example**:
```sql
ALTER TABLE AssetsConsumables
ADD CONSTRAINT CHK_AssetType CHECK (AssetType IN ('Asset', 'Consumable'));
```

**Why?**
- Validates data at database level
- Prevents invalid values
- Enforces business rules
- Better than application-level validation


---

## 6. Relationships & Foreign Keys

### 6.1 Entity Relationship Diagram

```
┌─────────────────────┐
│   MasterRegister    │ (Central Hub)
│  ─────────────────  │
│  ItemID (PK)        │◄─────────────┐
│  ItemType           │              │
│  ItemName           │              │
│  NextServiceDue     │              │
│  AvailabilityStatus │              │
└──────────┬──────────┘              │
           │                         │
           │ 1:1 Relationship        │
           │                         │
    ┌──────┴──────┬──────────────┬──┴──────────┐
    │             │              │              │
┌───▼────┐  ┌────▼────┐  ┌──────▼─────┐  ┌────▼────┐
│  MMDs  │  │  Tools  │  │   Assets   │  │Consumab.│
│  (FK)  │  │  (FK)   │  │   (FK)     │  │  (FK)   │
└────┬───┘  └─────┬───┘  └──────┬─────┘  └────┬────┘
     │            │              │              │
     └────────────┴──────────────┴──────────────┘
                  │
          ┌───────┴───────┐
          │               │
    ┌─────▼──────┐  ┌────▼──────┐
    │Maintenance │  │ Allocation│
    │    (FK)    │  │   (FK)    │
    └────────────┘  └───────────┘
```

### 6.2 Foreign Key Constraints

**MMDs Table**:
```sql
ALTER TABLE MMDs
ADD CONSTRAINT FK_MMDs_MasterRegister 
FOREIGN KEY (MmdId) REFERENCES MasterRegister(ItemID);
```

**Why?**
- Ensures MmdId exists in MasterRegister
- Prevents orphaned records
- Maintains referential integrity
- Cascading options available

**Tools Table**:
```sql
ALTER TABLE Tools
ADD CONSTRAINT FK_Tools_MasterRegister 
FOREIGN KEY (ToolsId) REFERENCES MasterRegister(ItemID);
```

**AssetsConsumables Table**:
```sql
ALTER TABLE AssetsConsumables
ADD CONSTRAINT FK_AssetsConsumables_MasterRegister 
FOREIGN KEY (AssetId) REFERENCES MasterRegister(ItemID);
```

**Maintenance Table**:
```sql
ALTER TABLE Maintenance
ADD CONSTRAINT FK_Maintenance_MasterRegister 
FOREIGN KEY (AssetId) REFERENCES MasterRegister(ItemID);
```

**Allocation Table**:
```sql
ALTER TABLE Allocation
ADD CONSTRAINT FK_Allocation_MasterRegister 
FOREIGN KEY (AssetId) REFERENCES MasterRegister(ItemID);
```

### 6.3 Quality Control Relationships

```
┌──────────────────┐
│ ValidationTypes  │
└────────┬─────────┘
         │ 1:N
    ┌────▼────────┐      ┌─────────────────┐
    │FinalProducts│      │ControlPointTypes│
    └────┬────────┘      └────────┬────────┘
         │ 1:N                    │ 1:N
    ┌────▼────────┐               │
    │  Materials  │               │
    └────┬────────┘               │
         │ 1:1                    │
    ┌────▼────────┐               │
    │ QCTemplates │               │
    └────┬────────┘               │
         │ 1:N                    │
    ┌────▼────────────────────────▼───┐
    │      QCControlPoints            │
    └─────────────────────────────────┘
```

**QCTemplates Foreign Keys**:
```sql
-- Validation Type
ALTER TABLE QCTemplates
ADD CONSTRAINT FK_QCTemplates_ValidationTypes 
FOREIGN KEY (ValidationTypeId) REFERENCES ValidationTypes(ValidationTypeId);

-- Final Product
ALTER TABLE QCTemplates
ADD CONSTRAINT FK_QCTemplates_FinalProducts 
FOREIGN KEY (FinalProductId) REFERENCES FinalProducts(FinalProductId);

-- Material (1:1 relationship)
ALTER TABLE QCTemplates
ADD CONSTRAINT FK_QCTemplates_Materials 
FOREIGN KEY (MaterialId) REFERENCES Materials(MaterialId);
```

**Materials Foreign Key**:
```sql
ALTER TABLE Materials
ADD CONSTRAINT FK_Materials_FinalProducts 
FOREIGN KEY (FinalProductId) REFERENCES FinalProducts(FinalProductId);
```

**QCControlPoints Foreign Keys**:
```sql
-- Template (with CASCADE DELETE)
ALTER TABLE QCControlPoints
ADD CONSTRAINT FK_QCControlPoints_QCTemplates 
FOREIGN KEY (QCTemplateId) REFERENCES QCTemplates(QCTemplateId) 
ON DELETE CASCADE;

-- Control Point Type
ALTER TABLE QCControlPoints
ADD CONSTRAINT FK_QCControlPoints_ControlPointTypes 
FOREIGN KEY (ControlPointTypeId) REFERENCES ControlPointTypes(ControlPointTypeId);

-- Unit
ALTER TABLE QCControlPoints
ADD CONSTRAINT FK_QCControlPoints_Units 
FOREIGN KEY (UnitId) REFERENCES Units(UnitId);
```

**Why CASCADE DELETE?**
```sql
ON DELETE CASCADE
```
- Deleting template automatically deletes all control points
- Maintains referential integrity
- Prevents orphaned control points
- Simplifies deletion logic

### 6.4 Relationship Types

**1:1 (One-to-One)**:
- MasterRegister ↔ MMDs
- MasterRegister ↔ Tools
- MasterRegister ↔ AssetsConsumables
- QCTemplates ↔ Materials (enforced by UNIQUE constraint)

**1:N (One-to-Many)**:
- MasterRegister → Maintenance (one item, many services)
- MasterRegister → Allocation (one item, many allocations)
- ValidationTypes → QCTemplates
- FinalProducts → Materials
- FinalProducts → QCTemplates
- QCTemplates → QCControlPoints
- ControlPointTypes → QCControlPoints

**Why These Relationships?**
- **1:1**: Detailed information in separate tables
- **1:N**: Historical records and multiple associations
- **Foreign Keys**: Enforce referential integrity
- **CASCADE**: Automatic cleanup of related data


---

## 7. Data Flow & Triggers

### 7.1 Maintenance Data Flow

**Flow Diagram**:
```
User Action: Add Maintenance Record
         ↓
Frontend: Sends POST request
         ↓
Backend: Calls sp_AddMaintenance
         ↓
Database: BEGIN TRANSACTION
         ↓
Step 1: INSERT into Maintenance table
         ↓
Step 2: UPDATE MasterRegister.NextServiceDue
         ↓
Step 3: UPDATE specific table (MMDs/Tools)
         ↓
Database: COMMIT TRANSACTION
         ↓
Backend: Returns new MaintenanceId
         ↓
Frontend: Refreshes UI
```

**SQL Flow**:
```sql
-- Step 1: Insert maintenance record
INSERT INTO Maintenance (...) VALUES (...);
DECLARE @NewId INT = SCOPE_IDENTITY();

-- Step 2: Update master register
UPDATE MasterRegister 
SET NextServiceDue = @NextServiceDue
WHERE ItemID = @AssetId;

-- Step 3: Update specific table
IF @AssetType = 'MMD'
    UPDATE MMDs SET NextCalibrationDate = @NextServiceDue WHERE MmdId = @AssetId;
ELSE IF @AssetType = 'Tool'
    UPDATE Tools SET LastAuditDate = @ServiceDate WHERE ToolsId = @AssetId;
```

**Why This Flow?**
- **Transaction**: All updates succeed or fail together
- **Cascading Updates**: Keeps all tables synchronized
- **Single Operation**: User performs one action
- **Data Consistency**: No partial updates

### 7.2 Allocation Data Flow

**Flow Diagram**:
```
User Action: Allocate Asset
         ↓
Frontend: Sends POST request
         ↓
Backend: Calls sp_AddAllocation
         ↓
Database: BEGIN TRANSACTION
         ↓
Step 1: INSERT into Allocation table
         ↓
Step 2: UPDATE MasterRegister.AvailabilityStatus = 'Allocated'
         ↓
Database: COMMIT TRANSACTION
         ↓
Backend: Returns new AllocationId
         ↓
Frontend: Refreshes UI
```

**Return Flow**:
```
User Action: Return Asset
         ↓
Frontend: Sends PUT request
         ↓
Backend: Calls sp_ReturnAllocation
         ↓
Database: BEGIN TRANSACTION
         ↓
Step 1: UPDATE Allocation.ActualReturnDate
         ↓
Step 2: UPDATE Allocation.AvailabilityStatus = 'Returned'
         ↓
Step 3: Check for other active allocations
         ↓
Step 4: IF no other allocations:
        UPDATE MasterRegister.AvailabilityStatus = 'Available'
         ↓
Database: COMMIT TRANSACTION
         ↓
Backend: Returns success
         ↓
Frontend: Refreshes UI
```

**Why Smart Status Update?**
```sql
IF NOT EXISTS (
    SELECT 1 FROM Allocation 
    WHERE AssetId = @AssetId 
      AND ActualReturnDate IS NULL
)
BEGIN
    UPDATE MasterRegister SET AvailabilityStatus = 'Available'
END
```
- Handles multiple allocations correctly
- Only marks Available when truly available
- Prevents premature status change
- Business logic in database

### 7.3 QC Template Creation Flow

**Flow Diagram**:
```
User Action: Create QC Template
         ↓
Frontend: Selects Validation Type, Product, Material
         ↓
Frontend: Auto-generates template name
         ↓
Frontend: Sends POST request
         ↓
Backend: Calls sp_CreateQCTemplate
         ↓
Database: Check for duplicate MaterialId
         ↓
IF duplicate: RAISERROR and RETURN
         ↓
IF unique: INSERT into QCTemplate
         ↓
Database: Returns new QCTemplateId
         ↓
Backend: Returns templateId to frontend
         ↓
Frontend: Navigates to Add Control Points
         ↓
User Action: Add Control Points
         ↓
Frontend: Sends POST requests for each control point
         ↓
Backend: Calls sp_AddQCControlPoint
         ↓
Database: Auto-generates SequenceOrder
         ↓
Database: INSERT into QCControlPoints
         ↓
Backend: Returns success
         ↓
Frontend: Displays control points list
```

**Template Naming Convention**:
```
Format: {ValidationTypeCode} - {ProductName} - {MSICode} - {MaterialName}

Example: IG - Product A - MSI-001 - Steel Grade A
```

**Why This Flow?**
- **Duplicate Prevention**: Checked at database level
- **Auto-Naming**: Consistent naming convention
- **Auto-Sequencing**: Control points ordered automatically
- **Two-Step Process**: Template first, then control points


### 7.4 Optional Triggers

**Trigger for Availability Status Update** (Optional):
```sql
CREATE TRIGGER trg_UpdateAvailabilityStatus
ON Allocation
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update MasterRegister availability status when allocation changes
    UPDATE mr
    SET mr.AvailabilityStatus = CASE 
        WHEN i.ActualReturnDate IS NOT NULL THEN 'Available'
        WHEN i.ActualReturnDate IS NULL AND i.ExpectedReturnDate < GETDATE() THEN 'Overdue'
        WHEN i.ActualReturnDate IS NULL THEN 'Allocated'
        ELSE 'Available'
    END
    FROM MasterRegister mr
    INNER JOIN inserted i ON mr.ItemID = i.AssetId;
END;
```

**Why Use Triggers?**
- **Automatic Updates**: No manual status updates needed
- **Data Consistency**: Status always reflects current state
- **Real-Time**: Updates immediately on allocation changes
- **Centralized Logic**: Business rules in one place

**When NOT to Use Triggers?**
- **Performance**: Can slow down INSERT/UPDATE operations
- **Debugging**: Harder to trace execution
- **Complexity**: Hidden logic can confuse developers
- **Alternative**: Handle in stored procedures (current approach)

**Current Approach (Stored Procedures)**:
- Explicit updates in sp_AddAllocation
- Explicit updates in sp_ReturnAllocation
- More transparent and debuggable
- Better performance control

### 7.5 Computed Columns

**TotalCost in MMDs, Tools, AssetsConsumables**:
```sql
TotalCost AS (Cost + ISNULL(ExtraCharges, 0)) PERSISTED
```

**Why PERSISTED?**
- **Stored Physically**: Calculated once, stored in table
- **Faster Queries**: No recalculation on SELECT
- **Indexable**: Can create indexes on computed column
- **Trade-off**: Uses more storage, faster reads

**Non-Persisted Alternative**:
```sql
TotalCost AS (Cost + ISNULL(ExtraCharges, 0))
```
- Calculated on every SELECT
- No storage overhead
- Cannot be indexed
- Slower for frequent queries

**When to Use PERSISTED?**
- Frequently queried columns
- Complex calculations
- Need to index the column
- Storage is not a concern

---

## 8. SQL Scripts Reference

### 8.1 Table Creation Scripts

**Main Tables**:
- `md/CREATE_TABLES.sql` - Creates Maintenance and Allocation tables
- `md/CREATE_MAINTENANCE_TABLE.sql` - Detailed Maintenance table creation

**Quality Control Tables**:
- `md/create_missing_quality_tables.sql` - Creates QC control point types and units
- `RUN_THIS_IN_SSMS.sql` - Complete QC template setup

**Schema Modifications**:
- `ADD_MATERIALID_TO_TEMPLATE.sql` - Adds MaterialId column to QCTemplate
- `ADD_TOOLS_FIELD_TO_TEMPLATE.sql` - Adds ToolsToQualityCheck column
- `ADD_UNIQUE_MATERIAL_CONSTRAINT.sql` - Adds unique constraint on MaterialId

### 8.2 Stored Procedure Scripts

**Quality Control**:
- `RUN_THIS_IN_SSMS.sql` - Creates sp_CreateQCTemplate
- `FIX_TOOLS_STORED_PROCEDURES.sql` - Updates all QC stored procedures
- `FIX_CONTROL_POINT_TYPE_ID_RETURN.sql` - Fixes sp_GetQCControlPointsByTemplate
- `FIX_CREATE_TEMPLATE.sql` - Fixes template creation procedure

**Maintenance**:
- `fix_next_service_calculation.sql` - Fixes next service date calculation

### 8.3 Data Migration Scripts

**Add Columns**:
```sql
-- Add MaterialId to QCTemplate
ALTER TABLE QCTemplate ADD MaterialId INT NULL;

-- Add ToolsToQualityCheck to QCTemplate
ALTER TABLE QCTemplate ADD ToolsToQualityCheck NVARCHAR(500) NULL;

-- Add NextServiceDue to MasterRegister
ALTER TABLE MasterRegister ADD NextServiceDue DATETIME NULL;

-- Add AvailabilityStatus to MasterRegister
ALTER TABLE MasterRegister ADD AvailabilityStatus NVARCHAR(50) DEFAULT 'Available';
```

**Add Constraints**:
```sql
-- Add unique constraint on MaterialId
ALTER TABLE QCTemplate
ADD CONSTRAINT UQ_QCTemplate_MaterialId UNIQUE (MaterialId);

-- Add check constraint on AssetType
ALTER TABLE AssetsConsumables
ADD CONSTRAINT CHK_AssetType CHECK (AssetType IN ('Asset', 'Consumable'));
```

### 8.4 Testing Scripts

**Test Files**:
- `test_create_template.ps1` - Tests template creation
- `test_tools_field.ps1` - Tests tools field functionality
- `test_unique_material_constraint.ps1` - Tests unique constraint
- `test_pagination_endpoints.ps1` - Tests pagination
- `test_maintenance_allocation_search.ps1` - Tests search functionality

**Sample Test Query**:
```sql
-- Test template creation
DECLARE @NewId INT;
EXEC sp_CreateQCTemplate 
    @TemplateName = 'Test Template',
    @ValidationTypeId = 1,
    @FinalProductId = 1,
    @MaterialId = 1,
    @ToolsToQualityCheck = 'Caliper, Micrometer',
    @NewTemplateId = @NewId OUTPUT;

PRINT 'New Template ID: ' + CAST(@NewId AS VARCHAR(10));

-- Verify creation
SELECT * FROM QCTemplate WHERE QCTemplateId = @NewId;
```

### 8.5 Maintenance Scripts

**Backup Script**:
```sql
-- Full database backup
BACKUP DATABASE ManufacturingApp
TO DISK = 'C:\Backups\ManufacturingApp_Full.bak'
WITH FORMAT, INIT, NAME = 'Full Backup of ManufacturingApp';
```

**Index Maintenance**:
```sql
-- Rebuild all indexes
ALTER INDEX ALL ON MasterRegister REBUILD;
ALTER INDEX ALL ON MMDs REBUILD;
ALTER INDEX ALL ON Tools REBUILD;
ALTER INDEX ALL ON AssetsConsumables REBUILD;
ALTER INDEX ALL ON Maintenance REBUILD;
ALTER INDEX ALL ON Allocation REBUILD;
ALTER INDEX ALL ON QCTemplate REBUILD;
ALTER INDEX ALL ON QCControlPoint REBUILD;
```

**Update Statistics**:
```sql
-- Update statistics for all tables
UPDATE STATISTICS MasterRegister;
UPDATE STATISTICS MMDs;
UPDATE STATISTICS Tools;
UPDATE STATISTICS AssetsConsumables;
UPDATE STATISTICS Maintenance;
UPDATE STATISTICS Allocation;
UPDATE STATISTICS QCTemplate;
UPDATE STATISTICS QCControlPoint;
```


---

## 9. Database Maintenance

### 9.1 Backup Strategy

**Full Backup (Weekly)**:
```sql
BACKUP DATABASE ManufacturingApp
TO DISK = 'C:\Backups\ManufacturingApp_Full_' + 
    CONVERT(VARCHAR(8), GETDATE(), 112) + '.bak'
WITH FORMAT, INIT, 
    NAME = 'Full Backup of ManufacturingApp',
    COMPRESSION;
```

**Why Weekly Full Backup?**
- Complete database snapshot
- Recovery point for disasters
- Baseline for differential backups
- Compressed to save space

**Differential Backup (Daily)**:
```sql
BACKUP DATABASE ManufacturingApp
TO DISK = 'C:\Backups\ManufacturingApp_Diff_' + 
    CONVERT(VARCHAR(8), GETDATE(), 112) + '.bak'
WITH DIFFERENTIAL, 
    NAME = 'Differential Backup of ManufacturingApp',
    COMPRESSION;
```

**Why Daily Differential?**
- Faster than full backup
- Only backs up changes since last full
- Quicker restore process
- Balances backup time and recovery time

**Transaction Log Backup (Hourly)**:
```sql
BACKUP LOG ManufacturingApp
TO DISK = 'C:\Backups\ManufacturingApp_Log_' + 
    CONVERT(VARCHAR(14), GETDATE(), 112) + '.trn'
WITH NAME = 'Log Backup of ManufacturingApp',
    COMPRESSION;
```

**Why Hourly Log Backup?**
- Point-in-time recovery
- Minimal data loss (max 1 hour)
- Keeps transaction log size manageable
- Required for full recovery model

**Backup Schedule**:
```
Sunday    00:00 - Full Backup
Monday    00:00 - Differential Backup
Tuesday   00:00 - Differential Backup
Wednesday 00:00 - Differential Backup
Thursday  00:00 - Differential Backup
Friday    00:00 - Differential Backup
Saturday  00:00 - Differential Backup

Every Hour - Transaction Log Backup
```

### 9.2 Index Maintenance

**Rebuild Indexes (Monthly)**:
```sql
-- Rebuild all indexes with online option
ALTER INDEX ALL ON MasterRegister REBUILD WITH (ONLINE = ON);
ALTER INDEX ALL ON MMDs REBUILD WITH (ONLINE = ON);
ALTER INDEX ALL ON Tools REBUILD WITH (ONLINE = ON);
ALTER INDEX ALL ON AssetsConsumables REBUILD WITH (ONLINE = ON);
ALTER INDEX ALL ON Maintenance REBUILD WITH (ONLINE = ON);
ALTER INDEX ALL ON Allocation REBUILD WITH (ONLINE = ON);
ALTER INDEX ALL ON QCTemplate REBUILD WITH (ONLINE = ON);
ALTER INDEX ALL ON QCControlPoint REBUILD WITH (ONLINE = ON);
```

**Why Rebuild Indexes?**
- Removes fragmentation
- Improves query performance
- Reclaims unused space
- Updates statistics

**Reorganize Indexes (Weekly)**:
```sql
-- Reorganize indexes (less intensive than rebuild)
ALTER INDEX ALL ON MasterRegister REORGANIZE;
ALTER INDEX ALL ON MMDs REORGANIZE;
-- ... repeat for all tables
```

**Why Reorganize?**
- Less resource-intensive than rebuild
- Can run during business hours
- Defragments leaf level
- Good for moderate fragmentation

**Check Index Fragmentation**:
```sql
SELECT 
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(
    DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id 
    AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 10
    AND ips.page_count > 1000
ORDER BY ips.avg_fragmentation_in_percent DESC;
```

**Fragmentation Guidelines**:
- **< 10%**: No action needed
- **10-30%**: REORGANIZE
- **> 30%**: REBUILD

### 9.3 Statistics Maintenance

**Update Statistics (Weekly)**:
```sql
-- Update statistics with full scan
UPDATE STATISTICS MasterRegister WITH FULLSCAN;
UPDATE STATISTICS MMDs WITH FULLSCAN;
UPDATE STATISTICS Tools WITH FULLSCAN;
UPDATE STATISTICS AssetsConsumables WITH FULLSCAN;
UPDATE STATISTICS Maintenance WITH FULLSCAN;
UPDATE STATISTICS Allocation WITH FULLSCAN;
UPDATE STATISTICS QCTemplate WITH FULLSCAN;
UPDATE STATISTICS QCControlPoint WITH FULLSCAN;
```

**Why Update Statistics?**
- Query optimizer uses statistics
- Outdated statistics = poor query plans
- Improves query performance
- Especially important after bulk operations

**Auto Update Statistics**:
```sql
-- Enable auto update statistics (should be enabled by default)
ALTER DATABASE ManufacturingApp SET AUTO_UPDATE_STATISTICS ON;
ALTER DATABASE ManufacturingApp SET AUTO_UPDATE_STATISTICS_ASYNC ON;
```

### 9.4 Database Integrity Checks

**DBCC CHECKDB (Weekly)**:
```sql
-- Check database integrity
DBCC CHECKDB (ManufacturingApp) WITH NO_INFOMSGS;
```

**Why DBCC CHECKDB?**
- Detects corruption
- Validates data integrity
- Checks allocation structures
- Prevents data loss

**DBCC CHECKTABLE (As Needed)**:
```sql
-- Check specific table
DBCC CHECKTABLE (MasterRegister) WITH NO_INFOMSGS;
```

### 9.5 Space Management

**Check Database Size**:
```sql
SELECT 
    name AS DatabaseName,
    size * 8 / 1024 AS SizeMB,
    max_size * 8 / 1024 AS MaxSizeMB
FROM sys.database_files;
```

**Check Table Sizes**:
```sql
SELECT 
    t.name AS TableName,
    SUM(p.rows) AS RowCount,
    SUM(a.total_pages) * 8 / 1024 AS TotalSpaceMB,
    SUM(a.used_pages) * 8 / 1024 AS UsedSpaceMB,
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 / 1024 AS UnusedSpaceMB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
GROUP BY t.name
ORDER BY TotalSpaceMB DESC;
```

**Shrink Database (Use Sparingly)**:
```sql
-- Shrink database (only if necessary)
DBCC SHRINKDATABASE (ManufacturingApp, 10);
```

**Why Avoid Shrinking?**
- Causes index fragmentation
- Impacts performance
- Database will grow again
- Only use after large data deletion

### 9.6 Performance Monitoring

**Check Long-Running Queries**:
```sql
SELECT 
    r.session_id,
    r.start_time,
    r.status,
    r.command,
    r.cpu_time,
    r.total_elapsed_time / 1000 AS elapsed_seconds,
    t.text AS query_text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.session_id > 50
ORDER BY r.total_elapsed_time DESC;
```

**Check Blocking**:
```sql
SELECT 
    blocking_session_id,
    session_id,
    wait_type,
    wait_time,
    wait_resource
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;
```

**Check Index Usage**:
```sql
SELECT 
    OBJECT_NAME(s.object_id) AS TableName,
    i.name AS IndexName,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i ON s.object_id = i.object_id 
    AND s.index_id = i.index_id
WHERE OBJECTPROPERTY(s.object_id, 'IsUserTable') = 1
ORDER BY s.user_seeks + s.user_scans + s.user_lookups DESC;
```

**Why Monitor Index Usage?**
- Identify unused indexes
- Remove unnecessary indexes
- Improve write performance
- Reduce storage overhead


---

## 10. Best Practices

### 10.1 Database Design Best Practices

**1. Normalization**
- **3rd Normal Form (3NF)**: Most tables follow 3NF
- **Denormalization**: Strategic denormalization for performance (ItemName in Maintenance/Allocation)
- **Balance**: Trade-off between normalization and query performance

**Example of Denormalization**:
```sql
-- Maintenance table includes ItemName (denormalized)
-- Avoids JOIN with MasterRegister for every query
CREATE TABLE Maintenance (
    MaintenanceId INT PRIMARY KEY,
    AssetId NVARCHAR(50),
    ItemName NVARCHAR(255),  -- Denormalized from MasterRegister
    ...
);
```

**Why?**
- Faster queries (no JOIN needed)
- Better read performance
- Trade-off: Data redundancy, update complexity

**2. Primary Keys**
- **Always use PRIMARY KEY**: Every table has one
- **Clustered Index**: Primary key creates clustered index
- **Identity Columns**: Use IDENTITY for auto-increment
- **Natural vs Surrogate**: Use surrogate keys (INT IDENTITY) for most tables

**3. Foreign Keys**
- **Always define FK constraints**: Enforces referential integrity
- **Cascade Options**: Use CASCADE DELETE where appropriate
- **Naming Convention**: FK_{ChildTable}_{ParentTable}

**4. Indexes**
- **Index Frequently Queried Columns**: WHERE, JOIN, ORDER BY columns
- **Don't Over-Index**: Each index slows down writes
- **Include Columns**: Use INCLUDE for covering indexes
- **Monitor Usage**: Remove unused indexes

**5. Data Types**
- **Use Appropriate Types**: Don't use NVARCHAR(MAX) for short strings
- **NVARCHAR vs VARCHAR**: Use NVARCHAR for Unicode support
- **DECIMAL for Money**: Use DECIMAL(18,2) for currency
- **DATETIME vs DATE**: Use DATE if time not needed

### 10.2 Query Optimization Best Practices

**1. Use Stored Procedures**
```sql
-- Good: Stored procedure
EXEC sp_GetMasterListPaginated @PageNumber = 1, @PageSize = 10;

-- Avoid: Dynamic SQL from application
SELECT * FROM MasterRegister WHERE ItemName LIKE '%' + @Search + '%';
```

**Why Stored Procedures?**
- Precompiled execution plans
- Reduced network traffic
- Better security
- Centralized logic

**2. Avoid SELECT ***
```sql
-- Bad
SELECT * FROM MasterRegister;

-- Good
SELECT ItemID, ItemName, ItemType, Status FROM MasterRegister;
```

**Why?**
- Reduces data transfer
- Faster queries
- Less memory usage
- More maintainable

**3. Use WHERE Clauses**
```sql
-- Bad: Returns all rows
SELECT * FROM Maintenance;

-- Good: Filters at database
SELECT * FROM Maintenance WHERE ServiceDate >= '2024-01-01';
```

**4. Use Indexes Effectively**
```sql
-- Good: Uses index on ItemType
SELECT * FROM MasterRegister WHERE ItemType = 'MMD';

-- Bad: Function prevents index usage
SELECT * FROM MasterRegister WHERE UPPER(ItemType) = 'MMD';
```

**5. Avoid Cursors**
```sql
-- Bad: Cursor (row-by-row processing)
DECLARE cursor_name CURSOR FOR SELECT * FROM Items;

-- Good: Set-based operation
UPDATE Items SET Status = 1 WHERE CreatedDate < '2024-01-01';
```

**Why Avoid Cursors?**
- Slow performance
- High resource usage
- Set-based operations are faster
- SQL Server optimized for sets

### 10.3 Security Best Practices

**1. Use Parameterized Queries**
```sql
-- Bad: SQL Injection risk
DECLARE @SQL NVARCHAR(MAX) = 'SELECT * FROM Items WHERE ItemName = ''' + @Name + '''';
EXEC(@SQL);

-- Good: Parameterized
DECLARE @SQL NVARCHAR(MAX) = 'SELECT * FROM Items WHERE ItemName = @Name';
EXEC sp_executesql @SQL, N'@Name NVARCHAR(200)', @Name = @Name;
```

**2. Principle of Least Privilege**
```sql
-- Create application user with limited permissions
CREATE USER AppUser FOR LOGIN AppLogin;

-- Grant only necessary permissions
GRANT EXECUTE ON sp_GetMasterListPaginated TO AppUser;
GRANT EXECUTE ON sp_CreateQCTemplate TO AppUser;

-- Don't grant direct table access
-- DENY SELECT, INSERT, UPDATE, DELETE ON MasterRegister TO AppUser;
```

**3. Encrypt Sensitive Data**
```sql
-- Use Always Encrypted or TDE for sensitive data
-- Example: Encrypt employee personal information
ALTER TABLE Employees
ADD EncryptedSSN VARBINARY(MAX);
```

**4. Audit Trail**
```sql
-- Add audit columns to important tables
ALTER TABLE QCTemplate ADD CreatedBy NVARCHAR(100);
ALTER TABLE QCTemplate ADD CreatedDate DATETIME DEFAULT GETDATE();
ALTER TABLE QCTemplate ADD ModifiedBy NVARCHAR(100);
ALTER TABLE QCTemplate ADD ModifiedDate DATETIME;
```

### 10.4 Transaction Best Practices

**1. Keep Transactions Short**
```sql
-- Good: Short transaction
BEGIN TRANSACTION;
    INSERT INTO Maintenance (...) VALUES (...);
    UPDATE MasterRegister SET NextServiceDue = @Date WHERE ItemID = @Id;
COMMIT TRANSACTION;

-- Bad: Long transaction with user interaction
BEGIN TRANSACTION;
    INSERT INTO Maintenance (...) VALUES (...);
    -- Wait for user input (BAD!)
    UPDATE MasterRegister SET NextServiceDue = @Date WHERE ItemID = @Id;
COMMIT TRANSACTION;
```

**Why?**
- Reduces locking
- Improves concurrency
- Prevents deadlocks
- Better performance

**2. Use Appropriate Isolation Level**
```sql
-- Default: READ COMMITTED
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- For reports: READ UNCOMMITTED (dirty reads allowed)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM MasterRegister;

-- For critical operations: SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
    -- Critical operations
COMMIT TRANSACTION;
```

**3. Handle Deadlocks**
```sql
BEGIN TRY
    BEGIN TRANSACTION;
        -- Operations
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    IF ERROR_NUMBER() = 1205  -- Deadlock
    BEGIN
        -- Retry logic or log error
        PRINT 'Deadlock detected. Please retry.';
    END
    ELSE
    BEGIN
        -- Other errors
        THROW;
    END
END CATCH;
```

### 10.5 Naming Conventions

**Tables**:
- PascalCase
- Singular or plural (be consistent)
- Descriptive names
- Examples: `MasterRegister`, `QCTemplate`, `Maintenance`

**Columns**:
- PascalCase
- Descriptive names
- Avoid abbreviations (unless common)
- Examples: `ItemID`, `ItemName`, `NextServiceDue`

**Stored Procedures**:
- Prefix: `sp_`
- Action verb + Entity
- Examples: `sp_GetAllItems`, `sp_CreateTemplate`, `sp_UpdateMaintenance`

**Indexes**:
- Prefix: `IX_` for non-clustered, `PK_` for primary key
- Format: `IX_{TableName}_{ColumnName}`
- Examples: `IX_MasterRegister_ItemType`, `PK_Maintenance`

**Foreign Keys**:
- Prefix: `FK_`
- Format: `FK_{ChildTable}_{ParentTable}`
- Examples: `FK_MMDs_MasterRegister`, `FK_QCControlPoints_QCTemplates`

**Constraints**:
- Prefix: `CHK_` for check, `UQ_` for unique, `DF_` for default
- Format: `{Prefix}_{TableName}_{ColumnName}`
- Examples: `CHK_AssetType`, `UQ_QCTemplate_MaterialId`, `DF_Status`


---

## 11. Conclusion

### 11.1 Database Summary

The ManufacturingApp database is a comprehensive inventory management system with the following characteristics:

**Core Components**:
- **13 Tables**: MasterRegister, MMDs, Tools, AssetsConsumables, Maintenance, Allocation, ValidationTypes, FinalProducts, Materials, ControlPointTypes, Units, QCTemplates, QCControlPoints
- **16 Stored Procedures**: Complete CRUD operations for all entities
- **Multiple Indexes**: Optimized for query performance
- **Foreign Key Constraints**: Enforced referential integrity
- **Unique Constraints**: Business rule enforcement

**Key Features**:
1. **Central Registry Pattern**: MasterRegister as single source of truth
2. **Type Discrimination**: ItemType field determines specific table
3. **Cascading Updates**: Automatic synchronization across tables
4. **Pagination Support**: Efficient handling of large datasets
5. **Search & Sort**: Flexible querying capabilities
6. **Duplicate Prevention**: Unique constraints on critical fields
7. **Transaction Safety**: ACID compliance for data integrity
8. **Audit Trail**: CreatedDate fields for tracking

**Design Patterns**:
- **Layered Architecture**: Clear separation of concerns
- **Stored Procedure Layer**: Business logic in database
- **Denormalization**: Strategic for performance
- **Soft Delete**: Status field instead of hard delete
- **Computed Columns**: Automatic calculations

### 11.2 Key Takeaways

**For Developers**:
1. **Always use stored procedures** for database operations
2. **Never bypass foreign key constraints** - they ensure data integrity
3. **Use transactions** for multi-table updates
4. **Handle errors properly** with TRY-CATCH blocks
5. **Test with realistic data volumes** to ensure performance

**For Database Administrators**:
1. **Regular backups** are critical (Full weekly, Differential daily, Log hourly)
2. **Monitor index fragmentation** and rebuild/reorganize as needed
3. **Update statistics** regularly for optimal query plans
4. **Check database integrity** with DBCC CHECKDB weekly
5. **Monitor performance** with DMVs and execution plans

**For Business Users**:
1. **One template per material** - enforced by unique constraint
2. **Maintenance updates Next Service Due** automatically
3. **Allocation updates Availability Status** automatically
4. **Search works across multiple columns** for convenience
5. **Pagination handles large datasets** efficiently

### 11.3 Common Scenarios

**Scenario 1: Add New MMD with Maintenance**
```sql
-- Step 1: Add to MasterRegister
INSERT INTO MasterRegister (ItemID, ItemType, ItemName, ...) 
VALUES ('MMD003', 'MMD', 'Torque Wrench', ...);

-- Step 2: Add MMD details
INSERT INTO MMDs (MmdId, MmdName, CalibrationFrequency, ...) 
VALUES ('MMD003', 'Torque Wrench', 'Yearly', ...);

-- Step 3: Add maintenance record
EXEC sp_AddMaintenance 
    @AssetType = 'MMD',
    @AssetId = 'MMD003',
    @ServiceDate = '2024-03-20',
    @NextServiceDue = '2025-03-20',
    ...;
```

**Scenario 2: Create QC Template with Control Points**
```sql
-- Step 1: Create template
DECLARE @TemplateId INT;
EXEC sp_CreateQCTemplate 
    @TemplateName = 'IG - Product A - MSI-001 - Steel Grade A',
    @ValidationTypeId = 1,
    @FinalProductId = 1,
    @MaterialId = 1,
    @ToolsToQualityCheck = 'Caliper, Micrometer',
    @NewTemplateId = @TemplateId OUTPUT;

-- Step 2: Add control points
EXEC sp_AddQCControlPoint 
    @QCTemplateId = @TemplateId,
    @ControlPointTypeId = 1,
    @ControlPointName = 'Length Measurement',
    @TargetValue = '100',
    @Unit = 'mm',
    @Tolerance = '±0.5';

EXEC sp_AddQCControlPoint 
    @QCTemplateId = @TemplateId,
    @ControlPointTypeId = 2,
    @ControlPointName = 'Visual Inspection',
    @TargetValue = 'No defects';
```

**Scenario 3: Allocate and Return Asset**
```sql
-- Step 1: Allocate asset
DECLARE @AllocationId INT;
EXEC sp_AddAllocation 
    @AssetType = 'Asset',
    @AssetId = 'ASSET001',
    @EmployeeId = 'EMP002',
    @EmployeeName = 'Jane Smith',
    @IssuedDate = '2024-01-01',
    @ExpectedReturnDate = '2024-12-31',
    @AvailabilityStatus = 'Allocated';

-- Step 2: Return asset
EXEC sp_ReturnAllocation 
    @AllocationId = @AllocationId,
    @ActualReturnDate = '2024-06-15';
```

### 11.4 Troubleshooting Guide

**Problem: Template creation fails with "already exists" error**
```sql
-- Solution: Check existing templates for material
SELECT * FROM QCTemplate WHERE MaterialId = 1;

-- If duplicate, either:
-- 1. Use existing template
-- 2. Delete old template (if appropriate)
DELETE FROM QCTemplate WHERE QCTemplateId = 1;
```

**Problem: Maintenance not updating Next Service Due**
```sql
-- Solution: Check if stored procedure is being used
-- Verify transaction completed successfully
SELECT NextServiceDue FROM MasterRegister WHERE ItemID = 'MMD001';

-- Manual update if needed
UPDATE MasterRegister SET NextServiceDue = '2024-12-01' WHERE ItemID = 'MMD001';
UPDATE MMDs SET NextCalibrationDate = '2024-12-01' WHERE MmdId = 'MMD001';
```

**Problem: Slow query performance**
```sql
-- Solution 1: Check index fragmentation
SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED')
WHERE avg_fragmentation_in_percent > 30;

-- Solution 2: Update statistics
UPDATE STATISTICS MasterRegister WITH FULLSCAN;

-- Solution 3: Check execution plan
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- Run your query
```

**Problem: Foreign key constraint violation**
```sql
-- Solution: Verify parent record exists
SELECT * FROM MasterRegister WHERE ItemID = 'MMD001';

-- If not exists, create parent first
INSERT INTO MasterRegister (ItemID, ItemType, ItemName, ...) 
VALUES ('MMD001', 'MMD', 'Vernier Caliper', ...);
```

### 11.5 Future Enhancements

**Potential Improvements**:
1. **Audit Tables**: Track all changes with who/when/what
2. **Soft Delete**: Add IsDeleted column instead of hard delete
3. **Versioning**: Track template versions
4. **Notifications**: Trigger-based email notifications for overdue services
5. **Reporting Tables**: Denormalized tables for faster reporting
6. **Partitioning**: Partition large tables by date for better performance
7. **Compression**: Enable data compression for older records
8. **Full-Text Search**: Enable full-text indexing for better search

**Scalability Considerations**:
- **Read Replicas**: For reporting workloads
- **Archiving**: Move old records to archive tables
- **Caching**: Implement application-level caching
- **Connection Pooling**: Optimize database connections

### 11.6 Related Documentation

**See Also**:
- **FRONTEND_COMPREHENSIVE_DOCUMENTATION.md** - Flutter frontend documentation
- **BACKEND_COMPREHENSIVE_DOCUMENTATION.md** - ASP.NET Core backend documentation
- **DATABASE_STORED_PROCEDURES.md** - Detailed stored procedure documentation
- **PAGINATION_IMPLEMENTATION_SUMMARY.md** - Pagination implementation details
- **QC_TEMPLATE_USER_GUIDE_NEW_FLOW.md** - QC template user guide

### 11.7 Contact & Support

**For Database Issues**:
- Check error logs in SQL Server Management Studio
- Review execution plans for slow queries
- Verify foreign key constraints
- Check transaction logs for failures

**For Development Questions**:
- Review stored procedure documentation
- Check table schemas and relationships
- Verify data types and constraints
- Test with sample data

---

## Appendix A: Quick Reference

### Connection String
```
Server=RISHIVASAN-PC;Database=ManufacturingApp;User Id=sa;Password=****;TrustServerCertificate=True;
```

### Common Queries

**Get All Active Items**:
```sql
SELECT * FROM MasterRegister WHERE Status = 1;
```

**Get Upcoming Services (Next 30 Days)**:
```sql
SELECT * FROM MasterRegister 
WHERE NextServiceDue BETWEEN GETDATE() AND DATEADD(DAY, 30, GETDATE())
ORDER BY NextServiceDue;
```

**Get Available Assets**:
```sql
SELECT * FROM MasterRegister 
WHERE AvailabilityStatus = 'Available' AND Status = 1;
```

**Get Templates by Product**:
```sql
SELECT t.*, fp.ProductName, m.MaterialName
FROM QCTemplate t
INNER JOIN FinalProduct fp ON t.FinalProductId = fp.FinalProductId
INNER JOIN Material m ON t.MaterialId = m.MaterialId
WHERE t.FinalProductId = 1;
```

**Get Maintenance History**:
```sql
SELECT * FROM Maintenance 
WHERE AssetId = 'MMD001' 
ORDER BY ServiceDate DESC;
```

### Common Stored Procedure Calls

```sql
-- Get paginated master list
EXEC sp_GetMasterListPaginated @PageNumber = 1, @PageSize = 10;

-- Create QC template
DECLARE @NewId INT;
EXEC sp_CreateQCTemplate 
    @TemplateName = 'Template Name',
    @ValidationTypeId = 1,
    @FinalProductId = 1,
    @MaterialId = 1,
    @NewTemplateId = @NewId OUTPUT;

-- Add maintenance
EXEC sp_AddMaintenance 
    @AssetType = 'MMD',
    @AssetId = 'MMD001',
    @ServiceDate = '2024-04-06',
    @NextServiceDue = '2024-12-01',
    ...;

-- Add allocation
EXEC sp_AddAllocation 
    @AssetType = 'Asset',
    @AssetId = 'ASSET001',
    @EmployeeId = 'EMP002',
    @IssuedDate = '2024-01-01',
    @ExpectedReturnDate = '2024-12-31',
    ...;
```

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Database Version**: SQL Server 2019+  
**Application**: Inventory Management System  

**End of Database Comprehensive Documentation**

