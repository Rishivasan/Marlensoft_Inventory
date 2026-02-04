# Test script for Control Point Types API endpoint
$baseUrl = "http://localhost:5069/api"

Write-Host "Testing Control Point Types API..." -ForegroundColor Green

try {
    # Test Control Point Types endpoint
    Write-Host "`nTesting GET /api/quality/control-point-types" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/quality/control-point-types" -Method GET -ContentType "application/json"
    Write-Host "✅ Control Point Types Response:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3 | Write-Host
    
    # Test Units endpoint
    Write-Host "`nTesting GET /api/quality/units" -ForegroundColor Yellow
    $unitsResponse = Invoke-RestMethod -Uri "$baseUrl/quality/units" -Method GET -ContentType "application/json"
    Write-Host "✅ Units Response:" -ForegroundColor Green
    $unitsResponse | ConvertTo-Json -Depth 3 | Write-Host
    
    Write-Host "`n✅ All tests completed successfully!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}