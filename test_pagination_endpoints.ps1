# Test Server-Side Pagination Endpoints for Maintenance and Allocation

Write-Host "=== Testing Maintenance Pagination Endpoint ===" -ForegroundColor Cyan

# Test 1: Basic pagination
Write-Host "`n1. Testing basic pagination (page 1, size 5)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/maintenance/paginated/MMD3232?pageNumber=1&pageSize=5" -Method Get
    Write-Host "✓ Success!" -ForegroundColor Green
    Write-Host "  Total Count: $($response.totalCount)" -ForegroundColor White
    Write-Host "  Page Number: $($response.pageNumber)" -ForegroundColor White
    Write-Host "  Page Size: $($response.pageSize)" -ForegroundColor White
    Write-Host "  Total Pages: $($response.totalPages)" -ForegroundColor White
    Write-Host "  Items Count: $($response.items.Count)" -ForegroundColor White
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}

# Test 2: With search
Write-Host "`n2. Testing with search (searchText='calibration')..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/maintenance/paginated/MMD3232?pageNumber=1&pageSize=5&searchText=calibration" -Method Get
    Write-Host "✓ Success!" -ForegroundColor Green
    Write-Host "  Total Count: $($response.totalCount)" -ForegroundColor White
    Write-Host "  Items Count: $($response.items.Count)" -ForegroundColor White
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}

# Test 3: With sorting
Write-Host "`n3. Testing with sorting (sortColumn='serviceDate', sortDirection='DESC')..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/maintenance/paginated/MMD3232?pageNumber=1&pageSize=5&sortColumn=serviceDate&sortDirection=DESC" -Method Get
    Write-Host "✓ Success!" -ForegroundColor Green
    Write-Host "  Total Count: $($response.totalCount)" -ForegroundColor White
    Write-Host "  Items Count: $($response.items.Count)" -ForegroundColor White
    if ($response.items.Count -gt 0) {
        Write-Host "  First item service date: $($response.items[0].serviceDate)" -ForegroundColor White
    }
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}

# Test 4: Page 2
Write-Host "`n4. Testing page 2..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/maintenance/paginated/MMD3232?pageNumber=2&pageSize=5" -Method Get
    Write-Host "✓ Success!" -ForegroundColor Green
    Write-Host "  Page Number: $($response.pageNumber)" -ForegroundColor White
    Write-Host "  Items Count: $($response.items.Count)" -ForegroundColor White
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}

Write-Host "`n=== Testing Allocation Pagination Endpoint ===" -ForegroundColor Cyan

# Test 5: Basic pagination
Write-Host "`n5. Testing basic pagination (page 1, size 5)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/allocation/paginated/MMD3232?pageNumber=1&pageSize=5" -Method Get
    Write-Host "✓ Success!" -ForegroundColor Green
    Write-Host "  Total Count: $($response.totalCount)" -ForegroundColor White
    Write-Host "  Page Number: $($response.pageNumber)" -ForegroundColor White
    Write-Host "  Page Size: $($response.pageSize)" -ForegroundColor White
    Write-Host "  Total Pages: $($response.totalPages)" -ForegroundColor White
    Write-Host "  Items Count: $($response.items.Count)" -ForegroundColor White
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}

# Test 6: With search
Write-Host "`n6. Testing with search (searchText='production')..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/allocation/paginated/MMD3232?pageNumber=1&pageSize=5&searchText=production" -Method Get
    Write-Host "✓ Success!" -ForegroundColor Green
    Write-Host "  Total Count: $($response.totalCount)" -ForegroundColor White
    Write-Host "  Items Count: $($response.items.Count)" -ForegroundColor White
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}

# Test 7: With sorting
Write-Host "`n7. Testing with sorting (sortColumn='issuedDate', sortDirection='DESC')..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/allocation/paginated/MMD3232?pageNumber=1&pageSize=5&sortColumn=issuedDate&sortDirection=DESC" -Method Get
    Write-Host "✓ Success!" -ForegroundColor Green
    Write-Host "  Total Count: $($response.totalCount)" -ForegroundColor White
    Write-Host "  Items Count: $($response.items.Count)" -ForegroundColor White
    if ($response.items.Count -gt 0) {
        Write-Host "  First item issued date: $($response.items[0].issuedDate)" -ForegroundColor White
    }
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}

# Test 8: Different page size
Write-Host "`n8. Testing different page size (pageSize=10)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/allocation/paginated/MMD3232?pageNumber=1&pageSize=10" -Method Get
    Write-Host "✓ Success!" -ForegroundColor Green
    Write-Host "  Page Size: $($response.pageSize)" -ForegroundColor White
    Write-Host "  Items Count: $($response.items.Count)" -ForegroundColor White
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}

Write-Host "`n=== All Tests Completed ===" -ForegroundColor Cyan
Write-Host "`nNote: If tests fail, ensure:" -ForegroundColor Yellow
Write-Host "  1. Backend is running on http://localhost:5069" -ForegroundColor White
Write-Host "  2. Database has Maintenance and Allocation tables" -ForegroundColor White
Write-Host "  3. Test asset 'MMD3232' exists with records" -ForegroundColor White
