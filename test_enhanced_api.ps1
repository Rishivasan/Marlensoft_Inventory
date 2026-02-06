try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list" -Method GET
    Write-Host "API Response received successfully!"
    Write-Host "Number of items: $($response.Count)"
    
    if ($response.Count -gt 0) {
        Write-Host "First item details:"
        $firstItem = $response[0]
        Write-Host "  ItemID: $($firstItem.ItemID)"
        Write-Host "  Type: $($firstItem.Type)"
        Write-Host "  ItemName: $($firstItem.ItemName)"
        Write-Host "  NextServiceDue: $($firstItem.NextServiceDue)"
        Write-Host "  AvailabilityStatus: $($firstItem.AvailabilityStatus)"
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}