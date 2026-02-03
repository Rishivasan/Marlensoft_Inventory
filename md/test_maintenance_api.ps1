# Test script to verify maintenance API
Write-Host "Testing Maintenance API..."

# Test if backend is running
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/maintenance/MMD001" -Method GET -TimeoutSec 5
    Write-Host "SUCCESS: API is responding"
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)"
} catch {
    Write-Host "ERROR: Cannot connect to backend API"
    Write-Host "Error details: $($_.Exception.Message)"
    
    # Check if port 5069 is in use
    $port5069 = netstat -ano | Select-String ":5069"
    if ($port5069) {
        Write-Host "Port 5069 is in use:"
        Write-Host $port5069
    } else {
        Write-Host "Port 5069 is not in use - backend may not be running"
    }
}

# Test allocation API
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5069/api/allocation/MMD001" -Method GET -TimeoutSec 5
    Write-Host "SUCCESS: Allocation API is responding"
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)"
} catch {
    Write-Host "ERROR: Cannot connect to allocation API"
    Write-Host "Error details: $($_.Exception.Message)"
}