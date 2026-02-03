# Test Status Filtering in Master List
Write-Host "Testing Status Filtering in Master List..." -ForegroundColor Green

# Test individual endpoints to see if they filter by Status
Write-Host "`n1. Testing Tools endpoint..." -ForegroundColor Yellow
try {
    $toolsResponse = Invoke-RestMethod -Uri "http://localhost:5069/api/tools" -Method GET -ContentType "application/json"
    Write-Host "Tools found: $($toolsResponse.Count)" -ForegroundColor Cyan
    if ($toolsResponse.Count -gt 0) {
        $statusCounts = $toolsResponse | Group-Object Status | Select-Object Name, Count
        Write-Host "Status distribution in Tools:" -ForegroundColor White
        $statusCounts | ForEach-Object { Write-Host "  Status $($_.Name): $($_.Count) items" }
    }
} catch {
    Write-Host "Error testing Tools endpoint: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2. Testing MMDs endpoint..." -ForegroundColor Yellow
try {
    $mmdsResponse = Invoke-RestMethod -Uri "http://localhost:5069/api/mmds" -Method GET -ContentType "application/json"
    Write-Host "MMDs found: $($mmdsResponse.Count)" -ForegroundColor Cyan
    if ($mmdsResponse.Count -gt 0) {
        $statusCounts = $mmdsResponse | Group-Object Status | Select-Object Name, Count
        Write-Host "Status distribution in MMDs:" -ForegroundColor White
        $statusCounts | ForEach-Object { Write-Host "  Status $($_.Name): $($_.Count) items" }
    }
} catch {
    Write-Host "Error testing MMDs endpoint: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3. Testing Assets/Consumables endpoint..." -ForegroundColor Yellow
try {
    $assetsResponse = Invoke-RestMethod -Uri "http://localhost:5069/api/assets-consumables" -Method GET -ContentType "application/json"
    Write-Host "Assets/Consumables found: $($assetsResponse.Count)" -ForegroundColor Cyan
    if ($assetsResponse.Count -gt 0) {
        $statusCounts = $assetsResponse | Group-Object Status | Select-Object Name, Count
        Write-Host "Status distribution in Assets/Consumables:" -ForegroundColor White
        $statusCounts | ForEach-Object { Write-Host "  Status $($_.Name): $($_.Count) items" }
    }
} catch {
    Write-Host "Error testing Assets/Consumables endpoint: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n4. Testing Enhanced Master List..." -ForegroundColor Yellow
try {
    $masterResponse = Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list" -Method GET -ContentType "application/json"
    Write-Host "Enhanced Master List items: $($masterResponse.Count)" -ForegroundColor Cyan
    
    # Group by type to see distribution
    $typeDistribution = $masterResponse | Group-Object Type | Select-Object Name, Count
    Write-Host "Type distribution in Enhanced Master List:" -ForegroundColor White
    $typeDistribution | ForEach-Object { Write-Host "  $($_.Name): $($_.Count) items" }
    
    # Check for duplicates (same ItemID appearing multiple times)
    $duplicates = $masterResponse | Group-Object ItemID | Where-Object { $_.Count -gt 1 }
    if ($duplicates.Count -gt 0) {
        Write-Host "`nDuplicate ItemIDs found:" -ForegroundColor Red
        $duplicates | ForEach-Object { 
            Write-Host "  $($_.Name): $($_.Count) occurrences" -ForegroundColor Red
        }
    } else {
        Write-Host "`nNo duplicate ItemIDs found." -ForegroundColor Green
    }
    
} catch {
    Write-Host "Error testing Enhanced Master List: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n5. Testing Regular Master List..." -ForegroundColor Yellow
try {
    $regularMasterResponse = Invoke-RestMethod -Uri "http://localhost:5069/api/master-list" -Method GET -ContentType "application/json"
    Write-Host "Regular Master List items: $($regularMasterResponse.Count)" -ForegroundColor Cyan
    
    # Group by type to see distribution
    $typeDistribution = $regularMasterResponse | Group-Object ItemType | Select-Object Name, Count
    Write-Host "Type distribution in Regular Master List:" -ForegroundColor White
    $typeDistribution | ForEach-Object { Write-Host "  $($_.Name): $($_.Count) items" }
    
} catch {
    Write-Host "Error testing Regular Master List: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nStatus filtering test completed!" -ForegroundColor Green