# Test script for Tools field functionality
# This tests creating a template with tools data

$baseUrl = "http://localhost:5000/api/quality"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Tools Field Functionality" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Create template with tools
Write-Host "Test 1: Creating template with tools data..." -ForegroundColor Yellow

$templateData = @{
    templateName = "Test Template with Tools"
    validationTypeId = 1
    finalProductId = 3
    materialId = 5
    toolsToQualityCheck = "Caliper, Micrometer, Thermometer"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/template" -Method Post -Body $templateData -ContentType "application/json"
    Write-Host "✓ Template created successfully!" -ForegroundColor Green
    Write-Host "  Template ID: $response" -ForegroundColor Gray
    $templateId = $response
} catch {
    Write-Host "✗ Failed to create template" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 2: Get all templates and verify tools field
Write-Host "Test 2: Retrieving templates to verify tools data..." -ForegroundColor Yellow

try {
    $templates = Invoke-RestMethod -Uri "$baseUrl/templates" -Method Get
    Write-Host "✓ Retrieved $($templates.Count) templates" -ForegroundColor Green
    
    # Find our test template
    $testTemplate = $templates | Where-Object { $_.qcTemplateId -eq $templateId }
    
    if ($testTemplate) {
        Write-Host "✓ Found test template" -ForegroundColor Green
        Write-Host "  Template Name: $($testTemplate.templateName)" -ForegroundColor Gray
        Write-Host "  Tools: $($testTemplate.toolsToQualityCheck)" -ForegroundColor Gray
        
        if ($testTemplate.toolsToQualityCheck -eq "Caliper, Micrometer, Thermometer") {
            Write-Host "✓ Tools field matches expected value!" -ForegroundColor Green
        } else {
            Write-Host "✗ Tools field does not match!" -ForegroundColor Red
            Write-Host "  Expected: Caliper, Micrometer, Thermometer" -ForegroundColor Red
            Write-Host "  Got: $($testTemplate.toolsToQualityCheck)" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ Could not find test template" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Failed to retrieve templates" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Open the QC Template screen in your app" -ForegroundColor White
Write-Host "2. Click on the test template" -ForegroundColor White
Write-Host "3. Verify the Tools field shows: Caliper, Micrometer, Thermometer" -ForegroundColor White
Write-Host "4. Create another template with different tools" -ForegroundColor White
Write-Host "5. Switch between templates and verify each shows its own tools" -ForegroundColor White
