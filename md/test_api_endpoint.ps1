# Test the item details API endpoint
Write-Host "Testing item details API endpoint..." -ForegroundColor Green

# Test with a known MMD ID
$testUrl = "http://localhost:5070/api/item-details/MMD0987"
Write-Host "Testing URL: $testUrl" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri $testUrl -Method GET -ContentType "application/json" -TimeoutSec 10
    Write-Host "SUCCESS: API response received" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

# Also test enhanced master list to see available items
Write-Host "`nTesting enhanced master list..." -ForegroundColor Green
$masterUrl = "http://localhost:5070/api/enhanced-master-list"

try {
    $masterResponse = Invoke-RestMethod -Uri $masterUrl -Method GET -ContentType "application/json" -TimeoutSec 10
    Write-Host "Master list loaded with $($masterResponse.Count) items" -ForegroundColor Green
    
    # Show first few items
    $masterResponse | Select-Object -First 3 | ForEach-Object {
        Write-Host "Item: $($_.ItemID) - $($_.ItemName) - Type: $($_.Type)" -ForegroundColor White
    }
} catch {
    Write-Host "ERROR loading master list: $($_.Exception.Message)" -ForegroundColor Red
}