# Test Script: Unique Template Per Material
# This script tests the duplicate prevention functionality

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Unique Template Per Material" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:5062/api"

# Test 1: Get existing templates
Write-Host "Test 1: Getting existing templates..." -ForegroundColor Yellow
try {
    $templates = Invoke-RestMethod -Uri "$baseUrl/Quality/templates" -Method Get
    Write-Host "✓ Found $($templates.Count) existing templates" -ForegroundColor Green
    
    if ($templates.Count -gt 0) {
        Write-Host ""
        Write-Host "Existing Templates:" -ForegroundColor Cyan
        foreach ($template in $templates) {
            Write-Host "  - ID: $($template.qcTemplateId), Material: $($template.materialId), Name: $($template.templateName)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "✗ Failed to get templates: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

# Test 2: Try to create duplicate template
if ($templates.Count -gt 0) {
    $existingTemplate = $templates[0]
    $materialId = $existingTemplate.materialId
    
    Write-Host "Test 2: Attempting to create duplicate template..." -ForegroundColor Yellow
    Write-Host "  Using MaterialId: $materialId (from existing template)" -ForegroundColor White
    Write-Host ""
    
    $duplicateTemplate = @{
        templateName = "DUPLICATE TEST - Should Fail"
        validationTypeId = 1
        finalProductId = 1
        materialId = $materialId
        productName = "Test Product"
        toolsToQualityCheck = "Test Tools"
    } | ConvertTo-Json
    
    try {
        $result = Invoke-RestMethod -Uri "$baseUrl/Quality/template" -Method Post -Body $duplicateTemplate -ContentType "application/json"
        Write-Host "✗ ERROR: Duplicate template was created (ID: $result)" -ForegroundColor Red
        Write-Host "  This should have been prevented!" -ForegroundColor Red
    } catch {
        $errorMessage = $_.Exception.Message
        if ($errorMessage -like "*already exists*") {
            Write-Host "✓ Duplicate prevention working correctly!" -ForegroundColor Green
            Write-Host "  Error: $errorMessage" -ForegroundColor Gray
        } else {
            Write-Host "✗ Unexpected error: $errorMessage" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Test 2: Skipped (no existing templates to test with)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

# Test 3: Create template with new material
Write-Host "Test 3: Creating template with new material..." -ForegroundColor Yellow

# Find an unused material ID (use a high number)
$newMaterialId = 9999

$newTemplate = @{
    templateName = "TEST - New Material Template"
    validationTypeId = 1
    finalProductId = 1
    materialId = $newMaterialId
    productName = "Test Product"
    toolsToQualityCheck = "Test Tools"
} | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri "$baseUrl/Quality/template" -Method Post -Body $newTemplate -ContentType "application/json"
    Write-Host "✓ Template created successfully with new material (ID: $result)" -ForegroundColor Green
    
    # Clean up - delete the test template
    Write-Host "  Cleaning up test template..." -ForegroundColor Gray
    # Note: Add delete endpoint if available
    
} catch {
    $errorMessage = $_.Exception.Message
    if ($errorMessage -like "*already exists*") {
        Write-Host "⚠ Material $newMaterialId already has a template" -ForegroundColor Yellow
        Write-Host "  Try running the test again with a different material ID" -ForegroundColor Gray
    } else {
        Write-Host "✗ Failed to create template: $errorMessage" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Expected Results:" -ForegroundColor White
Write-Host "  ✓ Test 1: Should list existing templates" -ForegroundColor Green
Write-Host "  ✓ Test 2: Should prevent duplicate (error message)" -ForegroundColor Green
Write-Host "  ✓ Test 3: Should allow new material template" -ForegroundColor Green
Write-Host ""
Write-Host "If all tests passed, the unique constraint is working!" -ForegroundColor Cyan
Write-Host ""
