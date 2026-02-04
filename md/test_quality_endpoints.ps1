# Test Quality API endpoints

Write-Host "Testing Control Point Types endpoint..." -ForegroundColor Green
try {
    $controlPointTypes = Invoke-RestMethod -Uri "http://localhost:5069/api/Quality/control-point-types" -Method GET -ContentType "application/json"
    Write-Host "Control Point Types Response:" -ForegroundColor Yellow
    $controlPointTypes | Format-Table -AutoSize
} catch {
    Write-Host "Error testing control point types: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTesting Units endpoint..." -ForegroundColor Green
try {
    $units = Invoke-RestMethod -Uri "http://localhost:5069/api/Quality/units" -Method GET -ContentType "application/json"
    Write-Host "Units Response:" -ForegroundColor Yellow
    $units | ForEach-Object { Write-Host "- $_" }
} catch {
    Write-Host "Error testing units: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nAPI endpoints test completed!" -ForegroundColor Green