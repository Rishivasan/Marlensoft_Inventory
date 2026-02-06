# Maintenance Service Next Due Date Flow

## Overview
This document explains the complete flow of how Next Service Due dates are managed when maintenance services are performed.

## Flow Diagram

```
Item Created → Next Service Due = Created Date + Maintenance Frequency
                        ↓
            (e.g., 2/2/2026 + Yearly = 2/2/2027)
                        ↓
        Service Person Opens "Add Maintenance Service" Form
                        ↓
        Service Date Field AUTO-POPULATES with 2/2/2027
                        ↓
        Next Service Due Field AUTO-CALCULATES: 2/2/2027 + Yearly = 2/2/2028
                        ↓
                Form Submitted
                        ↓
        Maintenance Record Saved with NextServiceDue = 2/2/2028
                        ↓
        Provider Updates Next Service Due to 2/2/2028
                        ↓
        ALL UI Components Update (Master List, Product Detail, etc.)
                        ↓
        Next Service → Service Date = 2/2/2028, Next Due = 2/2/2029
                        ↓
                    (Loop Continues)
```

## Implementation Details

### 1. Form Initialization (`add_maintenance_service.dart`)

When the "Add new maintenance service" form opens:

```dart
@override
void initState() {
  super.initState();
  _loadItemData(); // Fetch current next service due and maintenance frequency
}

Future<void> _loadItemData() async {
  // Get current next service due from provider
  final nextServiceDue = nextServiceProvider.getNextServiceDate(widget.assetId);
  
  // Get maintenance frequency from API
  final frequency = await nextServiceCalculationService.getMaintenanceFrequency(
    widget.assetId,
    widget.assetType
  );
  
  // Auto-populate Service Date with current Next Service Due
  if (nextServiceDue != null) {
    _serviceDateController.text = _formatDateForInput(nextServiceDue);
    // Auto-calculate Next Service Due Date
    _calculateNextServiceDue(nextServiceDue);
  }
}
```

### 2. Auto-Calculation Logic

When Service Date is selected or changed:

```dart
void _calculateNextServiceDue(DateTime serviceDate) {
  final frequency = _maintenanceFrequency!.toLowerCase().trim();
  DateTime? nextServiceDue;
  
  switch (frequency) {
    case 'daily': nextServiceDue = serviceDate.add(Duration(days: 1));
    case 'weekly': nextServiceDue = serviceDate.add(Duration(days: 7));
    case 'monthly': nextServiceDue = DateTime(serviceDate.year, serviceDate.month + 1, serviceDate.day);
    case 'quarterly': nextServiceDue = DateTime(serviceDate.year, serviceDate.month + 3, serviceDate.day);
    case 'half-yearly': nextServiceDue = DateTime(serviceDate.year, serviceDate.month + 6, serviceDate.day);
    case 'yearly': nextServiceDue = DateTime(serviceDate.year + 1, serviceDate.month, serviceDate.day);
    case '2nd year': nextServiceDue = DateTime(serviceDate.year + 2, serviceDate.month, serviceDate.day);
    case '3rd year': nextServiceDue = DateTime(serviceDate.year + 3, serviceDate.month, serviceDate.day);
    default: nextServiceDue = DateTime(serviceDate.year + 1, serviceDate.month, serviceDate.day);
  }
  
  _nextServiceDateController.text = _formatDateForInput(nextServiceDue);
}
```

### 3. Form Submission

When the form is submitted:

```dart
Future<void> _submitForm() async {
  // Save maintenance record to database
  await apiService.addMaintenanceRecord(maintenanceData);
  
  // Update provider (triggers UI updates everywhere)
  nextServiceProvider.updateNextServiceDate(widget.assetId, nextServiceDate);
  
  // Persist to database via API
  await nextServiceCalculationService.calculateNextServiceDateAfterMaintenance(
    assetId: widget.assetId,
    assetType: widget.assetType,
    serviceDate: serviceDate,
    maintenanceFrequency: _maintenanceFrequency,
  );
}
```

### 4. Provider Updates (`next_service_provider.dart`)

The provider manages next service dates and notifies all listeners:

```dart
class NextServiceProvider extends ChangeNotifier {
  final Map<String, DateTime?> _nextServiceDates = {};
  
  // Directly update next service date
  void updateNextServiceDate(String assetId, DateTime nextServiceDate) {
    _nextServiceDates[assetId] = nextServiceDate;
    notifyListeners(); // This triggers UI updates everywhere
  }
  
  // Get next service date for display
  DateTime? getNextServiceDate(String assetId) {
    return _nextServiceDates[assetId];
  }
}
```

### 5. UI Updates (`master_list.dart`, `product_detail_screen.dart`)

All UI components listen to the provider and update automatically:

```dart
Consumer(
  builder: (context, ref, child) {
    // Watch for reactive state changes
    final productState = ref.watch(productStateByIdProvider(item.assetId));
    
    // Use reactive state if available
    final nextServiceDue = productState?.nextServiceDue ?? item.nextServiceDue;
    
    return Text(nextServiceDue ?? "N/A");
  },
)
```

## Example Scenario

### Initial State
- **Item**: Tool TL001
- **Created Date**: 2/2/2026
- **Maintenance Frequency**: Yearly
- **Next Service Due**: 2/2/2027 (calculated on creation)

### First Service (2/2/2027)
1. Service person opens "Add Maintenance Service" form
2. **Service Date** auto-fills: 2/2/2027
3. **Next Service Due** auto-calculates: 2/2/2028
4. Form submitted → Database updated → Provider notified
5. Master list shows: Next Service Due = 2/2/2028

### Second Service (2/2/2028)
1. Service person opens form again
2. **Service Date** auto-fills: 2/2/2028
3. **Next Service Due** auto-calculates: 2/2/2029
4. Form submitted → Database updated → Provider notified
5. Master list shows: Next Service Due = 2/2/2029

### Loop Continues...
Each service automatically sets up the next service date, creating a continuous maintenance schedule.

## Key Features

✅ **Auto-Population**: Service Date automatically fills with current Next Service Due
✅ **Auto-Calculation**: Next Service Due automatically calculates based on Service Date + Frequency
✅ **Real-Time Updates**: Provider ensures all UI components update immediately
✅ **Persistent Storage**: Changes saved to database via API
✅ **Continuous Loop**: Each service sets up the next service date automatically

## Benefits

1. **No Manual Calculation**: Service person doesn't need to calculate dates
2. **Consistency**: Ensures maintenance schedule is followed correctly
3. **Real-Time Sync**: All screens show updated dates immediately
4. **Audit Trail**: Maintenance history tracks all service dates
5. **Automated Scheduling**: System manages the maintenance schedule automatically
