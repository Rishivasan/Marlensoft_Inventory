# Test the add endpoints
Write-Host "Testing add endpoints..." -ForegroundColor Green

# Test MMD endpoint
$mmdData = @{
    MmdId = "TEST001"
    AccuracyClass = "Class A"
    Vendor = "Test Vendor"
    CalibratedBy = "Test Lab"
    Specifications = "Test Specs"
    ModelNumber = "TM001"
    SerialNumber = "SN001"
    Quantity = 1
    CalibrationCertNo = "CERT001"
    Location = "Test Location"
    PoNumber = "PO001"
    PoDate = "2024-01-01T00:00:00Z"
    InvoiceNumber = "INV001"
    InvoiceDate = "2024-01-01T00:00:00Z"
    TotalCost = 100.0
    CalibrationFrequency = "Yearly"
    LastCalibration = "2024-01-01T00:00:00Z"
    NextCalibration = "2025-01-01T00:00:00Z"
    WarrantyYears = 1
    CalibrationStatus = "Calibrated"
    ResponsibleTeam = "Test Team"
    ManualLink = "http://test.com"
    StockMsi = "MSI001"
    Remarks = "Test remarks"
    CreatedBy = "Test User"
    UpdatedBy = "Test User"
    CreatedDate = "2024-01-01T00:00:00Z"
    Status = $true
} | ConvertTo-Json

Write-Host "Testing MMD endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5070/api/addmmds" -Method POST -Body $mmdData -ContentType "application/json" -TimeoutSec 10
    Write-Host "SUCCESS: MMD endpoint working" -ForegroundColor Green
    Write-Host "Response: $response" -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: MMD endpoint failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`nTest completed." -ForegroundColor Green