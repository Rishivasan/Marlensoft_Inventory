# Test script to verify templates API endpoint
Write-Host "Testing Templates API Endpoint..." -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:5069/api"

# Test 1: Get all templates
Write-Host "Test 1: GET /api/quality/templates" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/quality/templates" -Method Get -ContentType "application/json"
    Write-Host "Success! Found $($response.Count) templates:" -ForegroundColor Green
    $response | ForEach-Object {
        Write-Host "  - ID: $($_.QCTemplateId), Name: $($_.TemplateName), Product: $($_.ProductName)" -ForegroundColor White
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test completed!" -ForegroundColor Cyan
