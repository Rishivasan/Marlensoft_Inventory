# PowerShell script to debug allocation API issues
Write-Host "=== Allocation API Debug Test ===" -ForegroundColor Green

# Test allocation API with known AssetId from your maintenance data
$testAssetIds = @("MMD001", "AST001", "CON001")

foreach ($assetId in $testAssetIds) {
    Write-Host "`n" + "="*50 -ForegroundColor Yellow
    Write-Host "Testing Allocation API for AssetId: $assetId" -ForegroundColor Yellow
    Write-Host "="*50 -ForegroundColor Yellow
    
    try {
        $url = "http://localhost:5069/api/allocation/$assetId"
        Write-Host "Calling: $url" -ForegroundColor Cyan
        
        $response = Invoke-RestMethod -Uri $url -Method GET -TimeoutSec 15
        
        if ($response -and $response.Count -gt 0) {
            Write-Host "SUCCESS: Found $($response.Count) allocation record(s)" -ForegroundColor Green
            
            # Show details of each record
            for ($i = 0; $i -lt $response.Count; $i++) {
                $record = $response[$i]
                Write-Host "`nRecord $($i + 1):" -ForegroundColor White
                Write-Host "  - AssetId: $($record.assetId)"
                Write-Host "  - EmployeeId: $($record.employeeId)"
                Write-Host "  - EmployeeName: $($record.employeeName)"
                Write-Host "  - TeamName: $($record.teamName)"
                Write-Host "  - Purpose: $($record.purpose)"
                Write-Host "  - IssuedDate: $($record.issuedDate)"
                Write-Host "  - ExpectedReturnDate: $($record.expectedReturnDate)"
                Write-Host "  - ActualReturnDate: $($record.actualReturnDate)"
                Write-Host "  - AvailabilityStatus: $($record.availabilityStatus)"
            }
        } else {
            Write-Host "No allocation records found for $assetId" -ForegroundColor Gray
            Write-Host "This could mean:" -ForegroundColor Yellow
            Write-Host "  1. No allocation data exists for this AssetId" -ForegroundColor Yellow
            Write-Host "  2. Allocation table doesn't exist" -ForegroundColor Yellow
            Write-Host "  3. Table has different name/structure" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "ERROR calling allocation API: $($_.Exception.Message)" -ForegroundColor Red
        
        if ($_.Exception.Message -like "*connection*" -or $_.Exception.Message -like "*refused*") {
            Write-Host "Backend may not be running. Please start it with: dotnet run" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n" + "="*60 -ForegroundColor Cyan
Write-Host "IMPORTANT: Check the backend console output!" -ForegroundColor Cyan
Write-Host "="*60 -ForegroundColor Cyan
Write-Host "The enhanced allocation controller now provides detailed debugging info." -ForegroundColor White
Write-Host "Look for messages like:" -ForegroundColor White
Write-Host "  - 'Found potential allocation tables: ...'" -ForegroundColor Gray
Write-Host "  - 'Trying query: ...'" -ForegroundColor Gray
Write-Host "  - 'All tables in database: ...'" -ForegroundColor Gray
Write-Host "  - 'Sample columns in [TableName]: ...'" -ForegroundColor Gray
Write-Host "`nThis will help identify:" -ForegroundColor White
Write-Host "  1. What tables exist in your database" -ForegroundColor Yellow
Write-Host "  2. Which table contains allocation/usage data" -ForegroundColor Yellow
Write-Host "  3. What the column names are in your allocation table" -ForegroundColor Yellow

Write-Host "`nNext steps:" -ForegroundColor Green
Write-Host "1. Run this script while backend is running" -ForegroundColor White
Write-Host "2. Check backend console for detailed debug output" -ForegroundColor White
Write-Host "3. Share the backend console output to identify the issue" -ForegroundColor White