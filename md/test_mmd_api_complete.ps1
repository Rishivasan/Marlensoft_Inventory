#!/usr/bin/env pwsh

Write-Host "Testing MMD V2 API with complete field mapping..." -ForegroundColor Green

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/v2/item-details/SIMPLE002/mmd" -Method GET -ContentType "application/json"
    
    Write-Host "✅ API Response received successfully!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10
    
    if ($response.hasDetailedData) {
        Write-Host "✅ Has detailed data: TRUE" -ForegroundColor Green
        Write-Host "Detailed data keys:" -ForegroundColor Yellow
        $response.detailedData.PSObject.Properties.Name | ForEach-Object { Write-Host "  - $_" }
    } else {
        Write-Host "❌ Has detailed data: FALSE" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Error calling API: $($_.Exception.Message)" -ForegroundColor Red
}