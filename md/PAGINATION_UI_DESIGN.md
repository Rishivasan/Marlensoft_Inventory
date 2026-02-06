# Pagination UI Design Specification

## Design Overview

The pagination UI follows modern web application patterns with a clean, professional appearance that matches your existing design system.

## Layout Structure

```
┌────────────────────────────────────────────────────────────────────────────┐
│                          MASTER LIST SCREEN                                │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  ┌──────────────────────────────────────────────────────────────────────┐ │
│  │  HEADER SECTION                                                      │ │
│  │  ┌────────────────────────────────────────────────────────────────┐ │ │
│  │  │  Tools, Assets, MMDs & Consumables Management                  │ │ │
│  │  │                                                                 │ │ │
│  │  │  [Search items...] [Search] [Delete] [Export] [Add new Item]  │ │ │
│  │  └────────────────────────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────────────────────────┘ │
│                                                                            │
│  ┌──────────────────────────────────────────────────────────────────────┐ │
│  │  TABLE SECTION                                                       │ │
│  │  ┌────────────────────────────────────────────────────────────────┐ │ │
│  │  │ ☐ │ Item ID │ Type │ Item Name │ Supplier │ Location │ ... │→│ │ │
│  │  ├────────────────────────────────────────────────────────────────┤ │ │
│  │  │ ☐ │ TL123   │ Tool │ Wrench    │ ACME     │ A1       │ ... │→│ │ │
│  │  │ ☐ │ AS456   │Asset │ Drill     │ XYZ      │ B2       │ ... │→│ │ │
│  │  │ ☐ │ MM789   │ MMD  │ Meter     │ ABC      │ C3       │ ... │→│ │ │
│  │  │ ...                                                             │ │ │
│  │  │ ☐ │ TL999   │ Tool │ Hammer    │ DEF      │ D4       │ ... │→│ │ │
│  │  └────────────────────────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────────────────────────┘ │
│                                                                            │
│  ┌──────────────────────────────────────────────────────────────────────┐ │
│  │  PAGINATION BAR                                                      │ │
│  │  ┌────────────────────────────────────────────────────────────────┐ │ │
│  │  │                                                                 │ │ │
│  │  │  Show [10▼] entries        [◀ 1 2 3 ... 15 ▶]    Page 1 of 15 │ │ │
│  │  │                                                                 │ │ │
│  │  └────────────────────────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────────────────────────┘ │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

## Pagination Bar Components

### 1. Page Size Selector (Left)

```
┌─────────────────────────┐
│ Show [10▼] entries      │
└─────────────────────────┘
```

**Specifications:**
- Label: "Show" (14px, #666666)
- Dropdown: 10, 20, 30, 50 options
- Background: #F7F7F7
- Border: 1px solid #E5E7EB
- Border radius: 6px
- Padding: 6px 12px
- Font size: 14px
- Label: "entries" (14px, #666666)

**Behavior:**
- Clicking dropdown shows options
- Selecting new size resets to page 1
- Triggers data refresh

### 2. Page Navigation (Center)

```
┌─────────────────────────────────────┐
│  [◀]  1  2  3  ...  15  [▶]        │
└─────────────────────────────────────┘
```

**Specifications:**

**Previous Button:**
- Icon: Chevron left (◀)
- Size: 32x32px
- Color: Black (enabled), #9CA3AF (disabled)
- Disabled when on first page

**Page Numbers:**
- Active page:
  - Background: #0066CC (blue)
  - Text color: White
  - Font weight: 600
  - Border: 1px solid #0066CC
- Inactive pages:
  - Background: Transparent
  - Text color: Black
  - Font weight: 400
  - Border: 1px solid #E5E7EB
- Padding: 6px 12px
- Border radius: 4px
- Margin: 4px between buttons

**Ellipsis:**
- Shows "..." when there are gaps
- Color: #9CA3AF
- Not clickable

**Next Button:**
- Icon: Chevron right (▶)
- Size: 32x32px
- Color: Black (enabled), #9CA3AF (disabled)
- Disabled when on last page

**Page Display Logic:**
- If total pages ≤ 7: Show all pages
- If total pages > 7: Show first, current ±1, last with ellipsis
- Examples:
  - 5 pages: `1 2 3 4 5`
  - 15 pages, page 1: `1 2 3 ... 15`
  - 15 pages, page 7: `1 ... 6 7 8 ... 15`
  - 15 pages, page 15: `1 ... 13 14 15`

### 3. Page Info (Right)

```
┌─────────────────┐
│ Page 1 of 15    │
└─────────────────┘
```

**Specifications:**
- Font size: 14px
- Color: #666666
- Format: "Page {current} of {total}"

## Color Palette

```
Primary Blue:    #0066CC  (Active elements, buttons)
Background:      #F7F7F7  (Dropdown, inactive elements)
Border:          #E5E7EB  (Borders, dividers)
Text Primary:    #000000  (Main text)
Text Secondary:  #666666  (Labels, info text)
Text Disabled:   #9CA3AF  (Disabled elements)
White:           #FFFFFF  (Active page text, backgrounds)
```

## Status Badges (In Table)

```
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  Available   │  │  Allocated   │  │   In Use     │
└──────────────┘  └──────────────┘  └──────────────┘
```

**Available:**
- Background: #D1FAE5 (light green)
- Text: #065F46 (dark green)

**Allocated:**
- Background: #FEF3C7 (light yellow)
- Text: #92400E (dark yellow)

**In Use:**
- Background: #FED7AA (light orange)
- Text: #9A3412 (dark orange)

**Overdue:**
- Background: #FEE2E2 (light red)
- Text: #991B1B (dark red)

**Specifications:**
- Padding: 4px 12px
- Border radius: 12px
- Font size: 12px
- Font weight: 500

## Responsive Behavior

### Desktop (> 1200px)
- Full pagination bar visible
- All page numbers shown (with ellipsis)
- Page size selector on left
- Page info on right

### Tablet (768px - 1200px)
- Compact pagination bar
- Fewer page numbers shown
- Page size selector remains
- Page info remains

### Mobile (< 768px)
- Minimal pagination
- Only prev/next buttons
- Current page indicator
- Page size selector in dropdown menu

## Interaction States

### Hover States
```
Button Hover:
- Background: Lighten by 10%
- Cursor: pointer
- Transition: 150ms ease

Page Number Hover (inactive):
- Background: #F9FAFB
- Border: #D1D5DB
- Cursor: pointer
```

### Active States
```
Button Active:
- Background: Darken by 10%
- Scale: 0.98
- Transition: 100ms ease

Page Number Active:
- Background: #0066CC
- Text: White
- Border: #0066CC
```

### Disabled States
```
Button Disabled:
- Color: #9CA3AF
- Cursor: not-allowed
- Opacity: 0.5
```

### Loading States
```
During Data Fetch:
- Show loading spinner overlay
- Disable all pagination controls
- Maintain current page display
```

## Accessibility

### Keyboard Navigation
- Tab: Navigate between controls
- Enter/Space: Activate button
- Arrow keys: Navigate page numbers
- Escape: Close dropdown

### Screen Reader Support
- ARIA labels for all buttons
- ARIA live region for page changes
- ARIA disabled for inactive buttons
- Semantic HTML structure

### Focus Indicators
- Visible focus ring: 2px solid #0066CC
- Focus offset: 2px
- Focus visible on all interactive elements

## Animation & Transitions

### Page Change
```
Duration: 300ms
Easing: ease-in-out
Effect: Fade out old data, fade in new data
```

### Dropdown Open/Close
```
Duration: 200ms
Easing: ease-out
Effect: Slide down/up with fade
```

### Button Interactions
```
Duration: 150ms
Easing: ease
Effect: Background color transition
```

## Empty States

### No Results
```
┌────────────────────────────────────┐
│                                    │
│         [📭 Icon]                  │
│                                    │
│      No items found                │
│                                    │
│  Try adjusting your search or      │
│  filters                           │
│                                    │
└────────────────────────────────────┘
```

### No Data
```
┌────────────────────────────────────┐
│                                    │
│         [📦 Icon]                  │
│                                    │
│      No items yet                  │
│                                    │
│  Click "Add new Item" to get       │
│  started                           │
│                                    │
└────────────────────────────────────┘
```

## Loading States

### Initial Load
```
┌────────────────────────────────────┐
│                                    │
│         [⏳ Spinner]               │
│                                    │
│      Loading items...              │
│                                    │
└────────────────────────────────────┘
```

### Page Change Load
```
┌────────────────────────────────────┐
│  [Semi-transparent overlay]        │
│         [⏳ Spinner]               │
│      Loading page 2...             │
└────────────────────────────────────┘
```

## Error States

### API Error
```
┌────────────────────────────────────┐
│                                    │
│         [⚠️ Icon]                  │
│                                    │
│      Failed to load items          │
│                                    │
│  Error: Connection timeout         │
│                                    │
│      [Retry Button]                │
│                                    │
└────────────────────────────────────┘
```

## Implementation Notes

### CSS Classes (if using web)
```css
.pagination-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  background: white;
  border-top: 1px solid #E5E7EB;
}

.page-size-selector {
  display: flex;
  align-items: center;
  gap: 8px;
}

.page-navigation {
  display: flex;
  align-items: center;
  gap: 4px;
}

.page-number {
  padding: 6px 12px;
  border: 1px solid #E5E7EB;
  border-radius: 4px;
  cursor: pointer;
  transition: all 150ms ease;
}

.page-number.active {
  background: #0066CC;
  color: white;
  border-color: #0066CC;
}

.page-info {
  font-size: 14px;
  color: #666666;
}
```

### Flutter Widgets
```dart
// Main container
Container(
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Page size selector
      // Page navigation
      // Page info
    ],
  ),
)
```

## Testing Checklist

- [ ] Page size selector works
- [ ] Previous button disabled on first page
- [ ] Next button disabled on last page
- [ ] Page numbers clickable
- [ ] Active page highlighted
- [ ] Ellipsis shows for large page counts
- [ ] Page info updates correctly
- [ ] Loading states display
- [ ] Error states display
- [ ] Empty states display
- [ ] Keyboard navigation works
- [ ] Screen reader announces changes
- [ ] Responsive on all screen sizes
- [ ] Animations smooth
- [ ] Colors match design system

This design specification ensures a consistent, accessible, and user-friendly pagination experience across your application.
