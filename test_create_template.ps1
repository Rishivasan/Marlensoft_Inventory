# Test creating a template

Write-Host "=== Testing Create Template API ===" -ForegroundColor Cyan
Write-Host ""

$templateData = @{
    templateName = "Test Template for Circuit Breaker"
    validationTypeId = 1
    finalProductId = 3
} | ConvertTo-Json

Write-Host "Sending request:" -ForegroundColor Yellow
Write-Host $templateData
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://localhost:5069/api/quality/template" `
        -Method Post `
        -Body $templateData `
        -ContentType "application/json" `
        -UseBasicParsing

    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "Error occurred:" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "Error Message: $_" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
