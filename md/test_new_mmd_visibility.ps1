# Test if newly created MMD items are visible in the API and UI
Write-Host "Testing newly created MMD visibility..." -ForegroundColor Green

# Test 1: Check enhanced master list API
Write-Host "`n1. Testing enhanced master list API..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list" -Method GET
    
    Write-Host "✓ Enhanced master list returned $($response.Count) items" -ForegroundColor Green
    
    # Filter MMD items
    $mmdItems = $response | Where-Object { $_.type -eq "MMD" }
    Write-Host "✓ Found $($mmdItems.Count) MMD items in master list" -ForegroundColor Green
    
    if ($mmdItems.Count -gt 0) {
        Write-Host "`nRecent MMD items:" -ForegroundColor Cyan
        $mmdItems | Sort-Object createdDate -Descending | Select-Object -First 3 | ForEach-Object {
            Write-Host "  ID: $($_.itemID), Name: $($_.itemName), Vendor: $($_.vendor), Created: $($_.createdDate)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "✗ Error testing enhanced master list: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Check MMD API directly
Write-Host "`n2. Testing MMD API directly..." -ForegroundColor Yellow
try {
    $mmdResponse = Invoke-RestMethod -Uri "http://localhost:5069/api/mmds" -Method GET
    Write-Host "✓ MMD API returned $($mmdResponse.Count) items" -ForegroundColor Green
    
    if ($mmdResponse.Count -gt 0) {
        Write-Host "`nRecent MMD items from MMD API:" -ForegroundColor Cyan
        $mmdResponse | Sort-Object createdDate -Descending | Select-Object -First 3 | ForEach-Object {
            Write-Host "  ID: $($_.mmdId), Brand: $($_.brandName), Vendor: $($_.vendor), Status: $($_.status)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "✗ Error testing MMD API: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Check MasterRegister table
Write-Host "`n3. Checking MasterRegister table for MMD entries..." -ForegroundColor Yellow
try {
    # This would require database access - showing what to check
    Write-Host "To check database directly, run this SQL:" -ForegroundColor Cyan
    Write-Host "SELECT TOP 5 * FROM MasterRegister WHERE ItemType = 'MMD' ORDER BY CreatedDate DESC;" -ForegroundColor White
    Write-Host "SELECT TOP 5 * FROM MmdsMaster WHERE Status = 1 ORDER BY CreatedDate DESC;" -ForegroundColor White
} catch {
    Write-Host "Database check would require SQL access" -ForegroundColor Yellow
}

Write-Host "`nTest completed. Check if your new MMD appears in the lists above." -ForegroundColor Green