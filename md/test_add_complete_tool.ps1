# Test script to add a complete tool with detailed data

Write-Host "=== Adding Complete Tool for Testing ===" -ForegroundColor Green

$toolData = @{
    "ToolsId" = "TEST001"
    "ToolName" = "Test Tool Complete"
    "ToolType" = "Power Tool"
    "AssociatedProduct" = "Test Product"
    "ArticleCode" = "ART001"
    "Vendor" = "Test Vendor"
    "Specifications" = "Test Specifications"
    "StorageLocation" = "Test Location"
    "PoNumber" = "PO001"
    "PoDate" = "2024-01-01T00:00:00Z"
    "InvoiceNumber" = "INV001"
    "InvoiceDate" = "2024-01-01T00:00:00Z"
    "ToolCost" = 1000.0
    "ExtraCharges" = 100.0
    "TotalCost" = 1100.0
    "Lifespan" = "5 years"
    "MaintainanceFrequency" = "Monthly"
    "HandlingCertificate" = $true
    "AuditInterval" = "6 months"
    "MaxOutput" = 100
    "LastAuditDate" = "2024-01-01T00:00:00Z"
    "LastAuditNotes" = "Test audit notes"
    "ResponsibleTeam" = "Test Team"
    "Notes" = "Test notes"
    "MsiAsset" = "MSI001"
    "KernAsset" = "KERN001"
    "CreatedBy" = "TestUser"
    "UpdatedBy" = "TestUser"
    "CreatedDate" = "2024-01-01T00:00:00Z"
    "UpdatedDate" = "2024-01-01T00:00:00Z"
    "Status" = 1
}

try {
    Write-Host "Adding tool to database..." -ForegroundColor Yellow
    $jsonBody = $toolData | ConvertTo-Json -Depth 10
    Write-Host "JSON Body: $jsonBody" -ForegroundColor Cyan
    
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/addtools" -Method POST -Body $jsonBody -ContentType "application/json"
    Write-Host "Tool added successfully!" -ForegroundColor Green
    Write-Host "Response: $response" -ForegroundColor Cyan
    
    # Now test the V2 API with this tool
    Write-Host "`nTesting V2 API with new tool..." -ForegroundColor Yellow
    $v2Response = Invoke-RestMethod -Uri "http://localhost:5069/api/v2/item-details/TEST001/tool" -Method GET
    Write-Host "V2 API Response:" -ForegroundColor Green
    Write-Host "  - ItemType: $($v2Response.ItemType)" -ForegroundColor Cyan
    Write-Host "  - HasDetailedData: $($v2Response.HasDetailedData)" -ForegroundColor Cyan
    
    if ($v2Response.HasDetailedData) {
        Write-Host "  - Detailed data found! Keys: $($v2Response.DetailedData.PSObject.Properties.Name -join ', ')" -ForegroundColor Green
    } else {
        Write-Host "  - No detailed data found" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Green