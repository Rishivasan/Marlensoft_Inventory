# Test Next Service Due Priority Fix
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Next Service Due Priority Fix" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:5069"

Write-Host "Test 1: Fetching Enhanced Master List..." -ForegroundColor Yellow
Write-Host "Expected: Items with maintenance history should show Next Service Due calculated from Latest Service Date" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/enhanced-master-list" -Method Get
    
    Write-Host "API call successful!" -ForegroundColor Green
    Write-Host "Total items fetched: $($response.Count)" -ForegroundColor Cyan
    Write-Host ""
    
    # Find MMD232
    $mmd232 = $response | Where-Object { $_.itemID -eq "MMD232" }
    
    if ($mmd232) {
        Write-Host "Found MMD232:" -ForegroundColor Green
        Write-Host "  Item ID: $($mmd232.itemID)" -ForegroundColor White
        Write-Host "  Item Name: $($mmd232.itemName)" -ForegroundColor White
        Write-Host "  Created Date: $($mmd232.createdDate)" -ForegroundColor White
        Write-Host "  Next Service Due: $($mmd232.nextServiceDue)" -ForegroundColor Yellow
        Write-Host ""
        
        if ($mmd232.nextServiceDue -like "*2026-12-08*") {
            Write-Host "PASS: Next Service Due is correctly calculated!" -ForegroundColor Green
            Write-Host "  Expected: 2026-12-08" -ForegroundColor Gray
            Write-Host "  Actual: $($mmd232.nextServiceDue)" -ForegroundColor Gray
        } else {
            Write-Host "FAIL: Next Service Due is NOT correct!" -ForegroundColor Red
            Write-Host "  Expected: 2026-12-08" -ForegroundColor Gray
            Write-Host "  Actual: $($mmd232.nextServiceDue)" -ForegroundColor Gray
        }
    } else {
        Write-Host "MMD232 not found in response" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Test 2: Checking item without maintenance history..." -ForegroundColor Yellow
    
    $newItem = $response | Where-Object { $_.itemID -eq "T999" }
    
    if ($newItem) {
        Write-Host "Found T999 (new item):" -ForegroundColor Green
        Write-Host "  Item ID: $($newItem.itemID)" -ForegroundColor White
        Write-Host "  Created Date: $($newItem.createdDate)" -ForegroundColor White
        Write-Host "  Next Service Due: $($newItem.nextServiceDue)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "This item should calculate from Created Date" -ForegroundColor Green
    } else {
        Write-Host "  T999 not found" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    $itemsWithNextService = $response | Where-Object { $_.nextServiceDue -ne $null }
    
    Write-Host "Total items with Next Service Due: $($itemsWithNextService.Count)" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Sample items:" -ForegroundColor White
    $itemsWithNextService | Select-Object -First 5 | ForEach-Object {
        Write-Host "  $($_.itemID) - Next Service: $($_.nextServiceDue)" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Check the backend console for DEBUG logs" -ForegroundColor Yellow
