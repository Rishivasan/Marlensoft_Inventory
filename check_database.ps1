$query = @"
SELECT TOP 5 
    ToolsId, 
    ToolName, 
    CreatedDate, 
    MaintainanceFrequency, 
    NextServiceDue,
    DATEDIFF(DAY, CreatedDate, NextServiceDue) as DaysDifference
FROM ToolsMaster 
WHERE NextServiceDue IS NOT NULL
ORDER BY CreatedDate DESC
"@

sqlcmd -S RISHIVASAN-PC -d ManufacturingApp -U sa -P "Welcome@123" -Q $query