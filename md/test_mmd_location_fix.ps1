# Test MMD location fix in enhanced master list
Write-Host "Testing MMD location fix..." -ForegroundColor Green

# Test 1: Check enhanced master list for MMD212 specifically
Write-Host "`n1. Testing enhanced master list for MMD212..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list" -Method GET
    
    # Find MMD212 specifically
    $mmd212 = $response | Where-Object { $_.itemID -eq "MMD212" }
    
    if ($mmd212) {
        Write-Host "✓ Found MMD212 in enhanced master list" -ForegroundColor Green
        Write-Host "MMD212 Details:" -ForegroundColor Cyan
        Write-Host "  ItemID: $($mmd212.itemID)" -ForegroundColor White
        Write-Host "  ItemName: $($mmd212.itemName)" -ForegroundColor White
        Write-Host "  Type: $($mmd212.type)" -ForegroundColor White
        Write-Host "  Vendor: $($mmd212.vendor)" -ForegroundColor White
        Write-Host "  StorageLocation: '$($mmd212.storageLocation)'" -ForegroundColor White
        Write-Host "  ResponsibleTeam: $($mmd212.responsibleTeam)" -ForegroundColor White
        Write-Host "  AvailabilityStatus: $($mmd212.availabilityStatus)" -ForegroundColor White
        
        if ($mmd212.storageLocation -and $mmd212.storageLocation.Trim() -ne "") {
            Write-Host "✅ SUCCESS: StorageLocation is populated!" -ForegroundColor Green
        } else {
            Write-Host "❌ ISSUE: StorageLocation is still empty" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ MMD212 not found in enhanced master list" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error testing enhanced master list: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Check all MMD items for location data
Write-Host "`n2. Checking all MMD items for location data..." -ForegroundColor Yellow
try {
    $mmdItems = $response | Where-Object { $_.type -eq "MMD" }
    Write-Host "Found $($mmdItems.Count) MMD items" -ForegroundColor Green
    
    $itemsWithLocation = $mmdItems | Where-Object { $_.storageLocation -and $_.storageLocation.Trim() -ne "" }
    $itemsWithoutLocation = $mmdItems | Where-Object { -not $_.storageLocation -or $_.storageLocation.Trim() -eq "" }
    
    Write-Host "MMD items WITH location: $($itemsWithLocation.Count)" -ForegroundColor Green
    Write-Host "MMD items WITHOUT location: $($itemsWithoutLocation.Count)" -ForegroundColor $(if ($itemsWithoutLocation.Count -eq 0) { "Green" } else { "Red" })
    
    if ($itemsWithLocation.Count -gt 0) {
        Write-Host "`nSample MMD items with location:" -ForegroundColor Cyan
        $itemsWithLocation | Select-Object -First 3 | ForEach-Object {
            Write-Host "  $($_.itemID): '$($_.storageLocation)'" -ForegroundColor White
        }
    }
    
    if ($itemsWithoutLocation.Count -gt 0) {
        Write-Host "`nMMD items still missing location:" -ForegroundColor Red
        $itemsWithoutLocation | ForEach-Object {
            Write-Host "  $($_.itemID): (empty)" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "❌ Error analyzing MMD location data: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nLocation fix test completed." -ForegroundColor Green