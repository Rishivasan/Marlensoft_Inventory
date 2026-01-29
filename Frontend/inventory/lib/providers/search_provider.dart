import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/model/maintenance_model.dart';
import 'package:inventory/model/allocation_model.dart';
import 'package:inventory/providers/master_list_provider.dart';
import 'package:inventory/providers/selection_provider.dart';

// Search query providers
final masterListSearchQueryProvider = StateProvider<String>((ref) => '');
final maintenanceSearchQueryProvider = StateProvider<String>((ref) => '');
final allocationSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered data providers - now uses sorted data
final filteredMasterListProvider = Provider<List<MasterListModel>>((ref) {
  final sortedMasterListAsync = ref.watch(sortedMasterListProvider);
  final searchQuery = ref.watch(masterListSearchQueryProvider);
  
  return sortedMasterListAsync.when(
    data: (items) {
      if (searchQuery.isEmpty) {
        return items;
      }
      
      return filterMasterListItems(items, searchQuery);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Extracted filter function for reusability
List<MasterListModel> filterMasterListItems(
  List<MasterListModel> items, 
  String query
) {
  if (query.isEmpty) return items;
  
  final searchQuery = query.toLowerCase();
  return items.where((item) {
    return item.assetId.toLowerCase().contains(searchQuery) ||
           item.name.toLowerCase().contains(searchQuery) ||
           item.type.toLowerCase().contains(searchQuery) ||
           item.itemType.toLowerCase().contains(searchQuery) ||
           item.supplier.toLowerCase().contains(searchQuery) ||
           item.location.toLowerCase().contains(searchQuery) ||
           item.responsibleTeam.toLowerCase().contains(searchQuery) ||
           item.availabilityStatus.toLowerCase().contains(searchQuery);
  }).toList();
}

// Search functionality for maintenance records
List<MaintenanceModel> filterMaintenanceRecords(
  List<MaintenanceModel> records, 
  String query
) {
  if (query.isEmpty) return records;
  
  final searchQuery = query.toLowerCase();
  return records.where((record) {
    return record.serviceProviderCompany.toLowerCase().contains(searchQuery) ||
           record.serviceEngineerName.toLowerCase().contains(searchQuery) ||
           record.serviceType.toLowerCase().contains(searchQuery) ||
           record.maintenanceStatus.toLowerCase().contains(searchQuery) ||
           record.responsibleTeam.toLowerCase().contains(searchQuery) ||
           (record.serviceNotes?.toLowerCase().contains(searchQuery) ?? false);
  }).toList();
}

// Search functionality for allocation records
List<AllocationModel> filterAllocationRecords(
  List<AllocationModel> records, 
  String query
) {
  if (query.isEmpty) return records;
  
  final searchQuery = query.toLowerCase();
  return records.where((record) {
    return record.employeeName.toLowerCase().contains(searchQuery) ||
           record.teamName.toLowerCase().contains(searchQuery) ||
           record.purpose.toLowerCase().contains(searchQuery) ||
           record.availabilityStatus.toLowerCase().contains(searchQuery) ||
           record.employeeId.toLowerCase().contains(searchQuery);
  }).toList();
}