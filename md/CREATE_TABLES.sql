-- Create Maintenance table
CREATE TABLE Maintenance (
    MaintenanceId INT IDENTITY(1,1) PRIMARY KEY,
    AssetType NVARCHAR(50) NULL,
    AssetId NVARCHAR(50) NULL,
    ItemName NVARCHAR(100) NULL,
    ServiceDate DATETIME NULL,
    ServiceProviderCompany NVARCHAR(100) NULL,
    ServiceEngineerName NVARCHAR(100) NULL,
    ServiceType NVARCHAR(50) NULL,
    NextServiceDue DATETIME NULL,
    ServiceNotes NVARCHAR(500) NULL,
    MaintenanceStatus NVARCHAR(50) NULL,
    Cost DECIMAL(10,2) NULL,
    ResponsibleTeam NVARCHAR(100) NULL,
    CreatedDate DATETIME NULL
);

-- Create Allocation table
CREATE TABLE Allocation (
    AllocationId INT IDENTITY(1,1) PRIMARY KEY,
    AssetType NVARCHAR(50) NULL,
    AssetId NVARCHAR(50) NULL,
    ItemName NVARCHAR(100) NULL,
    EmployeeId NVARCHAR(50) NULL,
    EmployeeName NVARCHAR(100) NULL,
    TeamName NVARCHAR(100) NULL,
    Purpose NVARCHAR(200) NULL,
    IssuedDate DATETIME NULL,
    ExpectedReturnDate DATETIME NULL,
    ActualReturnDate DATETIME NULL,
    AvailabilityStatus NVARCHAR(50) NULL,
    CreatedDate DATETIME NULL
);

-- Insert sample maintenance data based on your database screenshot
INSERT INTO Maintenance (AssetType, AssetId, ItemName, ServiceDate, ServiceProviderCompany, ServiceEngineerName, ServiceType, NextServiceDue, ServiceNotes, MaintenanceStatus, Cost, ResponsibleTeam, CreatedDate)
VALUES 
('MMD', 'MMD001', 'Venter Caliper', '2024-04-06', 'ABC Calibration Lab', 'Ravi', 'Calibration', '2024-12-01', 'Calibration completed', 'Completed', 0, 'Production Team', GETDATE()),
('ASSET', 'AST001', 'Dell Service', '2024-05-10', 'Dell Service', 'Kumar', 'Preventive', '2025-05-10', 'Preventive maintenance', 'Completed', 0, 'IT Team', GETDATE()),
('CONSUMABLE', 'CON001', 'M4 Paper', '2024-04-15', 'Internal Store', 'N/A', 'Stock replenishment', '2024-05-15', 'Stock replenished', 'Completed', 0, 'Store Team', GETDATE());

-- Insert sample allocation data
INSERT INTO Allocation (AssetType, AssetId, ItemName, EmployeeId, EmployeeName, TeamName, Purpose, IssuedDate, ExpectedReturnDate, ActualReturnDate, AvailabilityStatus, CreatedDate)
VALUES 
('MMD', 'MMD001', 'Venter Caliper', 'EMP001', 'John Doe', 'Quality Team', 'Calibration work', '2024-01-15', '2024-01-30', '2024-01-28', 'Available', GETDATE()),
('ASSET', 'AST001', 'Dell Laptop', 'EMP002', 'Jane Smith', 'Development Team', 'Software development', '2024-01-01', '2024-12-31', NULL, 'Allocated', GETDATE()),
('CONSUMABLE', 'CON001', 'M4 Paper', 'EMP003', 'Mike Johnson', 'Documentation Team', 'Report printing', '2024-01-20', '2024-01-25', '2024-01-24', 'Available', GETDATE());

PRINT 'Tables created and sample data inserted successfully!';