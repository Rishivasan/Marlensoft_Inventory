# Direct test of V2 API to verify it's working

Write-Host "=== Testing V2 API Directly ===" -ForegroundColor Green

# Test the V2 API endpoint directly
$testUrl = "http://localhost:5069/api/v2/item-details/SIMPLE002/tool"
Write-Host "Testing URL: $testUrl" -ForegroundColor Yellow

try {
    # Use Invoke-WebRequest to get more detailed response info
    $response = Invoke-WebRequest -Uri $testUrl -Method GET -UseBasicParsing
    
    Write-Host "Response Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response Headers:" -ForegroundColor Cyan
    $response.Headers | Format-Table
    
    Write-Host "Response Body:" -ForegroundColor Cyan
    $jsonResponse = $response.Content | ConvertFrom-Json
    
    Write-Host "ItemType: $($jsonResponse.ItemType)" -ForegroundColor Green
    Write-Host "HasDetailedData: $($jsonResponse.HasDetailedData)" -ForegroundColor Green
    
    if ($jsonResponse.MasterData) {
        Write-Host "Master Data Keys: $($jsonResponse.MasterData.PSObject.Properties.Name -join ', ')" -ForegroundColor Yellow
    }
    
    if ($jsonResponse.DetailedData -and $jsonResponse.HasDetailedData) {
        Write-Host "Detailed Data Keys: $($jsonResponse.DetailedData.PSObject.Properties.Name -join ', ')" -ForegroundColor Yellow
        Write-Host "Sample Detailed Data:" -ForegroundColor Cyan
        Write-Host "  ToolType: $($jsonResponse.DetailedData.ToolType)" -ForegroundColor White
        Write-Host "  ToolCost: $($jsonResponse.DetailedData.ToolCost)" -ForegroundColor White
        Write-Host "  Specifications: $($jsonResponse.DetailedData.Specifications)" -ForegroundColor White
    } else {
        Write-Host "No detailed data available" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Error testing V2 API: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Response Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        Write-Host "Response Content: $($_.Exception.Response.Content)" -ForegroundColor Red
    }
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Green