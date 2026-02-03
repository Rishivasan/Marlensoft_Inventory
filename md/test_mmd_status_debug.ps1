# Debug MMD Status issue - check if new MMD has correct Status
Write-Host "Debugging MMD Status issue..." -ForegroundColor Green

# Test 1: Check MMD API for Status values
Write-Host "`n1. Checking MMD API Status values..." -ForegroundColor Yellow
try {
    $mmdResponse = Invoke-RestMethod -Uri "http://localhost:5069/api/mmds" -Method GET
    Write-Host "✓ MMD API returned $($mmdResponse.Count) items" -ForegroundColor Green
    
    # Group by Status
    $statusGroups = $mmdResponse | Group-Object Status
    Write-Host "`nMMD Status distribution:" -ForegroundColor Cyan
    foreach ($group in $statusGroups) {
        Write-Host "  Status $($group.Name): $($group.Count) items" -ForegroundColor White
        
        # Show recent items for each status
        $recentItems = $group.Group | Sort-Object createdDate -Descending | Select-Object -First 2
        foreach ($item in $recentItems) {
            Write-Host "    - ID: $($item.mmdId), Brand: $($item.brandName), CalibrationStatus: $($item.calibrationStatus)" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "✗ Error checking MMD API: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Check Enhanced Master List for MMD items
Write-Host "`n2. Checking Enhanced Master List for MMD items..." -ForegroundColor Yellow
try {
    $masterResponse = Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list" -Method GET
    $mmdItems = $masterResponse | Where-Object { $_.type -eq "MMD" }
    
    Write-Host "✓ Enhanced Master List has $($mmdItems.Count) MMD items" -ForegroundColor Green
    
    if ($mmdItems.Count -gt 0) {
        Write-Host "`nRecent MMD items in Master List:" -ForegroundColor Cyan
        $mmdItems | Sort-Object createdDate -Descending | Select-Object -First 5 | ForEach-Object {
            Write-Host "  ID: $($_.itemID), Name: $($_.itemName), Vendor: $($_.vendor)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "✗ Error checking Enhanced Master List: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Compare counts
Write-Host "`n3. Comparing MMD counts..." -ForegroundColor Yellow
$mmdApiCount = ($mmdResponse | Where-Object { $_.status -eq $true }).Count
$masterListMmdCount = ($masterResponse | Where-Object { $_.type -eq "MMD" }).Count

Write-Host "MMD API (Status=true): $mmdApiCount items" -ForegroundColor White
Write-Host "Master List (MMD): $masterListMmdCount items" -ForegroundColor White

if ($mmdApiCount -ne $masterListMmdCount) {
    Write-Host "⚠️  MISMATCH DETECTED!" -ForegroundColor Red
    Write-Host "This suggests some MMD items have Status=false and are not appearing in Master List" -ForegroundColor Red
} else {
    Write-Host "✓ Counts match - no Status filtering issues" -ForegroundColor Green
}

Write-Host "`nDebugging completed." -ForegroundColor Green