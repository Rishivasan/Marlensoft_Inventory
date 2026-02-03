# Test MMD location and brand name fetching
$baseUrl = "https://localhost:7297"

Write-Host "Testing MMD location and brand name fetching..." -ForegroundColor Green

# Test 1: Get all MMDs to see available data
Write-Host "`n1. Getting all MMDs..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/mmds" -Method GET -SkipCertificateCheck
    Write-Host "MMDs found: $($response.Count)" -ForegroundColor Green
    
    if ($response.Count -gt 0) {
        $firstMmd = $response[0]
        Write-Host "First MMD details:" -ForegroundColor Cyan
        Write-Host "  MmdId: $($firstMmd.mmdId)" -ForegroundColor White
        Write-Host "  BrandName: '$($firstMmd.brandName)'" -ForegroundColor White
        Write-Host "  Location: '$($firstMmd.location)'" -ForegroundColor White
        Write-Host "  Vendor: '$($firstMmd.vendor)'" -ForegroundColor White
        
        # Test 2: Get complete details using V2 API
        Write-Host "`n2. Testing V2 API for complete MMD details..." -ForegroundColor Yellow
        $mmdId = $firstMmd.mmdId
        $v2Response = Invoke-RestMethod -Uri "$baseUrl/api/v2/item-details/$mmdId/mmd" -Method GET -SkipCertificateCheck
        
        Write-Host "V2 API Response:" -ForegroundColor Cyan
        Write-Host "  HasDetailedData: $($v2Response.hasDetailedData)" -ForegroundColor White
        
        if ($v2Response.hasDetailedData) {
            $detailedData = $v2Response.detailedData
            Write-Host "  Detailed BrandName: '$($detailedData.brandName)'" -ForegroundColor White
            Write-Host "  Detailed Location: '$($detailedData.location)'" -ForegroundColor White
        }
        
        if ($v2Response.masterData) {
            $masterData = $v2Response.masterData
            Write-Host "  Master StorageLocation: '$($masterData.storageLocation)'" -ForegroundColor White
            Write-Host "  Master Vendor: '$($masterData.vendor)'" -ForegroundColor White
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTest completed." -ForegroundColor Green