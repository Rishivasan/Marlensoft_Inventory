try {
    Write-Host "Testing debug endpoint..."
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/debug-next-service" -Method GET -ContentType "application/json"
    
    Write-Host "=== DEBUG RESPONSE ==="
    Write-Host "Total Items: $($response.TotalItems)"
    Write-Host "Message: $($response.Message)"
    Write-Host ""
    Write-Host "=== SAMPLE DATA ==="
    
    foreach ($item in $response.DebugSample) {
        Write-Host "Item: $($item.ItemID) - $($item.ItemName)"
        Write-Host "  Type: $($item.Type)"
        Write-Host "  Created: $($item.CreatedDate)"
        Write-Host "  Next Service: $($item.NextServiceDue)"
        Write-Host "  Days Difference: $($item.DaysDifference)"
        Write-Host "  Is Calculated: $($item.IsCalculated)"
        Write-Host "  ---"
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    Write-Host "Response: $($_.Exception.Response)"
}