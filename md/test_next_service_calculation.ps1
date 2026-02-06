# Test script for Next Service Date Calculation functionality

Write-Host "Testing Next Service Date Calculation System..." -ForegroundColor Green

# Test 1: Test the NextService API endpoints
Write-Host "`n1. Testing NextService API endpoints..." -ForegroundColor Yellow

# Test getting last service date
$testAssetId = "TL5001"
$testAssetType = "Tool"

try {
    $response = Invoke-RestMethod -Uri "https://localhost:7297/api/NextService/GetLastServiceDate/$testAssetId/$testAssetType" -Method GET
    Write-Host "✓ GetLastServiceDate API working: $($response.lastServiceDate)" -ForegroundColor Green
} catch {
    Write-Host "✗ GetLastServiceDate API failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Test maintenance frequency retrieval
try {
    $response = Invoke-RestMethod -Uri "https://localhost:7297/api/NextService/GetMaintenanceFrequency/$testAssetId/$testAssetType" -Method GET
    Write-Host "✓ GetMaintenanceFrequency API working: $($response.maintenanceFrequency)" -ForegroundColor Green
} catch {
    Write-Host "✗ GetMaintenanceFrequency API failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test next service date calculation
Write-Host "`n2. Testing next service date calculation..." -ForegroundColor Yellow

$calculationData = @{
    createdDate = "2024-01-01T00:00:00Z"
    lastServiceDate = $null
    maintenanceFrequency = "Monthly"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://localhost:7297/api/NextService/CalculateNextServiceDate" -Method POST -Body $calculationData -ContentType "application/json"
    Write-Host "✓ CalculateNextServiceDate API working: $($response.nextServiceDate)" -ForegroundColor Green
} catch {
    Write-Host "✗ CalculateNextServiceDate API failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Test updating next service date
Write-Host "`n3. Testing next service date update..." -ForegroundColor Yellow

$updateData = @{
    assetId = $testAssetId
    assetType = $testAssetType
    nextServiceDate = "2025-02-01T00:00:00Z"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://localhost:7297/api/NextService/UpdateNextServiceDate" -Method POST -Body $updateData -ContentType "application/json"
    Write-Host "✓ UpdateNextServiceDate API working: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "✗ UpdateNextServiceDate API failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Test creating a new tool with automatic next service date calculation
Write-Host "`n4. Testing new tool creation with next service date..." -ForegroundColor Yellow

$newToolData = @{
    ToolsId = "TEST_TOOL_$(Get-Date -Format 'yyyyMMddHHmmss')"
    ToolName = "Test Tool for Next Service"
    ToolType = "Hand Tool"
    AssociatedProduct = "Test Product"
    ArticleCode = "TEST001"
    Vendor = "Test Vendor"
    Specifications = "Test specifications"
    StorageLocation = "Test Location"
    PoNumber = "PO001"
    PoDate = "2024-01-01T00:00:00Z"
    InvoiceNumber = "INV001"
    InvoiceDate = "2024-01-01T00:00:00Z"
    ToolCost = 100.00
    ExtraCharges = 10.00
    TotalCost = 110.00
    Lifespan = "5 years"
    MaintainanceFrequency = "Quarterly"
    HandlingCertificate = $true
    AuditInterval = "6 months"
    MaxOutput = 1000
    LastAuditDate = "2024-01-01T00:00:00Z"
    LastAuditNotes = "Test notes"
    ResponsibleTeam = "Test Team"
    Notes = "Test tool for next service calculation"
    MsiAsset = "MSI001"
    KernAsset = "KERN001"
    CreatedBy = "Test User"
    UpdatedBy = "Test User"
    CreatedDate = "2024-01-01T00:00:00Z"
    UpdatedDate = "2024-01-01T00:00:00Z"
    Status = $true
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://localhost:7297/api/Tools" -Method POST -Body $newToolData -ContentType "application/json"
    Write-Host "✓ New tool created successfully" -ForegroundColor Green
    
    # Wait a moment for the next service date calculation to complete
    Start-Sleep -Seconds 2
    
    # Check if next service date was calculated
    $toolId = ($newToolData | ConvertFrom-Json).ToolsId
    $checkResponse = Invoke-RestMethod -Uri "https://localhost:7297/api/NextService/GetMaintenanceFrequency/$toolId/Tool" -Method GET
    Write-Host "✓ Tool maintenance frequency: $($checkResponse.maintenanceFrequency)" -ForegroundColor Green
    
} catch {
    Write-Host "✗ New tool creation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Test the enhanced master list API with next service dates
Write-Host "`n5. Testing enhanced master list with next service dates..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "https://localhost:7297/api/ItemDetailsV2/enhanced-master-list" -Method GET
    $itemsWithNextService = $response | Where-Object { $_.nextServiceDue -ne $null }
    Write-Host "✓ Enhanced master list working. Items with next service dates: $($itemsWithNextService.Count)" -ForegroundColor Green
    
    if ($itemsWithNextService.Count -gt 0) {
        Write-Host "Sample items with next service dates:" -ForegroundColor Cyan
        $itemsWithNextService | Select-Object -First 3 | ForEach-Object {
            Write-Host "  - $($_.name) ($($_.itemType)): Next service due $($_.nextServiceDue)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "✗ Enhanced master list API failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Next Service Date Calculation Test Complete ===" -ForegroundColor Green
Write-Host "The system should now automatically calculate next service dates when:" -ForegroundColor White
Write-Host "1. New items are created with maintenance frequency" -ForegroundColor White
Write-Host "2. Maintenance services are performed" -ForegroundColor White
Write-Host "3. The master list displays next service dates with status indicators" -ForegroundColor White