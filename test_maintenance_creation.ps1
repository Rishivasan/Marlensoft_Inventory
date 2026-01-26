# PowerShell script to test maintenance record creation
Write-Host "=== Testing Maintenance Record Creation ===" -ForegroundColor Green

# Test data for creating a maintenance record
$testMaintenanceData = @{
    assetId = "MMD001"
    assetType = "MMD"
    itemName = "Test Item"
    serviceDate = "2024-01-27"
    serviceProviderCompany = "Test Service Provider"
    serviceEngineerName = "Test Engineer"
    serviceType = "Preventive"
    nextServiceDue = "2024-07-27"
    serviceNotes = "Test maintenance service"
    maintenanceStatus = "Completed"
    cost = 100.50
    responsibleTeam = "Test Team"
} | ConvertTo-Json

Write-Host "Test data to be sent:" -ForegroundColor Yellow
Write-Host $testMaintenanceData

try {
    $url = "http://localhost:5069/api/maintenance"
    Write-Host "`nCalling POST: $url" -ForegroundColor Cyan
    
    $response = Invoke-RestMethod -Uri $url -Method POST -Body $testMaintenanceData -ContentType "application/json" -TimeoutSec 15
    
    Write-Host "SUCCESS: Maintenance record created!" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)"
    
    # Now test if we can retrieve it
    Write-Host "`nTesting retrieval of created record..." -ForegroundColor Cyan
    $getUrl = "http://localhost:5069/api/maintenance/MMD001"
    $getResponse = Invoke-RestMethod -Uri $getUrl -Method GET -TimeoutSec 10
    
    Write-Host "Retrieved records count: $($getResponse.Count)" -ForegroundColor Green
    if ($getResponse.Count -gt 0) {
        $latestRecord = $getResponse | Sort-Object createdDate -Descending | Select-Object -First 1
        Write-Host "Latest record details:"
        Write-Host "  - ServiceDate: $($latestRecord.serviceDate)"
        Write-Host "  - ServiceProvider: $($latestRecord.serviceProviderCompany)"
        Write-Host "  - ServiceEngineer: $($latestRecord.serviceEngineerName)"
        Write-Host "  - ServiceType: $($latestRecord.serviceType)"
        Write-Host "  - Cost: $($latestRecord.cost)"
        Write-Host "  - Status: $($latestRecord.maintenanceStatus)"
    }
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Message -like "*connection*" -or $_.Exception.Message -like "*refused*") {
        Write-Host "Backend may not be running. Please start it with: dotnet run" -ForegroundColor Yellow
    }
    
    # Show more details about the error
    if ($_.ErrorDetails) {
        Write-Host "Error details: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Cyan
Write-Host "If successful, the new maintenance record should appear in your frontend table!"