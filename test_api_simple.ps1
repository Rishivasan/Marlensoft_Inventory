$response = Invoke-WebRequest -Uri "http://localhost:5069/api/enhanced-master-list" -Method GET -UseBasicParsing
Write-Host "Status Code: $($response.StatusCode)"
Write-Host "Content Length: $($response.Content.Length)"
if ($response.Content.Length -lt 1000) {
    Write-Host "Response Content: $($response.Content)"
} else {
    Write-Host "Response Content (first 500 chars): $($response.Content.Substring(0, 500))..."
}