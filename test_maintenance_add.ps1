# Test script to add a maintenance record via API
Write-Host "=== TESTING MAINTENANCE RECORD CREATION ===" -ForegroundColor Green

# Test data for maintenance record
$maintenanceData = @{
    assetId = "TEST_MAINTENANCE_001"
    assetType = "Tool"
    itemName = "Test Tool for Maintenance"
    serviceDate = "2024-02-02T00:00:00Z"
    serviceProviderCompany = "Test Service Company"
    serviceEngineerName = "Test Engineer"
    serviceType = "Preventive"
    nextServiceDue = "2024-08-02T00:00:00Z"
    serviceNotes = "Test maintenance record created via API"
    maintenanceStatus = "Completed"
    cost = 150.00
    responsibleTeam = "Test Team"
} | ConvertTo-Json

Write-Host "Test data to be sent:" -ForegroundColor Yellow
Write-Host $maintenanceData

Write-Host "`nSending POST request to maintenance API..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/maintenance" -Method POST -Body $maintenanceData -ContentType "application/json"
    Write-Host "SUCCESS! Maintenance record created:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "ERROR creating maintenance record:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response body: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n=== TEST COMPLETE ===" -ForegroundColor Green