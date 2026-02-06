# Test script to verify control point fix

Write-Host "=== Testing Control Point Fix ===" -ForegroundColor Cyan
Write-Host ""

# Check current control points in database
Write-Host "Step 1: Checking current control points in database..." -ForegroundColor Yellow
try {
    $controlPoints = Invoke-RestMethod -Uri "http://localhost:5069/api/quality/control-points/3" -Method Get
    Write-Host "Current control points for template 3:" -ForegroundColor Green
    $controlPoints | Format-Table -AutoSize
    $initialCount = $controlPoints.Count
    Write-Host "Initial count: $initialCount" -ForegroundColor Cyan
} catch {
    Write-Host "Error getting control points: $_" -ForegroundColor Red
    $initialCount = 0
}

Write-Host ""
Write-Host "Step 2: Now test by adding a control point through the UI..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Instructions:" -ForegroundColor Cyan
Write-Host "1. Open the frontend application" -ForegroundColor White
Write-Host "2. Go to Quality Check Customization screen" -ForegroundColor White
Write-Host "3. Select 'Untitled template' (or any template)" -ForegroundColor White
Write-Host "4. Click 'New Control Point' button" -ForegroundColor White
Write-Host "5. Fill in the form:" -ForegroundColor White
Write-Host "   - Control point name: Test UI Point" -ForegroundColor Gray
Write-Host "   - Type: Measure" -ForegroundColor Gray
Write-Host "   - Target value: 50" -ForegroundColor Gray
Write-Host "   - Unit: mm" -ForegroundColor Gray
Write-Host "   - Tolerance: 1" -ForegroundColor Gray
Write-Host "6. Click 'Add control point'" -ForegroundColor White
Write-Host ""
Write-Host "Press Enter after you've added the control point through the UI..." -ForegroundColor Yellow
Read-Host

Write-Host ""
Write-Host "Step 3: Checking if the control point was saved..." -ForegroundColor Yellow
try {
    $controlPoints = Invoke-RestMethod -Uri "http://localhost:5069/api/quality/control-points/3" -Method Get
    Write-Host "Control points after UI submission:" -ForegroundColor Green
    $controlPoints | Format-Table -AutoSize
    $finalCount = $controlPoints.Count
    Write-Host "Final count: $finalCount" -ForegroundColor Cyan
    
    if ($finalCount -gt $initialCount) {
        Write-Host ""
        Write-Host "SUCCESS! Control point was saved to database!" -ForegroundColor Green
        Write-Host "New control points added: $($finalCount - $initialCount)" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "FAILED: No new control points found in database" -ForegroundColor Red
        Write-Host "Check browser console for errors" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error getting control points: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
