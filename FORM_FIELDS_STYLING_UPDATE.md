# Form Fields Styling Update - Floating Labels

## Summary
Updated the form fields in the QC Template screen to use floating labels that sit on the border line, matching the Material Design pattern shown in the UI mockup.

## Changes Made

### 1. Floating Label Implementation
**Before:**
- Labels were positioned above the field as separate text
- Required manual spacing and alignment

**After:**
- Labels float on the border line using `labelText` property
- Automatic positioning and animation
- Clean, modern Material Design appearance

### 2. Label Styling
- Label text: 12px, gray color when unfocused
- Floating label: 12px, darker gray when focused/filled
- Red asterisk included in label text for required fields
- Smooth animation when field is focused or filled

### 3. Field Configuration

**Dropdown Fields (Validation type):**
```dart
DropdownButtonFormField(
  decoration: InputDecoration(
    labelText: 'Validation type *',
    labelStyle: TextStyle(fontSize: 12, color: gray),
    floatingLabelStyle: TextStyle(fontSize: 12, color: darkGray),
    // ... borders and styling
  ),
)
```

**Searchable Dropdown Fields (Final product, Material/Component):**
- Updated SearchableDropdown widget to support `labelText` parameter
- Wrapped with InputDecorator for proper floating label behavior
- Maintains search functionality with floating label

**Text Fields (Tools to quality check):**
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Tools to quality check *',
    labelStyle: TextStyle(fontSize: 12, color: gray),
    floatingLabelStyle: TextStyle(fontSize: 12, color: darkGray),
    // ... borders and styling
  ),
)
```

### 4. SearchableDropdown Widget Updates
- Added `labelText` parameter (optional)
- Wrapped content with `InputDecorator` for floating label support
- Removed custom border decoration (now handled by InputDecorator)
- Maintains all existing functionality (search, overlay, selection)

### 5. Visual Improvements
- **Empty state**: Label sits on top border in gray
- **Focused state**: Label moves up and changes to darker gray
- **Filled state**: Label stays up showing the field name
- **Consistent spacing**: All fields aligned properly
- **Professional appearance**: Matches Material Design guidelines

## Design Consistency
The form now uses the standard floating label pattern seen in:
- Material Design specifications
- Modern web applications
- Professional form interfaces

## Benefits
1. **Space efficient** - No need for separate label space above fields
2. **Clear context** - Label always visible even when field is filled
3. **Better UX** - Smooth animations provide visual feedback
4. **Consistent** - Matches expected behavior from other modern apps
5. **Accessible** - Proper label association for screen readers
