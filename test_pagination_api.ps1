# Test Pagination API Endpoint
$baseUrl = "http://localhost:5069"

Write-Host "=== Testing Pagination API ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Get first page with 10 items
Write-Host "Test 1: Get first page (10 items)" -ForegroundColor Yellow
$response1 = Invoke-RestMethod -Uri "$baseUrl/api/enhanced-master-list/paginated?pageNumber=1&pageSize=10" -Method Get
Write-Host "Total Count: $($response1.totalCount)" -ForegroundColor Green
Write-Host "Page Number: $($response1.pageNumber)" -ForegroundColor Green
Write-Host "Page Size: $($response1.pageSize)" -ForegroundColor Green
Write-Host "Total Pages: $($response1.totalPages)" -ForegroundColor Green
Write-Host "Items Returned: $($response1.items.Count)" -ForegroundColor Green
Write-Host ""

# Test 2: Get second page
Write-Host "Test 2: Get second page (10 items)" -ForegroundColor Yellow
$response2 = Invoke-RestMethod -Uri "$baseUrl/api/enhanced-master-list/paginated?pageNumber=2&pageSize=10" -Method Get
Write-Host "Page Number: $($response2.pageNumber)" -ForegroundColor Green
Write-Host "Items Returned: $($response2.items.Count)" -ForegroundColor Green
Write-Host "First Item ID: $($response2.items[0].itemID)" -ForegroundColor Green
Write-Host ""

# Test 3: Get page with 20 items
Write-Host "Test 3: Get first page (20 items)" -ForegroundColor Yellow
$response3 = Invoke-RestMethod -Uri "$baseUrl/api/enhanced-master-list/paginated?pageNumber=1&pageSize=20" -Method Get
Write-Host "Page Size: $($response3.pageSize)" -ForegroundColor Green
Write-Host "Items Returned: $($response3.items.Count)" -ForegroundColor Green
Write-Host ""

# Test 4: Search with pagination
Write-Host "Test 4: Search for 'Tool' (first page, 10 items)" -ForegroundColor Yellow
$response4 = Invoke-RestMethod -Uri "$baseUrl/api/enhanced-master-list/paginated?pageNumber=1&pageSize=10&searchText=Tool" -Method Get
Write-Host "Total Count (filtered): $($response4.totalCount)" -ForegroundColor Green
Write-Host "Total Pages (filtered): $($response4.totalPages)" -ForegroundColor Green
Write-Host "Items Returned: $($response4.items.Count)" -ForegroundColor Green
Write-Host ""

# Test 5: Display sample item details
Write-Host "Test 5: Sample Item Details" -ForegroundColor Yellow
if ($response1.items.Count -gt 0) {
    $sampleItem = $response1.items[0]
    Write-Host "Item ID: $($sampleItem.itemID)" -ForegroundColor Cyan
    Write-Host "Type: $($sampleItem.type)" -ForegroundColor Cyan
    Write-Host "Name: $($sampleItem.itemName)" -ForegroundColor Cyan
    Write-Host "Vendor: $($sampleItem.vendor)" -ForegroundColor Cyan
    Write-Host "Location: $($sampleItem.storageLocation)" -ForegroundColor Cyan
    Write-Host "Responsible Team: $($sampleItem.responsibleTeam)" -ForegroundColor Cyan
    Write-Host "Next Service Due: $($sampleItem.nextServiceDue)" -ForegroundColor Cyan
    Write-Host "Status: $($sampleItem.availabilityStatus)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=== All Tests Completed ===" -ForegroundColor Green
