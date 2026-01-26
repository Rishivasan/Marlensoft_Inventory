# PowerShell script to test allocation record creation
Write-Host "=== Testing Allocation Record Creation ===" -ForegroundColor Green

# Test data for creating an allocation record
$testAllocationData = @{
    assetId = "MMD001"
    assetType = "MMD"
    itemName = "Test Item"
    employeeId = "EMP001"
    employeeName = "John Smith"
    teamName = "Production Team A"
    purpose = "Quality testing and calibration work"
    issuedDate = "2024-01-27"
    expectedReturnDate = "2024-02-15"
    actualReturnDate = $null
    availabilityStatus = "Allocated"
} | ConvertTo-Json

Write-Host "Test allocation data to be sent:" -ForegroundColor Yellow
Write-Host $testAllocationData

try {
    $url = "http://localhost:5069/api/allocation"
    Write-Host "`nCalling POST: $url" -ForegroundColor Cyan
    
    $response = Invoke-RestMethod -Uri $url -Method POST -Body $testAllocationData -ContentType "application/json" -TimeoutSec 15
    
    Write-Host "SUCCESS: Allocation record created!" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)"
    
    # Now test if we can retrieve it
    Write-Host "`nTesting retrieval of created allocation record..." -ForegroundColor Cyan
    $getUrl = "http://localhost:5069/api/allocation/MMD001"
    $getResponse = Invoke-RestMethod -Uri $getUrl -Method GET -TimeoutSec 10
    
    Write-Host "Retrieved allocation records count: $($getResponse.Count)" -ForegroundColor Green
    if ($getResponse.Count -gt 0) {
        $latestRecord = $getResponse | Sort-Object createdDate -Descending | Select-Object -First 1
        Write-Host "Latest allocation record details:"
        Write-Host "  - EmployeeName: $($latestRecord.employeeName)"
        Write-Host "  - TeamName: $($latestRecord.teamName)"
        Write-Host "  - Purpose: $($latestRecord.purpose)"
        Write-Host "  - IssuedDate: $($latestRecord.issuedDate)"
        Write-Host "  - ExpectedReturnDate: $($latestRecord.expectedReturnDate)"
        Write-Host "  - Status: $($latestRecord.availabilityStatus)"
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

Write-Host "`n=== Allocation Test Complete ===" -ForegroundColor Cyan
Write-Host "If successful, the new allocation record should appear in your frontend table!"