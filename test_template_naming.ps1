# Test script to verify template naming convention
Write-Host "Testing Template Naming Convention..." -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:5069/api"

# Test 1: Get validation types
Write-Host "Test 1: GET /api/quality/validation-types" -ForegroundColor Yellow
try {
    $validationTypes = Invoke-RestMethod -Uri "$baseUrl/quality/validation-types" -Method Get -ContentType "application/json"
    Write-Host "Success! Found $($validationTypes.Count) validation types:" -ForegroundColor Green
    $validationTypes | ForEach-Object {
        Write-Host "  - ID: $($_.ValidationTypeId), Name: $($_.ValidationName)" -ForegroundColor White
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: Get final products
Write-Host "Test 2: GET /api/quality/final-products" -ForegroundColor Yellow
try {
    $products = Invoke-RestMethod -Uri "$baseUrl/quality/final-products" -Method Get -ContentType "application/json"
    Write-Host "Success! Found $($products.Count) final products:" -ForegroundColor Green
    $products | ForEach-Object {
        Write-Host "  - ID: $($_.FinalProductId), Name: $($_.ProductName)" -ForegroundColor White
    }
    
    # Store first product ID for next test
    $firstProductId = $products[0].FinalProductId
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    $firstProductId = 1
}

Write-Host ""

# Test 3: Get materials for a product
Write-Host "Test 3: GET /api/quality/materials/$firstProductId" -ForegroundColor Yellow
try {
    $materials = Invoke-RestMethod -Uri "$baseUrl/quality/materials/$firstProductId" -Method Get -ContentType "application/json"
    Write-Host "Success! Found $($materials.Count) materials for product $firstProductId:" -ForegroundColor Green
    $materials | ForEach-Object {
        Write-Host "  - ID: $($_.MaterialId), MSI Code: $($_.MSICode), Name: $($_.MaterialName)" -ForegroundColor White
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Create a test template with proper naming
Write-Host "Test 4: POST /api/quality/template (with auto-generated name)" -ForegroundColor Yellow
try {
    # Example: IG - Circuit Breaker - MSI-001 - Steel Sheet
    $templateData = @{
        templateName = "IG - Circuit Breaker - MSI-001 - Steel Sheet"
        validationTypeId = 1
        finalProductId = 1
        productName = "Circuit Breaker"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$baseUrl/quality/template" -Method Post -Body $templateData -ContentType "application/json"
    Write-Host "Success! Template created with ID: $($response.templateId)" -ForegroundColor Green
    Write-Host "Template Name: IG - Circuit Breaker - MSI-001 - Steel Sheet" -ForegroundColor Cyan
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 5: Get all templates to verify naming
Write-Host "Test 5: GET /api/quality/templates (verify naming convention)" -ForegroundColor Yellow
try {
    $templates = Invoke-RestMethod -Uri "$baseUrl/quality/templates" -Method Get -ContentType "application/json"
    Write-Host "Success! Found $($templates.Count) templates:" -ForegroundColor Green
    $templates | ForEach-Object {
        $name = $_.TemplateName
        Write-Host "  - ID: $($_.QCTemplateId)" -ForegroundColor White
        Write-Host "    Name: $name" -ForegroundColor White
        
        # Check if name follows convention
        if ($name -match "^(IG|IP|FI) - .+ - MSI-\d+ - .+$") {
            Write-Host "    ✓ Follows naming convention" -ForegroundColor Green
        } else {
            Write-Host "    ✗ Does NOT follow naming convention" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Expected Template Name Format:" -ForegroundColor Cyan
Write-Host "  {ValidationTypeCode} - {FinalProductName} - {MSICode} - {MaterialName}" -ForegroundColor White
Write-Host ""
Write-Host "Validation Type Codes:" -ForegroundColor Cyan
Write-Host "  IG = Incoming Goods Validation" -ForegroundColor White
Write-Host "  IP = In-progress Validation" -ForegroundColor White
Write-Host "  FI = Final Inspection" -ForegroundColor White
Write-Host ""
Write-Host "Test completed!" -ForegroundColor Cyan
