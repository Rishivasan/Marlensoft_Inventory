# Test script to verify delete API functionality
Write-Host "Testing Delete API functionality..." -ForegroundColor Green

# Test delete tool endpoint
$toolId = "TOOL001"  # Replace with an actual tool ID from your database
$deleteUrl = "https://localhost:7297/api/Tools/$toolId"

Write-Host "Testing DELETE $deleteUrl" -ForegroundColor Yellow

try {
    # Make DELETE request
    $response = Invoke-RestMethod -Uri $deleteUrl -Method DELETE -ContentType "application/json"
    Write-Host "Delete successful: $response" -ForegroundColor Green
} catch {
    Write-Host "Delete failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

# Test get tools to verify soft delete
$getUrl = "https://localhost:7297/api/tools"
Write-Host "`nTesting GET $getUrl to verify soft delete" -ForegroundColor Yellow

try {
    $tools = Invoke-RestMethod -Uri $getUrl -Method GET
    Write-Host "Found $($tools.Count) active tools" -ForegroundColor Green
    
    # Check if the deleted tool is still in the list
    $deletedTool = $tools | Where-Object { $_.toolsId -eq $toolId }
    if ($deletedTool) {
        Write-Host "ERROR: Deleted tool $toolId is still in the active list!" -ForegroundColor Red
    } else {
        Write-Host "SUCCESS: Deleted tool $toolId is not in the active list" -ForegroundColor Green
    }
} catch {
    Write-Host "Get tools failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTest completed." -ForegroundColor Green