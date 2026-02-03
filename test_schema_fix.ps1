# Test Schema Fix - Verify Status/IsActive changes work correctly
Write-Host "Testing Schema Fix: Status/IsActive standardization..." -ForegroundColor Green

# Step 1: Run the database schema fix
Write-Host "`n1. Running database schema fix..." -ForegroundColor Yellow
try {
    # You'll need to run fix_database_schema.sql manually in SQL Server Management Studio
    Write-Host "Please run fix_database_schema.sql in SQL Server Management Studio first" -ForegroundColor Red
    Write-Host "Press Enter after running the SQL script..." -ForegroundColor Yellow
    Read-Host
} catch {
    Write-Host "Error with database schema fix: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 2: Test backend compilation
Write-Host "`n2. Testing backend compilation..." -ForegroundColor Yellow
try {
    Push-Location "Backend/InventoryManagement"
    $buildResult = dotnet build 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Backend compilation successful!" -ForegroundColor Green
    } else {
        Write-Host "Backend compilation failed:" -ForegroundColor Red
        Write-Host $buildResult
    }
    Pop-Location
} catch {
    Write-Host "Error testing backend compilation: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Test API endpoints after restart
Write-Host "`n3. Testing API endpoints..." -ForegroundColor Yellow
Write-Host "Please restart the backend server and press Enter..." -ForegroundColor Yellow
Read-Host

try {
    # Test individual endpoints
    Write-Host "Testing Tools endpoint..." -ForegroundColor Cyan
    $toolsResponse = Invoke-RestMethod -Uri "http://localhost:5069/api/tools" -Method GET -ContentType "application/json"
    Write-Host "Tools found: $($toolsResponse.Count)" -ForegroundColor Green
    
    Write-Host "Testing MMDs endpoint..." -ForegroundColor Cyan
    $mmdsResponse = Invoke-RestMethod -Uri "http://localhost:5069/api/mmds" -Method GET -ContentType "application/json"
    Write-Host "MMDs found: $($mmdsResponse.Count)" -ForegroundColor Green
    
    Write-Host "Testing Assets/Consumables endpoint..." -ForegroundColor Cyan
    $assetsResponse = Invoke-RestMethod -Uri "http://localhost:5069/api/assets-consumables" -Method GET -ContentType "application/json"
    Write-Host "Assets/Consumables found: $($assetsResponse.Count)" -ForegroundColor Green
    
    Write-Host "Testing Enhanced Master List..." -ForegroundColor Cyan
    $masterResponse = Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list" -Method GET -ContentType "application/json"
    Write-Host "Enhanced Master List items: $($masterResponse.Count)" -ForegroundColor Green
    
    # Check for duplicates
    $duplicates = $masterResponse | Group-Object ItemID | Where-Object { $_.Count -gt 1 }
    if ($duplicates.Count -eq 0) {
        Write-Host "No duplicates found - SUCCESS!" -ForegroundColor Green
    } else {
        Write-Host "Duplicates still found:" -ForegroundColor Red
        $duplicates | ForEach-Object { Write-Host "  $($_.Name): $($_.Count) occurrences" -ForegroundColor Red }
    }
    
} catch {
    Write-Host "Error testing API endpoints: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Test new item creation
Write-Host "`n4. Testing new item creation..." -ForegroundColor Yellow
try {
    # Test creating a new tool
    $newTool = @{
        "ToolsId" = "TEST_STATUS_FIX_001"
        "ToolName" = "Status Fix Test Tool"
        "ToolType" = "Test"
        "AssociatedProduct" = "Test Product"
        "ArticleCode" = "TEST001"
        "Vendor" = "Test Vendor"
        "Specifications" = "Test Specifications"
        "StorageLocation" = "Test Location"
        "PoNumber" = "PO001"
        "PoDate" = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        "InvoiceNumber" = "INV001"
        "InvoiceDate" = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        "ToolCost" = 100.00
        "ExtraCharges" = 10.00
        "TotalCost" = 110.00
        "Lifespan" = "5 years"
        "MaintainanceFrequency" = "Annual"
        "HandlingCertificate" = $false
        "AuditInterval" = "6 months"
        "MaxOutput" = 100
        "LastAuditDate" = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        "LastAuditNotes" = "Test audit"
        "ResponsibleTeam" = "Test Team"
        "Notes" = "Test notes"
        "MsiAsset" = "MSI001"
        "KernAsset" = "KERN001"
        "CreatedBy" = "Test User"
        "UpdatedBy" = "Test User"
        "CreatedDate" = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        "UpdatedDate" = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        "Status" = 1  # This should be 1 for active
    }
    
    $createResponse = Invoke-RestMethod -Uri "http://localhost:5069/api/addtools" -Method POST -ContentType "application/json" -Body ($newTool | ConvertTo-Json)
    Write-Host "New tool creation: SUCCESS" -ForegroundColor Green
    
    # Verify it appears in master list
    Start-Sleep -Seconds 2
    $updatedMasterList = Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list" -Method GET -ContentType "application/json"
    $newItem = $updatedMasterList | Where-Object { $_.ItemID -eq "TEST_STATUS_FIX_001" }
    
    if ($newItem) {
        Write-Host "New item found in master list: SUCCESS" -ForegroundColor Green
        Write-Host "  ItemID: $($newItem.ItemID)" -ForegroundColor Cyan
        Write-Host "  ItemName: $($newItem.ItemName)" -ForegroundColor Cyan
        Write-Host "  Type: $($newItem.Type)" -ForegroundColor Cyan
    } else {
        Write-Host "New item NOT found in master list: FAILED" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Error testing new item creation: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nSchema fix testing completed!" -ForegroundColor Green
Write-Host "`nSummary of changes:" -ForegroundColor Yellow
Write-Host "- Removed IsActive column from MasterRegister" -ForegroundColor White
Write-Host "- Standardized all Status columns to BIT (boolean)" -ForegroundColor White
Write-Host "- Updated all repository queries to use Status only" -ForegroundColor White
Write-Host "- Fixed frontend to send Status: 1 for active items" -ForegroundColor White
Write-Host "- Master list now filters by Status field only" -ForegroundColor White