# Test MMD with HTTP
Write-Host "Testing MMD API with HTTP..." -ForegroundColor Green

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/mmds" -Method GET
    Write-Host "✓ Found $($response.Count) MMD records" -ForegroundColor Green
    
    if ($response.Count -gt 0) {
        $firstMmd = $response[0]
        Write-Host "Sample MMD:" -ForegroundColor Cyan
        Write-Host "  MmdId: $($firstMmd.mmdId)" -ForegroundColor White
        Write-Host "  BrandName: '$($firstMmd.brandName)'" -ForegroundColor White
        Write-Host "  Location: '$($firstMmd.location)'" -ForegroundColor White
        
        # Test V2 API
        $mmdId = $firstMmd.mmdId
        $v2Response = Invoke-RestMethod -Uri "http://localhost:5069/api/v2/item-details/$mmdId/mmd" -Method GET
        
        Write-Host "V2 API:" -ForegroundColor Cyan
        Write-Host "  HasDetailedData: $($v2Response.hasDetailedData)" -ForegroundColor White
        
        if ($v2Response.detailedData) {
            Write-Host "  Detailed BrandName: '$($v2Response.detailedData.brandName)'" -ForegroundColor White
            Write-Host "  Detailed Location: '$($v2Response.detailedData.location)'" -ForegroundColor White
        }
        
        if ($v2Response.masterData) {
            Write-Host "  Master StorageLocation: '$($v2Response.masterData.storageLocation)'" -ForegroundColor White
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}