# Test the updated Units API to verify it returns UnitMaster data

Write-Host "Testing Updated Units API..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/Quality/units" -Method GET -ContentType "application/json"
    Write-Host "Response Type: $($response.GetType().Name)" -ForegroundColor Yellow
    Write-Host "Response Count: $($response.Count)" -ForegroundColor Yellow
    
    Write-Host "Units from UnitMaster table:" -ForegroundColor Yellow
    $response | ForEach-Object { Write-Host "  - $_" -ForegroundColor Green }
    
    Write-Host "`nExpected units from UnitMaster:" -ForegroundColor Yellow
    Write-Host "  - cm" -ForegroundColor Cyan
    Write-Host "  - gram" -ForegroundColor Cyan  
    Write-Host "  - inch" -ForegroundColor Cyan
    Write-Host "  - kg" -ForegroundColor Cyan
    Write-Host "  - liter" -ForegroundColor Cyan
    Write-Host "  - mm" -ForegroundColor Cyan
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nAPI test completed!" -ForegroundColor Green