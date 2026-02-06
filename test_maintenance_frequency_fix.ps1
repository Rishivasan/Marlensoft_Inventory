# Test the GetMaintenanceFrequency endpoint after table name fix

$baseUrl = "http://localhost:5069"

Write-Host "`n=== Testing GetMaintenanceFrequency Endpoint ===" -ForegroundColor Cyan

# Test with a Tool
Write-Host "`n1. Testing with Tool (T001)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/NextService/GetMaintenanceFrequency/T001/tool" -Method Get
    Write-Host "✓ Tool T001 Maintenance Frequency: $($response.maintenanceFrequency)" -ForegroundColor Green
} catch {
    Write-Host "✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
}

# Test with another Tool
Write-Host "`n2. Testing with Tool (T002)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/NextService/GetMaintenanceFrequency/T002/tool" -Method Get
    Write-Host "✓ Tool T002 Maintenance Frequency: $($response.maintenanceFrequency)" -ForegroundColor Green
} catch {
    Write-Host "✗ Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test with an Asset
Write-Host "`n3. Testing with Asset (A001)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/NextService/GetMaintenanceFrequency/A001/asset" -Method Get
    Write-Host "✓ Asset A001 Maintenance Frequency: $($response.maintenanceFrequency)" -ForegroundColor Green
} catch {
    Write-Host "✗ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Cyan
