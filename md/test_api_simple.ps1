# Simple API test
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list" -Method GET
    $mmd212 = $response | Where-Object { $_.itemID -eq "MMD212" }
    if ($mmd212) {
        Write-Host "MMD212 StorageLocation: '$($mmd212.storageLocation)'"
    } else {
        Write-Host "MMD212 not found"
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}