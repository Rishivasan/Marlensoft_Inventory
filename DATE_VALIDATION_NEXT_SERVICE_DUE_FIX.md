# Next Service Due Date Validation Fix

## Issue
In the maintenance service form, users could select a "Next service due date" that was before the "Service date", which doesn't make business sense. The next service should always be scheduled on or after the current service was performed.

## Business Logic
- **Service Date**: When the current maintenance service was performed
- **Next Service Due Date**: When the next maintenance service should be performed
- **Rule**: Next Service Due Date ≥ Service Date (cannot be before)

## Solution Implemented

### 1. Calendar Date Range Validation
When opening the Next Service Due Date picker:
- **Minimum Date**: Set to the Service Date (if selected)
- **Effect**: User cannot select dates before the service date in the calendar
- **Fallback**: If no service date is selected, shows a message asking to select service date first

### 2. Pre-Selection Validation
**Before opening the calendar:**
```dart
// Check if service date is selected first
if (!isServiceDate && _serviceDateController.text.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please select the service date first'),
      backgroundColor: Colors.orange,
    ),
  );
  return;
}
```

### 3. Dynamic Date Range Adjustment
**When service date exists:**
```dart
if (_serviceDateController.text.isNotEmpty) {
  try {
    final serviceDate = DateTime.parse(_serviceDateController.text);
    // Next service due must be on or after the service date
    firstDate = serviceDate;
    
    // If current date is before service date, adjust to service date
    if (initialDate.isBefore(serviceDate)) {
      initialDate = serviceDate;
    }
  } catch (e) {
    // Handle parsing errors gracefully
  }
}
```

### 4. Form Validation
**Added comprehensive validator:**
```dart
validator: (v) {
  if (v == null || v.isEmpty) {
    return "The field cannot be empty";
  }
  
  // Validate that next service due is not before service date
  if (_serviceDateController.text.isNotEmpty) {
    try {
      final serviceDate = DateTime.parse(_serviceDateController.text);
      final nextServiceDate = DateTime.parse(v);
      
      if (nextServiceDate.isBefore(serviceDate)) {
        return "Next service due cannot be before service date";
      }
    } catch (e) {
      return "Invalid date format";
    }
  }
  
  return null;
}
```

### 5. Auto-Cleanup on Service Date Change
**When service date is changed:**
```dart
if (isServiceDate) {
  // Check if next service due date is now invalid
  if (_nextServiceDateController.text.isNotEmpty) {
    try {
      final nextServiceDate = DateTime.parse(_nextServiceDateController.text);
      if (nextServiceDate.isBefore(picked)) {
        // Clear the invalid next service due date
        _nextServiceDateController.clear();
        
        // Inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Next service due date cleared as it was before the new service date'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      // Handle parsing errors
    }
  }
}
```

## User Experience Flow

### Scenario 1: New Form
1. User opens maintenance service form
2. Tries to click "Next service due date" first
3. ❌ Gets message: "Please select the service date first"
4. User selects service date (e.g., 2030-02-10)
5. User clicks "Next service due date"
6. ✅ Calendar opens with minimum date = 2030-02-10
7. ✅ User can only select dates from 2030-02-10 onwards

### Scenario 2: Editing Service Date
1. User has both dates selected:
   - Service date: 2030-02-10
   - Next service due: 2030-03-15
2. User changes service date to 2030-04-01
3. ✅ System automatically clears next service due (2030-03-15) as it's now invalid
4. ✅ User gets notification about the change
5. User selects new next service due date ≥ 2030-04-01

### Scenario 3: Form Validation
1. User manually enters dates or uses copy/paste
2. Service date: 2030-02-10
3. Next service due: 2030-01-15 (before service date)
4. User tries to submit form
5. ❌ Gets validation error: "Next service due cannot be before service date"
6. User must fix the date before submission

## Benefits

### Business Logic Enforcement
- ✅ Prevents illogical maintenance scheduling
- ✅ Ensures data integrity
- ✅ Follows real-world maintenance workflows

### User Experience
- ✅ Clear error messages and guidance
- ✅ Proactive validation prevents errors
- ✅ Auto-cleanup maintains consistency
- ✅ Calendar restricts invalid selections

### Data Quality
- ✅ Prevents invalid date combinations
- ✅ Maintains referential integrity
- ✅ Reduces data entry errors
- ✅ Improves reporting accuracy

## Technical Implementation

### Files Modified
- `Frontend/inventory/lib/screens/add_forms/add_maintenance_service.dart`

### Key Methods Updated
- `_selectDate()` - Added date range validation and user messaging
- Next Service Due Date validator - Added cross-field validation
- Date selection logic - Added auto-cleanup functionality

### Validation Levels
1. **UI Level**: Calendar date range restriction
2. **Interaction Level**: Pre-selection validation messages  
3. **Form Level**: Field validator with error messages
4. **Logic Level**: Auto-cleanup on related field changes

This comprehensive validation ensures that maintenance service scheduling follows proper business logic while providing excellent user experience.