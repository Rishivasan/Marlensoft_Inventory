# Allocation Table & Maintenance Data Fix

## Issues Fixed

### 1. ✅ **Allocation Table Not Showing**
**Problem**: The "Usage & allocation management" tab was empty, showing only placeholder text.

**Solution**: 
- Created `AllocationModel` to match backend `AllocationEntity`
- Created `AllocationController.cs` for backend API endpoints
- Added `getAllocationsByAssetId()` method to API service
- Implemented complete allocation table with real data structure

**Features Added**:
- Employee ID, Name, Team columns
- Purpose, Issued Date, Expected/Actual Return dates
- Status badges with color coding (Allocated, Returned, Overdue, Available)
- Search functionality
- "Add new allocation" button
- Pagination controls
- Loading states and empty state handling

### 2. ✅ **Maintenance Table Showing Dummy Data**
**Problem**: Maintenance table was showing hardcoded sample data instead of real data from the database.

**Solution**:
- Removed `_getSampleMaintenanceData()` method that generated dummy data
- Updated `_loadMaintenanceData()` to only show real data from API
- Added proper empty state when no maintenance records exist
- Shows "No maintenance records found" instead of dummy data

**Before**: Always showed 3 hardcoded maintenance records
**After**: Shows real maintenance data from `/api/maintenance/{assetId}` or empty state

## Backend Controllers Created

### 1. MaintenanceController.cs
```csharp
GET /api/maintenance           // Get all maintenance records
GET /api/maintenance/{assetId} // Get maintenance for specific asset
POST /api/maintenance          // Create new maintenance record
PUT /api/maintenance/{id}      // Update maintenance record
DELETE /api/maintenance/{id}   // Delete maintenance record
```

### 2. AllocationController.cs
```csharp
GET /api/allocation           // Get all allocation records
GET /api/allocation/{assetId} // Get allocations for specific asset
POST /api/allocation          // Create new allocation record
PUT /api/allocation/{id}      // Update allocation record
DELETE /api/allocation/{id}   // Delete allocation record
```

## Data Models Created

### 1. AllocationModel (Flutter)
- Maps to backend `AllocationEntity`
- Handles employee assignments, dates, and status
- Proper JSON serialization/deserialization

### 2. MaintenanceModel (Flutter)
- Already existed, now properly used without dummy data fallback

## Current Behavior

### **Maintenance Tab**:
- ✅ Loads real maintenance data from API
- ✅ Shows loading indicator while fetching
- ✅ Shows "No maintenance records found" when empty
- ✅ No more dummy/sample data

### **Allocation Tab**:
- ✅ Loads real allocation data from API
- ✅ Complete table with all relevant columns
- ✅ Color-coded status badges
- ✅ Search and add functionality
- ✅ Proper pagination
- ✅ Shows "No allocation records found" when empty

## Next Steps

### 1. Database Setup
Ensure these tables exist in your database:
```sql
-- Maintenance table (if not exists)
CREATE TABLE Maintenance (
    MaintenanceId INT IDENTITY(1,1) PRIMARY KEY,
    AssetType NVARCHAR(50),
    AssetId NVARCHAR(50),
    ItemName NVARCHAR(100),
    ServiceDate DATETIME,
    ServiceProviderCompany NVARCHAR(100),
    ServiceEngineerName NVARCHAR(100),
    ServiceType NVARCHAR(50),
    NextServiceDue DATETIME,
    ServiceNotes NVARCHAR(500),
    MaintenanceStatus NVARCHAR(50),
    Cost DECIMAL(10,2),
    ResponsibleTeam NVARCHAR(100),
    CreatedDate DATETIME
);

-- Allocation table (if not exists)
CREATE TABLE Allocation (
    AllocationId INT IDENTITY(1,1) PRIMARY KEY,
    AssetType NVARCHAR(50),
    AssetId NVARCHAR(50),
    ItemName NVARCHAR(100),
    EmployeeId NVARCHAR(50),
    EmployeeName NVARCHAR(100),
    TeamName NVARCHAR(100),
    Purpose NVARCHAR(200),
    IssuedDate DATETIME,
    ExpectedReturnDate DATETIME,
    ActualReturnDate DATETIME,
    AvailabilityStatus NVARCHAR(50),
    CreatedDate DATETIME
);
```

### 2. Test the APIs
- Start your backend: `dotnet run`
- Test endpoints: 
  - `GET http://localhost:5069/api/maintenance/{assetId}`
  - `GET http://localhost:5069/api/allocation/{assetId}`

### 3. Add Sample Data (Optional)
Insert some test records to see the tables in action.

## Result
Both tabs now show real data from your database instead of dummy data. The allocation table is fully functional, and the maintenance table only shows actual maintenance records from your backend API.