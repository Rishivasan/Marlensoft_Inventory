# Test Enhanced Master List API
Write-Host "=== Testing Enhanced Master List API ===" -ForegroundColor Green

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list" -Method GET
    
    Write-Host "✓ API call successful!" -ForegroundColor Green
    Write-Host "Total items returned: $($response.Count)" -ForegroundColor Cyan
    
    if ($response.Count -gt 0) {
        $firstItem = $response[0]
        Write-Host "`n--- Sample Item Structure ---" -ForegroundColor Yellow
        Write-Host "ItemID: $($firstItem.itemID)" -ForegroundColor White
        Write-Host "Type: $($firstItem.type)" -ForegroundColor White
        Write-Host "ItemName: $($firstItem.itemName)" -ForegroundColor White
        Write-Host "Vendor: $($firstItem.vendor)" -ForegroundColor White
        Write-Host "ResponsibleTeam: $($firstItem.responsibleTeam)" -ForegroundColor White
        Write-Host "StorageLocation: $($firstItem.storageLocation)" -ForegroundColor White
        Write-Host "NextServiceDue: $($firstItem.nextServiceDue)" -ForegroundColor White
        Write-Host "AvailabilityStatus: $($firstItem.availabilityStatus)" -ForegroundColor White
        Write-Host "CreatedDate: $($firstItem.createdDate)" -ForegroundColor White
        
        # Check for dynamic data
        $itemsWithServiceDue = $response | Where-Object { $_.nextServiceDue -ne $null -and $_.nextServiceDue -ne "" }
        $itemsWithStatus = $response | Where-Object { $_.availabilityStatus -ne "Available" }
        
        Write-Host "`n--- Dynamic Data Analysis ---" -ForegroundColor Yellow
        Write-Host "Items with Next Service Due: $($itemsWithServiceDue.Count)" -ForegroundColor Cyan
        Write-Host "Items with non-Available status: $($itemsWithStatus.Count)" -ForegroundColor Cyan
        
        if ($itemsWithServiceDue.Count -eq 0 -and $itemsWithStatus.Count -eq 0) {
            Write-Host "⚠️  All items show static data (no dynamic maintenance/allocation data)" -ForegroundColor Yellow
            Write-Host "   This indicates Maintenance and Allocation tables don't exist yet" -ForegroundColor Yellow
        } else {
            Write-Host "✓ Dynamic data found!" -ForegroundColor Green
        }
    }
    
    Write-Host "`n=== Test Complete ===" -ForegroundColor Green
    
} catch {
    Write-Host "✗ API call failed: $($_.Exception.Message)" -ForegroundColor Red
}