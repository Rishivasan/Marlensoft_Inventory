# Test script for V2 API endpoints
# This script tests the new ItemDetailsV2Controller endpoints

$baseUrl = "http://localhost:5069"

Write-Host "Testing V2 API Endpoints..." -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Test 1: Get Tool details
Write-Host "`n1. Testing Tool Details (GET)..." -ForegroundColor Yellow
$toolId = "T001"  # Replace with actual tool ID from your database
$toolUrl = "$baseUrl/api/v2/item-details/$toolId/tool"

try {
    $toolResponse = Invoke-RestMethod -Uri $toolUrl -Method GET -ContentType "application/json"
    Write-Host "✓ Tool API Response:" -ForegroundColor Green
    Write-Host "  - ItemType: $($toolResponse.ItemType)" -ForegroundColor Cyan
    Write-Host "  - HasDetailedData: $($toolResponse.HasDetailedData)" -ForegroundColor Cyan
    if ($toolResponse.MasterData) {
        Write-Host "  - Master ItemID: $($toolResponse.MasterData.ItemID)" -ForegroundColor Cyan
        Write-Host "  - Master ItemName: $($toolResponse.MasterData.ItemName)" -ForegroundColor Cyan
    }
    if ($toolResponse.DetailedData -and $toolResponse.HasDetailedData) {
        Write-Host "  - Tool Type: $($toolResponse.DetailedData.ToolType)" -ForegroundColor Cyan
        Write-Host "  - Tool Name: $($toolResponse.DetailedData.ToolName)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Tool API Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Get MMD details
Write-Host "`n2. Testing MMD Details (GET)..." -ForegroundColor Yellow
$mmdId = "MMD001"  # Replace with actual MMD ID from your database
$mmdUrl = "$baseUrl/api/v2/item-details/$mmdId/mmd"

try {
    $mmdResponse = Invoke-RestMethod -Uri $mmdUrl -Method GET -ContentType "application/json"
    Write-Host "✓ MMD API Response:" -ForegroundColor Green
    Write-Host "  - ItemType: $($mmdResponse.ItemType)" -ForegroundColor Cyan
    Write-Host "  - HasDetailedData: $($mmdResponse.HasDetailedData)" -ForegroundColor Cyan
    if ($mmdResponse.MasterData) {
        Write-Host "  - Master ItemID: $($mmdResponse.MasterData.ItemID)" -ForegroundColor Cyan
        Write-Host "  - Master ItemName: $($mmdResponse.MasterData.ItemName)" -ForegroundColor Cyan
    }
    if ($mmdResponse.DetailedData -and $mmdResponse.HasDetailedData) {
        Write-Host "  - MMD Name: $($mmdResponse.DetailedData.MmdName)" -ForegroundColor Cyan
        Write-Host "  - Model Number: $($mmdResponse.DetailedData.ModelNumber)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ MMD API Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Get Asset details
Write-Host "`n3. Testing Asset Details (GET)..." -ForegroundColor Yellow
$assetId = "A001"  # Replace with actual asset ID from your database
$assetUrl = "$baseUrl/api/v2/item-details/$assetId/asset"

try {
    $assetResponse = Invoke-RestMethod -Uri $assetUrl -Method GET -ContentType "application/json"
    Write-Host "✓ Asset API Response:" -ForegroundColor Green
    Write-Host "  - ItemType: $($assetResponse.ItemType)" -ForegroundColor Cyan
    Write-Host "  - HasDetailedData: $($assetResponse.HasDetailedData)" -ForegroundColor Cyan
    if ($assetResponse.MasterData) {
        Write-Host "  - Master ItemID: $($assetResponse.MasterData.ItemID)" -ForegroundColor Cyan
        Write-Host "  - Master ItemName: $($assetResponse.MasterData.ItemName)" -ForegroundColor Cyan
    }
    if ($assetResponse.DetailedData -and $assetResponse.HasDetailedData) {
        Write-Host "  - Asset Name: $($assetResponse.DetailedData.AssetName)" -ForegroundColor Cyan
        Write-Host "  - Category: $($assetResponse.DetailedData.Category)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Asset API Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Get Consumable details
Write-Host "`n4. Testing Consumable Details (GET)..." -ForegroundColor Yellow
$consumableId = "C001"  # Replace with actual consumable ID from your database
$consumableUrl = "$baseUrl/api/v2/item-details/$consumableId/consumable"

try {
    $consumableResponse = Invoke-RestMethod -Uri $consumableUrl -Method GET -ContentType "application/json"
    Write-Host "✓ Consumable API Response:" -ForegroundColor Green
    Write-Host "  - ItemType: $($consumableResponse.ItemType)" -ForegroundColor Cyan
    Write-Host "  - HasDetailedData: $($consumableResponse.HasDetailedData)" -ForegroundColor Cyan
    if ($consumableResponse.MasterData) {
        Write-Host "  - Master ItemID: $($consumableResponse.MasterData.ItemID)" -ForegroundColor Cyan
        Write-Host "  - Master ItemName: $($consumableResponse.MasterData.ItemName)" -ForegroundColor Cyan
    }
    if ($consumableResponse.DetailedData -and $consumableResponse.HasDetailedData) {
        Write-Host "  - Asset Name: $($consumableResponse.DetailedData.AssetName)" -ForegroundColor Cyan
        Write-Host "  - Category: $($consumableResponse.DetailedData.Category)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "✗ Consumable API Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Test Field Structure endpoint
Write-Host "`n5. Testing Field Structure (GET)..." -ForegroundColor Yellow
$fieldsUrl = "$baseUrl/api/v2/item-details/test/tool/fields"

try {
    $fieldsResponse = Invoke-RestMethod -Uri $fieldsUrl -Method GET -ContentType "application/json"
    Write-Host "✓ Fields API Response:" -ForegroundColor Green
    Write-Host "  - ItemType: $($fieldsResponse.ItemType)" -ForegroundColor Cyan
    Write-Host "  - Basic Fields: $($fieldsResponse.Fields.Basic -join ', ')" -ForegroundColor Cyan
    Write-Host "  - Purchase Fields: $($fieldsResponse.Fields.Purchase -join ', ')" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Fields API Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Test Update endpoint (PUT) - Only if you have a test tool
Write-Host "`n6. Testing Update Tool (PUT)..." -ForegroundColor Yellow
$updateUrl = "$baseUrl/api/v2/item-details/$toolId/tool"
$updateData = @{
    ToolsId = $toolId
    ToolName = "Updated Test Tool"
    ToolType = "Hand Tool"
    Vendor = "Test Vendor"
    Status = 1
    UpdatedBy = "Test Script"
    UpdatedDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
} | ConvertTo-Json

try {
    $updateResponse = Invoke-RestMethod -Uri $updateUrl -Method PUT -Body $updateData -ContentType "application/json"
    Write-Host "✓ Update API Response: $updateResponse" -ForegroundColor Green
} catch {
    Write-Host "✗ Update API Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  This is expected if the tool ID doesn't exist in the database" -ForegroundColor Yellow
}

Write-Host "`n================================" -ForegroundColor Green
Write-Host "V2 API Testing Complete!" -ForegroundColor Green
Write-Host "`nNotes:" -ForegroundColor Yellow
Write-Host "- Replace the test IDs (T001, MMD001, A001, C001) with actual IDs from your database" -ForegroundColor Yellow
Write-Host "- Make sure the backend server is running on port 5069" -ForegroundColor Yellow
Write-Host "- Check the backend console for detailed debug logs" -ForegroundColor Yellow