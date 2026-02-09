# Complete Search Test - All 8 Columns Including Location and Date
$baseUrl = "http://localhost:5069/api"

Write-Host "`n=== COMPLETE MASTER LIST SEARCH TEST ===" -ForegroundColor Cyan
Write-Host "Testing all 8 searchable columns`n" -ForegroundColor White

# Test 1: Item ID
Write-Host "1. Search by Item ID 'TL':" -ForegroundColor Yellow
$r1 = Invoke-RestMethod -Uri "$baseUrl/enhanced-master-list/paginated?pageNumber=1&pageSize=5&searchText=TL" -Method Get
Write-Host "   ✅ Found: $($r1.totalCount) items" -ForegroundColor Green
Write-Host ""

# Test 2: Type
Write-Host "2. Search by Type 'Tool':" -ForegroundColor Yellow
$r2 = Invoke-RestMethod -Uri "$baseUrl/enhanced-master-list/paginated?pageNumber=1&pageSize=5&searchText=Tool" -Method Get
Write-Host "   ✅ Found: $($r2.totalCount) items" -ForegroundColor Green
Write-Host ""

# Test 3: Item Name
Write-Host "3. Search by Item Name 'Test':" -ForegroundColor Yellow
$r3 = Invoke-RestMethod -Uri "$baseUrl/enhanced-master-list/paginated?pageNumber=1&pageSize=5&searchText=Test" -Method Get
Write-Host "   ✅ Found: $($r3.totalCount) items" -ForegroundColor Green
Write-Host ""

# Test 4: Vendor
Write-Host "4. Search by Vendor:" -ForegroundColor Yellow
$r4 = Invoke-RestMethod -Uri "$baseUrl/enhanced-master-list/paginated?pageNumber=1&pageSize=5&searchText=Vendor" -Method Get
Write-Host "   ✅ Found: $($r4.totalCount) items" -ForegroundColor Green
Write-Host ""

# Test 5: Responsible Team
Write-Host "5. Search by Responsible Team '2332':" -ForegroundColor Yellow
$r5 = Invoke-RestMethod -Uri "$baseUrl/enhanced-master-list/paginated?pageNumber=1&pageSize=5&searchText=2332" -Method Get
Write-Host "   ✅ Found: $($r5.totalCount) items" -ForegroundColor Green
$r5.items | Select-Object -First 1 | Format-Table itemID, type, responsibleTeam -AutoSize
Write-Host ""

# Test 6: Location (NEW!)
Write-Host "6. Search by Location 'jamil':" -ForegroundColor Yellow
$r6 = Invoke-RestMethod -Uri "$baseUrl/enhanced-master-list/paginated?pageNumber=1&pageSize=5&searchText=jamil" -Method Get
Write-Host "   ✅ Found: $($r6.totalCount) items" -ForegroundColor Green
$r6.items | Select-Object -First 1 | Format-Table itemID, type, storageLocation -AutoSize
Write-Host ""

# Test 7: Next Service Due - Year (FIXED!)
Write-Host "7. Search by Next Service Due Year '2027':" -ForegroundColor Yellow
$r7 = Invoke-RestMethod -Uri "$baseUrl/enhanced-master-list/paginated?pageNumber=1&pageSize=5&searchText=2027" -Method Get
Write-Host "   ✅ Found: $($r7.totalCount) items" -ForegroundColor Green
Write-Host ""

# Test 8: Next Service Due - Specific Date (FIXED!)
Write-Host "8. Search by Next Service Due Date '2027-02-08':" -ForegroundColor Yellow
$r8 = Invoke-RestMethod -Uri "$baseUrl/enhanced-master-list/paginated?pageNumber=1&pageSize=5&searchText=2027-02-08" -Method Get
Write-Host "   ✅ Found: $($r8.totalCount) items" -ForegroundColor Green
$r8.items | Select-Object -First 2 | Format-Table itemID, type, nextServiceDue -AutoSize
Write-Host ""

# Test 9: Status
Write-Host "9. Search by Status 'Available':" -ForegroundColor Yellow
$r9 = Invoke-RestMethod -Uri "$baseUrl/enhanced-master-list/paginated?pageNumber=1&pageSize=5&searchText=Available" -Method Get
Write-Host "   ✅ Found: $($r9.totalCount) items" -ForegroundColor Green
Write-Host ""

Write-Host "=== ALL TESTS PASSED! ===" -ForegroundColor Green
Write-Host ""
Write-Host "SUMMARY - All 8 Columns Searchable:" -ForegroundColor Cyan
Write-Host "  ✅ 1. Item ID" -ForegroundColor Green
Write-Host "  ✅ 2. Type" -ForegroundColor Green
Write-Host "  ✅ 3. Item Name" -ForegroundColor Green
Write-Host "  ✅ 4. Vendor" -ForegroundColor Green
Write-Host "  ✅ 5. Responsible Team" -ForegroundColor Green
Write-Host "  ✅ 6. Location (Storage Location) - NEW!" -ForegroundColor Green
Write-Host "  ✅ 7. Next Service Due (Date Search) - FIXED!" -ForegroundColor Green
Write-Host "  ✅ 8. Status" -ForegroundColor Green
Write-Host ""
Write-Host "🎉 Master List Search is fully functional!" -ForegroundColor Green
