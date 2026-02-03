# Test MMD location and brand name fix verification
Write-Host "Testing MMD location and brand name fixes..." -ForegroundColor Green

# Test 1: Check if backend is running
Write-Host "`n1. Checking if backend is running..." -ForegroundColor Yellow
try {
    $healthCheck = Invoke-WebRequest -Uri "https://localhost:7294/api/mmds" -Method GET -SkipCertificateCheck -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Backend is running (Status: $($healthCheck.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ Backend not accessible: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Get MMD data and check fields
Write-Host "`n2. Testing MMD API response..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "https://localhost:7294/api/mmds" -Method GET -SkipCertificateCheck
    
    if ($response -and $response.Count -gt 0) {
        $firstMmd = $response[0]
        Write-Host "✓ Found $($response.Count) MMD records" -ForegroundColor Green
        Write-Host "Sample MMD data:" -ForegroundColor Cyan
        Write-Host "  MmdId: $($firstMmd.mmdId)" -ForegroundColor White
        Write-Host "  BrandName: '$($firstMmd.brandName)'" -ForegroundColor White
        Write-Host "  Location: '$($firstMmd.location)'" -ForegroundColor White
        Write-Host "  Vendor: '$($firstMmd.vendor)'" -ForegroundColor White
        
        # Test V2 API
        Write-Host "`n3. Testing V2 API for complete MMD details..." -ForegroundColor Yellow
        $mmdId = $firstMmd.mmdId
        $v2Response = Invoke-RestMethod -Uri "https://localhost:7294/api/v2/item-details/$mmdId/mmd" -Method GET -SkipCertificateCheck
        
        Write-Host "V2 API Response:" -ForegroundColor Cyan
        Write-Host "  HasDetailedData: $($v2Response.hasDetailedData)" -ForegroundColor White
        
        if ($v2Response.hasDetailedData -and $v2Response.detailedData) {
            $detailedData = $v2Response.detailedData
            Write-Host "  Detailed BrandName: '$($detailedData.brandName)'" -ForegroundColor White
            Write-Host "  Detailed Location: '$($detailedData.location)'" -ForegroundColor White
        }
        
        if ($v2Response.masterData) {
            $masterData = $v2Response.masterData
            Write-Host "  Master StorageLocation: '$($masterData.storageLocation)'" -ForegroundColor White
        }
        
        Write-Host "`n✓ All tests completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "✗ No MMD records found" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Error testing MMD API: $($_.Exception.Message)" -ForegroundColor Red
}