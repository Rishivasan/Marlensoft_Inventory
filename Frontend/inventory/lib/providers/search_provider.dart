import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/model/maintenance_model.dart';
import 'package:inventory/model/allocation_model.dart';
import 'package:inventory/providers/master_list_provider.dart';

// Search query providers
final masterListSearchQueryProvider = StateProvider<String>((ref) => '');
final maintenanceSearchQueryProvider = StateProvider<String>((ref) => '');
final allocationSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered data providers
final filteredMasterListProvider = Provider<List<MasterListModel>>((ref) {
  final masterListAsync = ref.watch(masterListProvider);
  final searchQuery = ref.watch(masterListSearchQueryProvider);
  
  return masterListAsync.when(
    data: (items) {
      if (searchQuery.isEmpty) {
        return items;
      }
      
      final query = searchQuery.toLowerCase();
      return items.where((item) {
        return item.assetId.toLowerCase().contains(query) ||
               item.name.toLowerCase().contains(query) ||
               item.type.toLowerCase().contains(query) ||
               item.itemType.toLowerCase().contains(query) ||
               item.supplier.toLowerCase().contains(query) ||
               item.location.toLowerCase().contains(query) ||
               item.responsibleTeam.toLowerCase().contains(query) ||
               item.availabilityStatus.toLowerCase().contains(query);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

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