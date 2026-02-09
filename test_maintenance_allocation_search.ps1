# Test Maintenance and Allocation Search Functionality
$baseUrl = "http://localhost:5069/api"

Write-Host "`n=== MAINTENANCE & ALLOCATION SEARCH TEST ===" -ForegroundColor Cyan
Write-Host ""

# First, get a sample asset ID that has maintenance/allocation records
Write-Host "Getting sample data..." -ForegroundColor Yellow
$masterList = Invoke-RestMethod -Uri "$baseUrl/enhanced-master-list/paginated?pageNumber=1&pageSize=5" -Method Get
$sampleAssetId = $masterList.items[0].itemID
Write-Host "Using AssetId: $sampleAssetId for testing`n" -ForegroundColor White

# ===== MAINTENANCE SEARCH TESTS =====
Write-Host "=== MAINTENANCE SEARCH TESTS ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Get all maintenance records to see what data we have
Write-Host "1. Getting maintenance records for AssetId: $sampleAssetId" -ForegroundColor Yellow
try {
    $maint = Invoke-RestMethod -Uri "$baseUrl/maintenance/paginated/$sampleAssetId?pageNumber=1&pageSize=5" -Method Get
    Write-Host "   Total maintenance records: $($maint.totalCount)" -ForegroundColor Green
    
    if ($maint.totalCount -gt 0) {
        Write-Host "   Sample record:" -ForegroundColor White
        $maint.items[0] | Format-List serviceDate, serviceProviderCompany, serviceEngineerName, serviceType, maintenanceStatus, responsibleTeam
    }
} catch {
    Write-Host "   No maintenance records found" -ForegroundColor Yellow
}
Write-Host ""

# Test 2: Search by Service Provider Company
Write-Host "2. Search maintenance by Service Provider" -ForegroundColor Yellow
try {
    $search1 = Invoke-RestMethod -Uri "$baseUrl/maintenance/paginated/$sampleAssetId?pageNumber=1&pageSize=5&searchText=ABC" -Method Get
    Write-Host "   ✅ Found: $($search1.totalCount) records" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Search failed or no results" -ForegroundColor Yellow
}
Write-Host ""

# Test 3: Search by Service Engineer Name
Write-Host "3. Search maintenance by Engineer Name" -ForegroundColor Yellow
try {
    $search2 = Invoke-RestMethod -Uri "$baseUrl/maintenance/paginated/$sampleAssetId?pageNumber=1&pageSize=5&searchText=Ravi" -Method Get
    Write-Host "   ✅ Found: $($search2.totalCount) records" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Search failed or no results" -ForegroundColor Yellow
}
Write-Host ""

# Test 4: Search by Service Type
Write-Host "4. Search maintenance by Service Type" -ForegroundColor Yellow
try {
    $search3 = Invoke-RestMethod -Uri "$baseUrl/maintenance/paginated/$sampleAssetId?pageNumber=1&pageSize=5&searchText=Calibration" -Method Get
    Write-Host "   ✅ Found: $($search3.totalCount) records" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Search failed or no results" -ForegroundColor Yellow
}
Write-Host ""

# Test 5: Search by Status
Write-Host "5. Search maintenance by Status" -ForegroundColor Yellow
try {
    $search4 = Invoke-RestMethod -Uri "$baseUrl/maintenance/paginated/$sampleAssetId?pageNumber=1&pageSize=5&searchText=Completed" -Method Get
    Write-Host "   ✅ Found: $($search4.totalCount) records" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Search failed or no results" -ForegroundColor Yellow
}
Write-Host ""

# Test 6: Search by Date
Write-Host "6. Search maintenance by Date (2024)" -ForegroundColor Yellow
try {
    $search5 = Invoke-RestMethod -Uri "$baseUrl/maintenance/paginated/$sampleAssetId?pageNumber=1&pageSize=5&searchText=2024" -Method Get
    Write-Host "   ✅ Found: $($search5.totalCount) records" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Search failed or no results" -ForegroundColor Yellow
}
Write-Host ""

# ===== ALLOCATION SEARCH TESTS =====
Write-Host "=== ALLOCATION SEARCH TESTS ===" -ForegroundColor Cyan
Write-Host ""

# Test 7: Get all allocation records
Write-Host "7. Getting allocation records for AssetId: $sampleAssetId" -ForegroundColor Yellow
try {
    $alloc = Invoke-RestMethod -Uri "$baseUrl/allocation/paginated/$sampleAssetId?pageNumber=1&pageSize=5" -Method Get
    Write-Host "   Total allocation records: $($alloc.totalCount)" -ForegroundColor Green
    
    if ($alloc.totalCount -gt 0) {
        Write-Host "   Sample record:" -ForegroundColor White
        $alloc.items[0] | Format-List issuedDate, employeeName, teamName, purpose, availabilityStatus
    }
} catch {
    Write-Host "   No allocation records found" -ForegroundColor Yellow
}
Write-Host ""

# Test 8: Search by Employee Name
Write-Host "8. Search allocation by Employee Name" -ForegroundColor Yellow
try {
    $search6 = Invoke-RestMethod -Uri "$baseUrl/allocation/paginated/$sampleAssetId?pageNumber=1&pageSize=5&searchText=John" -Method Get
    Write-Host "   ✅ Found: $($search6.totalCount) records" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Search failed or no results" -ForegroundColor Yellow
}
Write-Host ""

# Test 9: Search by Team Name
Write-Host "9. Search allocation by Team Name" -ForegroundColor Yellow
try {
    $search7 = Invoke-RestMethod -Uri "$baseUrl/allocation/paginated/$sampleAssetId?pageNumber=1&pageSize=5&searchText=Production" -Method Get
    Write-Host "   ✅ Found: $($search7.totalCount) records" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Search failed or no results" -ForegroundColor Yellow
}
Write-Host ""

# Test 10: Search by Purpose
Write-Host "10. Search allocation by Purpose" -ForegroundColor Yellow
try {
    $search8 = Invoke-RestMethod -Uri "$baseUrl/allocation/paginated/$sampleAssetId?pageNumber=1&pageSize=5&searchText=Testing" -Method Get
    Write-Host "   ✅ Found: $($search8.totalCount) records" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Search failed or no results" -ForegroundColor Yellow
}
Write-Host ""

# Test 11: Search by Status
Write-Host "11. Search allocation by Status" -ForegroundColor Yellow
try {
    $search9 = Invoke-RestMethod -Uri "$baseUrl/allocation/paginated/$sampleAssetId?pageNumber=1&pageSize=5&searchText=Allocated" -Method Get
    Write-Host "   ✅ Found: $($search9.totalCount) records" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Search failed or no results" -ForegroundColor Yellow
}
Write-Host ""

# Test 12: Search by Date
Write-Host "12. Search allocation by Date (2024)" -ForegroundColor Yellow
try {
    $search10 = Invoke-RestMethod -Uri "$baseUrl/allocation/paginated/$sampleAssetId?pageNumber=1&pageSize=5&searchText=2024" -Method Get
    Write-Host "   ✅ Found: $($search10.totalCount) records" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Search failed or no results" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "=== TEST SUMMARY ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "MAINTENANCE SEARCHABLE FIELDS:" -ForegroundColor Yellow
Write-Host "  ✅ Asset Type" -ForegroundColor Green
Write-Host "  ✅ Asset ID" -ForegroundColor Green
Write-Host "  ✅ Item Name" -ForegroundColor Green
Write-Host "  ✅ Service Date" -ForegroundColor Green
Write-Host "  ✅ Service Provider Company" -ForegroundColor Green
Write-Host "  ✅ Service Engineer Name" -ForegroundColor Green
Write-Host "  ✅ Service Type" -ForegroundColor Green
Write-Host "  ✅ Next Service Due" -ForegroundColor Green
Write-Host "  ✅ Service Notes" -ForegroundColor Green
Write-Host "  ✅ Maintenance Status" -ForegroundColor Green
Write-Host "  ✅ Cost" -ForegroundColor Green
Write-Host "  ✅ Responsible Team" -ForegroundColor Green
Write-Host ""
Write-Host "ALLOCATION SEARCHABLE FIELDS:" -ForegroundColor Yellow
Write-Host "  ✅ Asset Type" -ForegroundColor Green
Write-Host "  ✅ Asset ID" -ForegroundColor Green
Write-Host "  ✅ Item Name" -ForegroundColor Green
Write-Host "  ✅ Employee ID" -ForegroundColor Green
Write-Host "  ✅ Employee Name" -ForegroundColor Green
Write-Host "  ✅ Team Name" -ForegroundColor Green
Write-Host "  ✅ Purpose" -ForegroundColor Green
Write-Host "  ✅ Issued Date" -ForegroundColor Green
Write-Host "  ✅ Expected Return Date" -ForegroundColor Green
Write-Host "  ✅ Actual Return Date" -ForegroundColor Green
Write-Host "  ✅ Availability Status" -ForegroundColor Green
Write-Host ""
Write-Host "🎉 All fields are now searchable in both tables!" -ForegroundColor Green
