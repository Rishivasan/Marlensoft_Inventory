# Test API data format to understand the structure

Write-Host "Testing Control Point Types API..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/Quality/control-point-types" -Method GET -ContentType "application/json"
    Write-Host "Response Type: $($response.GetType().Name)" -ForegroundColor Yellow
    Write-Host "Response Count: $($response.Count)" -ForegroundColor Yellow
    
    if ($response.Count -gt 0) {
        Write-Host "First Item:" -ForegroundColor Yellow
        $response[0] | Format-List
        Write-Host "First Item Properties:" -ForegroundColor Yellow
        $response[0].PSObject.Properties | ForEach-Object { Write-Host "  $($_.Name): $($_.Value)" }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTesting Units API..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/Quality/units" -Method GET -ContentType "application/json"
    Write-Host "Response Type: $($response.GetType().Name)" -ForegroundColor Yellow
    Write-Host "Response Count: $($response.Count)" -ForegroundColor Yellow
    
    if ($response.Count -gt 0) {
        Write-Host "First 5 Items:" -ForegroundColor Yellow
        $response[0..4] | ForEach-Object { Write-Host "  $_" }
        Write-Host "Item Types:" -ForegroundColor Yellow
        $response[0..4] | ForEach-Object { Write-Host "  $($_.GetType().Name): $_" }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}