# Horizontal Scroll Test Steps

## Current Implementation
- Container with fixed width: 1800px
- Nested SingleChildScrollView with horizontal scrolling
- DataTable with increased column widths
- Total column widths should exceed screen width

## Test Steps
1. Open the Flutter app
2. Navigate to "Tools, Assets, MMDs & Consumables Management" (sidebar item 6)
3. Look at the table - it should show data
4. Try to scroll horizontally on the table area
5. Verify that you can see additional columns when scrolling right

## Expected Columns (Left to Right)
1. Checkbox (50px)
2. Item ID (150px)
3. Type (120px)
4. Item Name (200px)
5. Vendor (180px)
6. Created Date (150px)
7. Responsible Team (180px)
8. Storage Location (180px)
9. Next Service Due (160px)
10. Availability Status (170px)
11. Action Arrow (50px)

**Total Width: ~1590px + spacing = ~1800px**

## If Still Not Working
The issue might be that DataTable has internal constraints that prevent horizontal scrolling.
Alternative solutions:
1. Use a custom Table widget
2. Use ListView.builder with Row widgets
3. Use a third-party data table package