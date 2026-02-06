# Test script to add a control point and verify it's saved to database

Write-Host "=== Testing Add Control Point Functionality ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Get a template ID first (we need this to add a control point)
Write-Host "Step 1: Getting available templates..." -ForegroundColor Yellow
try {
    $templatesResponse = Invoke-RestMethod -Uri "http://localhost:5062/api/quality/templates" -Method Get
    Write-Host "Available templates:" -ForegroundColor Green
    $templatesResponse | Format-Table -AutoSize
    
    if ($templatesResponse.Count -eq 0) {
        Write-Host "No templates found. Please create a template first." -ForegroundColor Red
        exit
    }
    
    $templateId = $templatesResponse[0].qcTemplateId
    Write-Host "Using Template ID: $templateId" -ForegroundColor Green
} catch {
    Write-Host "Error getting templates: $_" -ForegroundColor Red
    exit
}

Write-Host ""

# Step 2: Get control point types
Write-Host "Step 2: Getting control point types..." -ForegroundColor Yellow
try {
    $typesResponse = Invoke-RestMethod -Uri "http://localhost:5062/api/quality/control-point-types" -Method Get
    Write-Host "Available control point types:" -ForegroundColor Green
    $typesResponse | Format-Table -AutoSize
    
    $controlPointTypeId = $typesResponse[0].controlPointTypeId
    Write-Host "Using Control Point Type ID: $controlPointTypeId" -ForegroundColor Green
} catch {
    Write-Host "Error getting control point types: $_" -ForegroundColor Red
    exit
}

Write-Host ""

# Step 3: Add a new control point
Write-Host "Step 3: Adding new control point..." -ForegroundColor Yellow

$newControlPoint = @{
    qcTemplateId = $templateId
    controlPointTypeId = $controlPointTypeId
    controlPointName = "Test Measurement Point"
    targetValue = "100"
    unit = "mm"
    tolerance = "±2"
    instructions = "Measure the width at the center point"
    imagePath = ""
    sequenceOrder = 1
} | ConvertTo-Json

Write-Host "Sending data:" -ForegroundColor Cyan
Write-Host $newControlPoint

try {
    $addResponse = Invoke-RestMethod -Uri "http://localhost:5062/api/quality/control-point" `
        -Method Post `
        -Body $newControlPoint `
        -ContentType "application/json"
    
    Write-Host "Response: $addResponse" -ForegroundColor Green
    Write-Host "✓ Control point added successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error adding control point: $_" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    exit
}

Write-Host ""

# Step 4: Verify by getting control points for this template
Write-Host "Step 4: Verifying - Getting control points for template $templateId..." -ForegroundColor Yellow

try {
    $controlPoints = Invoke-RestMethod -Uri "http://localhost:5062/api/quality/control-points/$templateId" -Method Get
    Write-Host "Control points in database:" -ForegroundColor Green
    $controlPoints | Format-Table -AutoSize
    
    if ($controlPoints.Count -gt 0) {
        Write-Host "✓ SUCCESS: Control point was saved to database!" -ForegroundColor Green
    } else {
        Write-Host "✗ FAILED: No control points found in database" -ForegroundColor Red
    }
} catch {
    Write-Host "Error getting control points: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Now check your SQL Server Management Studio and refresh the QCControlPoint table to see the new record." -ForegroundColor Yellow
