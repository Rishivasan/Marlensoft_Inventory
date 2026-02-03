# Test script to verify the item-details API endpoint
$baseUrl = "https://localhost:7240"
$itemId = "TL2324"  # Using the Tool ID from your screenshot

Write-Host "Testing item-details API endpoint..." -ForegroundColor Green
Write-Host "Base URL: $baseUrl" -ForegroundColor Yellow
Write-Host "Item ID: $itemId" -ForegroundColor Yellow

try {
    # Test the item-details endpoint
    $endpoint = "$baseUrl/api/item-details/$itemId"
    Write-Host "Calling endpoint: $endpoint" -ForegroundColor Cyan
    
    $response = Invoke-RestMethod -Uri $endpoint -Method Get -ContentType "application/json"
    
    Write-Host "✅ API call successful!" -ForegroundColor Green
    Write-Host "Response structure:" -ForegroundColor Yellow
    
    # Display the response structure
    Write-Host "ItemType: $($response.ItemType)" -ForegroundColor White
    Write-Host "MasterData keys: $($response.MasterData.PSObject.Properties.Name -join ', ')" -ForegroundColor White
    Write-Host "DetailedData keys: $($response.DetailedData.PSObject.Properties.Name -join ', ')" -ForegroundColor White
    
    Write-Host "`nMaster Data:" -ForegroundColor Yellow
    $response.MasterData | Format-List
    
    Write-Host "`nDetailed Data:" -ForegroundColor Yellow
    $response.DetailedData | Format-List
    
} catch {
    Write-Host "❌ API call failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "Status Code: $statusCode" -ForegroundColor Red
    }
}

Write-Host "`nTest completed." -ForegroundColor Green