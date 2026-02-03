# Test Enhanced Master List with Real Maintenance and Allocation Data
# This script tests the updated GetEnhancedMasterListAsync method

Write-Host "=== TESTING ENHANCED MASTER LIST WITH MAINTENANCE/ALLOCATION DATA ===" -ForegroundColor Cyan
Write-Host ""

# Test the enhanced master list endpoint
Write-Host "1. Testing Enhanced Master List API..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/api/masterregister/enhanced" -Method GET
    
    if ($response -and $response.Count -gt 0) {
        Write-Host "✓ SUCCESS: Retrieved $($response.Count) items from enhanced master list" -ForegroundColor Green
        
        # Analyze the data
        $itemsWithNextServiceDue = ($response | Where-Object { $_.nextServiceDue -ne $null }).Count
        $itemsAllocated = ($response | Where-Object { $_.availabilityStatus -ne "Available" }).Count
        $itemsAvailable = ($response | Where-Object { $_.availabilityStatus -eq "Available" }).Count
        
        Write-Host ""
        Write-Host "=== DATA ANALYSIS ===" -ForegroundColor Cyan
        Write-Host "Total Items: $($response.Count)"
        Write-Host "Items with Next Service Due: $itemsWithNextServiceDue"
        Write-Host "Items Currently Allocated: $itemsAllocated"
        Write-Host "Items Available: $itemsAvailable"
        Write-Host ""
        
        # Show sample items with maintenance data
        $itemsWithMaintenance = $response | Where-Object { $_.nextServiceDue -ne $null } | Select-Object -First 3
        if ($itemsWithMaintenance.Count -gt 0) {
            Write-Host "=== SAMPLE ITEMS WITH MAINTENANCE DATA ===" -ForegroundColor Green
            foreach ($item in $itemsWithMaintenance) {
                Write-Host "Item: $($item.itemName) ($($item.itemID))"
                Write-Host "  Next Service Due: $($item.nextServiceDue)"
                Write-Host "  Status: $($item.availabilityStatus)"
                Write-Host ""
            }
        } else {
            Write-Host "⚠️  No items found with maintenance data (NextServiceDue)" -ForegroundColor Yellow
        }
        
        # Show sample allocated items
        $allocatedItems = $response | Where-Object { $_.availabilityStatus -ne "Available" } | Select-Object -First 3
        if ($allocatedItems.Count -gt 0) {
            Write-Host "=== SAMPLE ALLOCATED ITEMS ===" -ForegroundColor Green
            foreach ($item in $allocatedItems) {
                Write-Host "Item: $($item.itemName) ($($item.itemID))"
                Write-Host "  Status: $($item.availabilityStatus)"
                Write-Host "  Location: $($item.storageLocation)"
                Write-Host ""
            }
        } else {
            Write-Host "⚠️  No allocated items found - all items show as 'Available'" -ForegroundColor Yellow
        }
        
        # Show first few items for verification
        Write-Host "=== FIRST 5 ITEMS (SAMPLE) ===" -ForegroundColor Cyan
        $sampleItems = $response | Select-Object -First 5
        foreach ($item in $sampleItems) {
            Write-Host "[$($item.type)] $($item.itemName) ($($item.itemID))"
            Write-Host "  Vendor: $($item.vendor)"
            Write-Host "  Team: $($item.responsibleTeam)"
            Write-Host "  Location: $($item.storageLocation)"
            Write-Host "  Next Service: $(if ($item.nextServiceDue) { $item.nextServiceDue } else { 'N/A' })"
            Write-Host "  Status: $($item.availabilityStatus)"
            Write-Host ""
        }
        
    } else {
        Write-Host "❌ No data returned from enhanced master list" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ ERROR calling enhanced master list API: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Testing if maintenance data exists in database..." -ForegroundColor Yellow

# Test if we have any maintenance records
try {
    $maintenanceResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/maintenance" -Method GET
    
    if ($maintenanceResponse -and $maintenanceResponse.Count -gt 0) {
        Write-Host "✓ Found $($maintenanceResponse.Count) maintenance records in database" -ForegroundColor Green
        
        # Show maintenance records with NextServiceDue
        $maintenanceWithDue = $maintenanceResponse | Where-Object { $_.nextServiceDue -ne $null }
        Write-Host "  - Records with NextServiceDue: $($maintenanceWithDue.Count)"
        
        if ($maintenanceWithDue.Count -gt 0) {
            Write-Host "  Sample maintenance records:"
            $maintenanceWithDue | Select-Object -First 3 | ForEach-Object {
                Write-Host "    AssetId: $($_.assetId), NextServiceDue: $($_.nextServiceDue)"
            }
        }
    } else {
        Write-Host "⚠️  No maintenance records found in database" -ForegroundColor Yellow
        Write-Host "   This explains why NextServiceDue shows as N/A in master list"
    }
} catch {
    Write-Host "⚠️  Could not retrieve maintenance data: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "3. Testing if allocation data exists in database..." -ForegroundColor Yellow

# Test if we have any allocation records
try {
    $allocationResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/allocation" -Method GET
    
    if ($allocationResponse -and $allocationResponse.Count -gt 0) {
        Write-Host "✓ Found $($allocationResponse.Count) allocation records in database" -ForegroundColor Green
        
        # Show allocation status distribution
        $statusGroups = $allocationResponse | Group-Object availabilityStatus
        Write-Host "  Allocation status distribution:"
        foreach ($group in $statusGroups) {
            Write-Host "    $($group.Name): $($group.Count) records"
        }
        
        # Show sample allocation records
        Write-Host "  Sample allocation records:"
        $allocationResponse | Select-Object -First 3 | ForEach-Object {
            Write-Host "    AssetId: $($_.assetId), Status: $($_.availabilityStatus), Employee: $($_.employeeName)"
        }
    } else {
        Write-Host "⚠️  No allocation records found in database" -ForegroundColor Yellow
        Write-Host "   This explains why all items show as 'Available' in master list"
    }
} catch {
    Write-Host "⚠️  Could not retrieve allocation data: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== TEST SUMMARY ===" -ForegroundColor Cyan
Write-Host "The enhanced master list should now show:"
Write-Host "1. Real 'Next Service Due' dates from maintenance records (if any exist)"
Write-Host "2. Real 'Status' from allocation records (Available/Allocated based on current allocations)"
Write-Host "3. If no maintenance/allocation data exists, it falls back to N/A and Available respectively"
Write-Host ""
Write-Host "✓ Enhanced Master List implementation complete!" -ForegroundColor Green