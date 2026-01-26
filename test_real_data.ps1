# PowerShell script to test if the maintenance API is returning real data
Write-Host "=== Testing Maintenance API for Real Data ===" -ForegroundColor Green

# Test maintenance API with known AssetId
$testAssetIds = @("MMD001", "AST001", "CON001")

foreach ($assetId in $testAssetIds) {
    Write-Host "`nTesting AssetId: $assetId" -ForegroundColor Yellow
    
    try {
        $url = "http://localhost:5069/api/maintenance/$assetId"
        Write-Host "Calling: $url"
        
        $response = Invoke-RestMethod -Uri $url -Method GET -TimeoutSec 10
        
        if ($response -and $response.Count -gt 0) {
            Write-Host "SUCCESS: Found $($response.Count) maintenance record(s)" -ForegroundColor Green
            
            # Show first record details
            $firstRecord = $response[0]
            Write-Host "Sample record details:"
            Write-Host "  - AssetId: $($firstRecord.assetId)"
            Write-Host "  - ItemName: $($firstRecord.itemName)"
            Write-Host "  - ServiceType: $($firstRecord.serviceType)"
            Write-Host "  - ServiceDate: $($firstRecord.serviceDate)"
            Write-Host "  - MaintenanceStatus: $($firstRecord.maintenanceStatus)"
            
            # Check if this looks like real data (not dummy data)
            if ($firstRecord.serviceProviderCompany -ne "ABC Calibration Lab" -and 
                $firstRecord.serviceEngineerName -ne "Ravi") {
                Write-Host "✓ This appears to be REAL data from your database!" -ForegroundColor Green
            } else {
                Write-Host "⚠ This might still be dummy data" -ForegroundColor Yellow
            }
        } else {
            Write-Host "No maintenance records found for $assetId" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "ERROR calling API: $($_.Exception.Message)" -ForegroundColor Red
        
        if ($_.Exception.Message -like "*connection*" -or $_.Exception.Message -like "*refused*") {
            Write-Host "Backend may not be running. Please start it with: dotnet run" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n=== Testing Allocation API ===" -ForegroundColor Green

foreach ($assetId in $testAssetIds) {
    Write-Host "`nTesting Allocation for AssetId: $assetId" -ForegroundColor Yellow
    
    try {
        $url = "http://localhost:5069/api/allocation/$assetId"
        $response = Invoke-RestMethod -Uri $url -Method GET -TimeoutSec 10
        
        if ($response -and $response.Count -gt 0) {
            Write-Host "SUCCESS: Found $($response.Count) allocation record(s)" -ForegroundColor Green
            
            $firstRecord = $response[0]
            Write-Host "Sample allocation details:"
            Write-Host "  - AssetId: $($firstRecord.assetId)"
            Write-Host "  - EmployeeName: $($firstRecord.employeeName)"
            Write-Host "  - TeamName: $($firstRecord.teamName)"
            Write-Host "  - Purpose: $($firstRecord.purpose)"
            
            # Check if this looks like real data
            if ($firstRecord.employeeName -ne "John Doe" -and 
                $firstRecord.teamName -ne "Quality Team") {
                Write-Host "✓ This appears to be REAL allocation data!" -ForegroundColor Green
            } else {
                Write-Host "⚠ This might still be dummy data" -ForegroundColor Yellow
            }
        } else {
            Write-Host "No allocation records found for $assetId" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "ERROR calling allocation API: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "1. If you see 'SUCCESS' messages above, the APIs are working"
Write-Host "2. If you see 'REAL data' messages, dummy data has been replaced"
Write-Host "3. If you see connection errors, make sure backend is running with 'dotnet run'"
Write-Host "4. Check the backend console for detailed query logs"