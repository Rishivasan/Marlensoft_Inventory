# PowerShell script to fix remaining ref usage issues
$filePath = "Frontend/inventory/lib/screens/product_detail_screen.dart"
$content = Get-Content $filePath -Raw

# Replace the specific patterns
$content = $content -replace 'await ref\.read\(forceRefreshMasterListProvider\)\(\);', 'await _safeRefreshMasterList();'

# Write back to file
Set-Content $filePath $content -NoNewline

Write-Host "Fixed all remaining ref usage issues in product_detail_screen.dart"