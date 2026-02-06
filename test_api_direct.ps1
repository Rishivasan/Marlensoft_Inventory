$uri = "http://localhost:5069/api/enhanced-master-list"
$webClient = New-Object System.Net.WebClient
try {
    $result = $webClient.DownloadString($uri)
    Write-Host "SUCCESS: API call completed"
    Write-Host "Response length: $($result.Length) characters"
    if ($result.Length -lt 500) {
        Write-Host "Full response: $result"
    } else {
        Write-Host "Response preview: $($result.Substring(0, 500))..."
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)"
} finally {
    $webClient.Dispose()
}