# Allocation Date Validation Fix

## Issue
In the allocation form, users could select "Expected Return Date" and "Actual Return Date" that were before the "Issue Date", which doesn't make business sense. Items cannot be returned before they were issued.

## Business Logic
- **Issue Date**: When the item was issued/allocated to the employee
- **Expected Return Date**: When the item is expected to be returned
- **Actual Return Date**: When the item was actually returned
- **Rules**: 
  - Expected Return Date ≥ Issue Date (cannot be before)
  - Actual Return Date ≥ Issue Date (cannot be before)

## Solution Implemented

### 1. Calendar Date Range Validation
When opening the Expected Return Date or Actual Return Date picker:
- **Minimum Date**: Set to the Issue Date (if selected)
- **Effect**: User cannot select dates before the issue date in the calendar
- **Fallback**: If no issue date is selected, shows a message asking to select issue date first

### 2. Pre-Selection Validation
**Before opening the calendar for return dates:**
```dart
// Check if issue date is selected first
if ((isExpectedReturnDate || isActualReturnDate) && _issueDateController.text.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please select the issue date first'),
      backgroundColor: Colors.orange,
    ),
  );
  return;
}
```

### 3. Dynamic Date Range Adjustment
**When issue date exists:**
```dart
if (isExpectedReturnDate || isActualReturnDate) {
  if (_issueDateController.text.isNotEmpty) {
    try {
      final issueDate = DateTime.parse(_issueDateController.text);
      // Return dates must be on or after the issue date
      firstDate = issueDate;
      
      // If current date is before issue date, adjust to issue date
      if (initialDate.isBefore(issueDate)) {
        initialDate = issueDate;
      }
    } catch (e) {
      // Handle parsing errors gracefully
    }
  }
}
```

### 4. Form Validation
**Added comprehensive validators:**

**Expected Return Date:**
```dart
validator: (v) {
  if (v == null || v.isEmpty) {
    return "The field cannot be empty";
  }
  
  // Validate that expected return date is not before issue date
  if (_issueDateController.text.isNotEmpty) {
    try {
      final issueDate = DateTime.parse(_issueDateController.text);
      final expectedReturnDate = DateTime.parse(v);
      
      if (expectedReturnDate.isBefore(issueDate)) {
        return "Expected return date cannot be before issue date";
      }
    } catch (e) {
      return "Invalid date format";
    }
  }
  
  return null;
}
```

**Actual Return Date:**
```dart
validator: (v) {
  // Actual return date is optional, so only validate if it's not empty
  if (v != null && v.isNotEmpty) {
    // Validate that actual return date is not before issue date
    if (_issueDateController.text.isNotEmpty) {
      try {
        final issueDate = DateTime.parse(_issueDateController.text);
        final actualReturnDate = DateTime.parse(v);
        
        if (actualReturnDate.isBefore(issueDate)) {
          return "Actual return date cannot be before issue date";
        }
      } catch (e) {
        return "Invalid date format";
      }
    }
  }
  
  return null;
}
```

### 5. Auto-Cleanup on Issue Date Change
**When issue date is changed:**
```dart
if (isIssueDate) {
  // Check if expected return date is now invalid
  if (_expectedReturnDateController.text.isNotEmpty) {
    try {
      final expectedReturnDate = DateTime.parse(_expectedReturnDateController.text);
      if (expectedReturnDate.isBefore(picked)) {
        _expectedReturnDateController.clear();
        // Show notification
      }
    } catch (e) {
      // Handle parsing errors
    }
  }
  
  // Check if actual return date is now invalid
  if (_actualReturnDateController.text.isNotEmpty) {
    try {
      final actualReturnDate = DateTime.parse(_actualReturnDateController.text);
      if (actualReturnDate.isBefore(picked)) {
        _actualReturnDateController.clear();
        // Show notification
      }
    } catch (e) {
      // Handle parsing errors
    }
  }
}
```

## User Experience Flow

### Scenario 1: New Allocation Form
1. User opens allocation form
2. Tries to click "Expected return date" first
3. ❌ Gets message: "Please select the issue date first"
4. User selects issue date (e.g., 2026-02-10)
5. User clicks "Expected return date"
6. ✅ Calendar opens with minimum date = 2026-02-10
7. ✅ User can only select dates from 2026-02-10 onwards

### Scenario 2: Editing Issue Date
1. User has dates selected:
   - Issue date: 2026-02-10
   - Expected return: 2026-03-15
   - Actual return: 2026-03-20
2. User changes issue date to 2026-04-01
3. ✅ System automatically clears both return dates as they're now invalid
4. ✅ User gets notifications about the changes
5. User selects new return dates ≥ 2026-04-01

### Scenario 3: Form Validation
1. User manually enters dates:
   - Issue date: 2026-02-10
   - Expected return: 2026-01-15 (before issue date)
2. User tries to submit form
3. ❌ Gets validation error: "Expected return date cannot be before issue date"
4. User must fix the date before submission

### Scenario 4: Optional Actual Return Date
1. User fills issue date and expected return date
2. Leaves actual return date empty
3. ✅ Form validates successfully (actual return is optional)
4. If user later fills actual return date with invalid date
5. ❌ Gets validation error if it's before issue date

## Benefits

### Business Logic Enforcement
- ✅ Prevents illogical allocation scheduling
- ✅ Ensures data integrity in allocation tracking
- ✅ Follows real-world asset management workflows
- ✅ Maintains proper audit trail

### User Experience
- ✅ Clear error messages and guidance
- ✅ Proactive validation prevents errors
- ✅ Auto-cleanup maintains consistency
- ✅ Calendar restricts invalid selections
- ✅ Handles optional fields appropriately

### Data Quality
- ✅ Prevents invalid date combinations
- ✅ Maintains referential integrity
- ✅ Reduces data entry errors
- ✅ Improves allocation reporting accuracy

## Technical Implementation

### Files Modified
- `Frontend/inventory/lib/screens/add_forms/add_allocation.dart`

### Key Methods Updated
- `_selectDate()` - Added date range validation and field identification
- Expected Return Date validator - Added cross-field validation
- Actual Return Date validator - Added optional field validation with cross-field check
- Date selection logic - Added auto-cleanup functionality

### Validation Levels
1. **UI Level**: Calendar date range restriction
2. **Interaction Level**: Pre-selection validation messages  
3. **Form Level**: Field validators with error messages
4. **Logic Level**: Auto-cleanup on related field changes

### Field Relationships
```
Issue Date (Required)
    ↓
Expected Return Date (Required, ≥ Issue Date)
    ↓
Actual Return Date (Optional, ≥ Issue Date if provided)
```

This comprehensive validation ensures that allocation tracking follows proper business logic while providing excellent user experience and maintaining data integrity.