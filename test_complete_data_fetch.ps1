# Test script to verify complete data fetching API endpoint
Write-Host "Testing complete data fetching API endpoint..." -ForegroundColor Green

# Test MMD item details
$mmdId = "MMD0987"
$url = "http://localhost:5069/api/item-details/$mmdId"

Write-Host "Testing URL: $url" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri $url -Method GET -ContentType "application/json"
    Write-Host "SUCCESS: API response received" -ForegroundColor Green
    Write-Host "Item Type: $($response.ItemType)" -ForegroundColor Cyan
    Write-Host "Master Data: $($response.MasterData.ItemName)" -ForegroundColor Cyan
    Write-Host "Detailed Data Keys: $($response.DetailedData.PSObject.Properties.Name -join ', ')" -ForegroundColor Cyan
    
    # Show some key fields from detailed data
    if ($response.DetailedData.MmdId) {
        Write-Host "MMD ID: $($response.DetailedData.MmdId)" -ForegroundColor White
    }
    if ($response.DetailedData.BrandName) {
        Write-Host "Brand Name: $($response.DetailedData.BrandName)" -ForegroundColor White
    }
    if ($response.DetailedData.ModelNumber) {
        Write-Host "Model Number: $($response.DetailedData.ModelNumber)" -ForegroundColor White
    }
    if ($response.DetailedData.SerialNumber) {
        Write-Host "Serial Number: $($response.DetailedData.SerialNumber)" -ForegroundColor White
    }
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

Write-Host "`nTest completed." -ForegroundColor Green