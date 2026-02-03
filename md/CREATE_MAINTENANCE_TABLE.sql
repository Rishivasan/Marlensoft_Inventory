-- Create Maintenance Table for tracking service records and next due dates
-- This table will store maintenance records and automatically update the master list next service due dates

CREATE TABLE Maintenance (
    MaintenanceId INT IDENTITY(1,1) PRIMARY KEY,
    AssetType NVARCHAR(50) NOT NULL,
    AssetId NVARCHAR(50) NOT NULL,
    ItemName NVARCHAR(255),
    ServiceDate DATETIME,
    ServiceProviderCompany NVARCHAR(255),
    ServiceEngineerName NVARCHAR(255),
    ServiceType NVARCHAR(100),
    NextServiceDue DATETIME,  -- This field will be used to update master list
    ServiceNotes NVARCHAR(MAX),
    MaintenanceStatus NVARCHAR(50) DEFAULT 'Completed',
    Cost DECIMAL(18,2) DEFAULT 0,
    ResponsibleTeam NVARCHAR(255),
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- Create index for faster lookups by AssetId
CREATE INDEX IX_Maintenance_AssetId ON Maintenance(AssetId);
CREATE INDEX IX_Maintenance_ServiceDate ON Maintenance(ServiceDate DESC);
CREATE INDEX IX_Maintenance_NextServiceDue ON Maintenance(NextServiceDue);

-- Insert sample maintenance records to test the next service due functionality
INSERT INTO Maintenance (AssetType, AssetId, ItemName, ServiceDate, ServiceProviderCompany, ServiceEngineerName, ServiceType, NextServiceDue, ServiceNotes, MaintenanceStatus, Cost, ResponsibleTeam)
VALUES 
-- Sample for MMD001 (Mitutoyo caliper)
('MMD', 'MMD001', 'MIT-500', '2024-06-15', 'Mitutoyo Service Center', 'John Smith', 'Calibration', '2025-06-15', 'Annual calibration completed successfully', 'Completed', 500.00, 'Production Team A'),

-- Sample for TL5001 (Vernier Caliper)
('Tool', 'TL5001', 'VERNIERCALIBER', '2024-08-20', 'ABC Calibration Lab', 'Ravi Kumar', 'Calibration', '2025-02-20', 'Calibration and maintenance completed', 'Completed', 300.00, 'HARIRAJA'),

-- Sample for MMD002 (WIKA pressure gauge)
('MMD', 'MMD002', 'WIKA-10B', '2024-09-10', 'WIKA Service', 'David Wilson', 'Calibration', '2025-03-10', 'Pressure calibration completed', 'Completed', 450.00, 'Production'),

-- Sample for TL892 (Tool with upcoming service)
('Tool', 'TL892', 'jvnfjv', '2024-10-01', 'Local Service Provider', 'Mike Johnson', 'Preventive Maintenance', '2025-04-01', 'Regular maintenance completed', 'Completed', 200.00, 'vjv'),

-- Sample for MMD003 (Norbar torque wrench)
('MMD', 'MMD003', 'NOR-200', '2024-11-15', 'Norbar Service Center', 'Sarah Lee', 'Calibration', '2025-05-15', 'Torque calibration completed', 'Completed', 600.00, 'Assembly');

-- Verify the data was inserted
SELECT 
    AssetId, 
    ItemName, 
    ServiceDate, 
    NextServiceDue, 
    ServiceType,
    MaintenanceStatus
FROM Maintenance 
ORDER BY ServiceDate DESC;

PRINT 'Maintenance table created successfully with sample data!';
PRINT 'The enhanced master list API will now show real next service due dates.';