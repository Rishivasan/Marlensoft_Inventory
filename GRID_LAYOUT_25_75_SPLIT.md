# Grid Layout 25-75 Split Implementation

## Summary
Updated the QC Template screen to use a responsive 25-75 grid layout split between the sidebar and main content area, replacing the fixed-width sidebar.

## Changes Made

### 1. Sidebar Layout (25% width)
**Before:**
```dart
Container(
  width: 250,  // Fixed width
  child: Column(...)
)
```

**After:**
```dart
Expanded(
  flex: 25,  // 25% of available width
  child: Container(
    child: Column(...)
  )
)
```

### 2. Main Content Area (75% width)
**Before:**
```dart
Expanded(
  child: Container(...)  // Takes remaining space
)
```

**After:**
```dart
Expanded(
  flex: 75,  // 75% of available width
  child: Container(...)
)
```

### 3. Layout Structure
```
Row
├── Expanded (flex: 25) - Sidebar
│   └── Container
│       └── Column
│           ├── Add new template button
│           └── Templates list
│
└── Expanded (flex: 75) - Main Content
    └── Container
        └── Column
            ├── Basic Information
            └── QC control points configuration
```

### 4. Benefits of Flex-Based Layout

**Responsive Design:**
- Sidebar and main content scale proportionally
- Works on different screen sizes
- Maintains 25-75 ratio regardless of window size

**Consistent Proportions:**
- Sidebar always takes 25% of available width
- Main content always takes 75% of available width
- No fixed pixel widths that might look wrong on different screens

**Better Space Utilization:**
- On larger screens, both areas get more space
- On smaller screens, both areas shrink proportionally
- Content remains readable and accessible

### 5. Visual Impact

**Sidebar (25%):**
- Template list
- Add new template button
- Adequate space for template names
- Scrollable list when many templates exist

**Main Content (75%):**
- Form fields with proper spacing
- Control points configuration
- Buttons and actions
- More room for content and data entry

## Technical Details

**Flex Values:**
- `flex: 25` = 25% of parent width
- `flex: 75` = 75% of parent width
- Total flex: 100 (25 + 75)

**Calculation:**
- If screen width = 1200px
- Sidebar width = 1200 × 0.25 = 300px
- Main content width = 1200 × 0.75 = 900px

**Responsive Behavior:**
- Automatically adjusts to parent container size
- No media queries needed
- Works with Flutter's layout system

## Result
The screen now has a professional, balanced layout with the sidebar taking 25% and the main content taking 75% of the available width, providing optimal space for both navigation and data entry.
