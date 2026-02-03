# Test script to check database content and V2 API functionality

Write-Host "=== Testing Database Content and V2 API ===" -ForegroundColor Green

# Test 1: Check enhanced master list
Write-Host "`n1. Testing Enhanced Master List..." -ForegroundColor Yellow
try {
    $masterList = Invoke-RestMethod -Uri "http://localhost:5069/api/enhanced-master-list" -Method GET
    Write-Host "Found $($masterList.Count) items in master list" -ForegroundColor Green
    
    # Show first few items
    $masterList | Select-Object -First 5 | ForEach-Object {
        Write-Host "  - ItemID: $($_.ItemID), Name: $($_.ItemName), Type: $($_.Type)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Error getting master list: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Check Tools table
Write-Host "`n2. Testing Tools API..." -ForegroundColor Yellow
try {
    $tools = Invoke-RestMethod -Uri "http://localhost:5069/api/tools" -Method GET
    Write-Host "Found $($tools.Count) items in Tools table" -ForegroundColor Green
    
    # Show first few tools
    $tools | Select-Object -First 3 | ForEach-Object {
        Write-Host "  - ToolsId: $($_.ToolsId), Name: $($_.ToolName), Type: $($_.ToolType)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Error getting tools: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test V2 API with different items
Write-Host "`n3. Testing V2 API with various items..." -ForegroundColor Yellow

$testItems = @(
    @{id="SIMPLE002"; type="tool"},
    @{id="TL2324"; type="tool"},
    @{id="5555555"; type="mmd"}
)

foreach ($item in $testItems) {
    Write-Host "`nTesting V2 API for $($item.id) ($($item.type)):" -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:5069/api/v2/item-details/$($item.id)/$($item.type)" -Method GET
        Write-Host "  - ItemType: $($response.ItemType)" -ForegroundColor Green
        Write-Host "  - HasDetailedData: $($response.HasDetailedData)" -ForegroundColor Green
        
        if ($response.MasterData) {
            Write-Host "  - Master Data: ItemID=$($response.MasterData.ItemID), Name=$($response.MasterData.ItemName)" -ForegroundColor Green
        }
        
        if ($response.HasDetailedData -and $response.DetailedData) {
            $detailKeys = ($response.DetailedData | Get-Member -MemberType NoteProperty).Name
            Write-Host "  - Detailed Data Keys: $($detailKeys -join ', ')" -ForegroundColor Green
        } else {
            Write-Host "  - No detailed data available" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  - Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Green