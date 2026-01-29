import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/model/maintenance_model.dart';
import 'package:inventory/model/allocation_model.dart';
import 'package:inventory/providers/sorting_provider.dart';

class SortingUtils {
  // Generic sorting function that works with any list type
  static List<T> sortList<T>(
    List<T> items,
    String? sortColumn,
    SortDirection direction,
    dynamic Function(T, String) valueExtractor,
  ) {
    if (sortColumn == null || direction == SortDirection.none) {
      return items;
    }

    List<T> sortedItems = List.from(items);

    sortedItems.sort((a, b) {
      dynamic aValue = valueExtractor(a, sortColumn);
      dynamic bValue = valueExtractor(b, sortColumn);

      // Handle null values - put them at the end
      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return 1;
      if (bValue == null) return -1;

      // Compare values
      int comparison;
      if (aValue is DateTime && bValue is DateTime) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        comparison = aValue.compareTo(bValue);
      } else {
        // Convert to string and compare (case-insensitive)
        String aStr = aValue.toString().toLowerCase();
        String bStr = bValue.toString().toLowerCase();
        comparison = aStr.compareTo(bStr);
      }

      // Apply sort direction
      return direction == SortDirection.ascending ? comparison : -comparison;
    });

    return sortedItems;
  }

  // Master List sorting
  static List<MasterListModel> sortMasterList(
    List<MasterListModel> items,
    String? sortColumn,
    SortDirection direction,
  ) {
    return sortList<MasterListModel>(items, sortColumn, direction, (item, column) {
      switch (column) {
        case 'itemId':
          return item.assetId;
        case 'type':
          return item.type;
        case 'itemName':
          return item.assetName;
        case 'vendor':
          return item.supplier;
        case 'createdDate':
          return item.createdDate;
        case 'responsibleTeam':
          return item.responsibleTeam;
        case 'storageLocation':
          return item.location;
        case 'nextServiceDue':
          return item.nextServiceDue;
        case 'availabilityStatus':
          return item.availabilityStatus;
        default:
          return '';
      }
    });
  }

  // Maintenance sorting
  static List<MaintenanceModel> sortMaintenanceList(
    List<MaintenanceModel> items,
    String? sortColumn,
    SortDirection direction,
  ) {
    return sortList<MaintenanceModel>(items, sortColumn, direction, (item, column) {
      switch (column) {
        case 'serviceDate':
          return item.serviceDate;
        case 'serviceProvider':
          return item.serviceProviderCompany;
        case 'serviceEngineer':
          return item.serviceEngineerName;
        case 'serviceType':
          return item.serviceType;
        case 'responsibleTeam':
          return item.responsibleTeam;
        case 'nextServiceDue':
          return item.nextServiceDue;
        case 'cost':
          return item.cost;
        case 'status':
          return item.maintenanceStatus;
        default:
          return '';
      }
    });
  }

  // Allocation sorting
  static List<AllocationModel> sortAllocationList(
    List<AllocationModel> items,
    String? sortColumn,
    SortDirection direction,
  ) {
    return sortList<AllocationModel>(items, sortColumn, direction, (item, column) {
      switch (column) {
        case 'issueDate':
          return item.issuedDate;
        case 'employeeName':
          return item.employeeName;
        case 'teamName':
          return item.teamName;
        case 'purpose':
          return item.purpose;
        case 'expectedReturnDate':
          return item.expectedReturnDate;
        case 'actualReturnDate':
          return item.actualReturnDate;
        case 'status':
          return item.availabilityStatus;
        default:
          return '';
      }
    });
  }

  static String getSortColumnDisplayName(String sortColumn) {
    switch (sortColumn) {
      // Master List columns
      case 'itemId':
        return 'Item ID';
      case 'type':
        return 'Type';
      case 'itemName':
        return 'Item Name';
      case 'vendor':
        return 'Vendor';
      case 'createdDate':
        return 'Created Date';
      case 'responsibleTeam':
        return 'Responsible Team';
      case 'storageLocation':
        return 'Storage Location';
      case 'nextServiceDue':
        return 'Next Service Due';
      case 'availabilityStatus':
        return 'Availability Status';
      
      // Maintenance columns
      case 'serviceDate':
        return 'Service Date';
      case 'serviceProvider':
        return 'Service Provider';
      case 'serviceEngineer':
        return 'Service Engineer';
      case 'serviceType':
        return 'Service Type';
      case 'cost':
        return 'Cost';
      case 'status':
        return 'Status';
      
      // Allocation columns
      case 'issueDate':
        return 'Issue Date';
      case 'employeeName':
        return 'Employee Name';
      case 'teamName':
        return 'Team Name';
      case 'purpose':
        return 'Purpose';
      case 'expectedReturnDate':
        return 'Expected Return Date';
      case 'actualReturnDate':
        return 'Actual Return Date';
      
      default:
        return sortColumn;
    }
  }

  static String getSortDirectionText(SortDirection direction) {
    switch (direction) {
      case SortDirection.ascending:
        return 'ascending';
      case SortDirection.descending:
        return 'descending';
      case SortDirection.none:
        return 'none';
    }
  }
}