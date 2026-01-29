// Test script to verify Excel export functionality
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/services/export_service.dart';

void main() async {
  print('🔥 Testing Excel Export Functionality');
  
  // Create sample data
  List<MasterListModel> sampleItems = [
    MasterListModel(
      sno: 1,
      itemType: 'Tool',
      refId: 'TOOL001',
      assetId: 'TOOL001',
      type: 'Measuring',
      name: 'Digital Caliper',
      supplier: 'Mitutoyo',
      location: 'Workshop A',
      createdDate: DateTime(2024, 1, 15),
      responsibleTeam: 'Production Team A',
      nextServiceDue: DateTime(2024, 6, 15),
      availabilityStatus: 'Available',
    ),
    MasterListModel(
      sno: 2,
      itemType: 'Asset',
      refId: 'ASSET001',
      assetId: 'ASSET001',
      type: 'Equipment',
      name: 'CNC Machine',
      supplier: 'Haas Automation',
      location: 'Production Floor',
      createdDate: DateTime(2024, 2, 10),
      responsibleTeam: 'Production Team B',
      nextServiceDue: DateTime(2024, 8, 10),
      availabilityStatus: 'In Use',
    ),
    MasterListModel(
      sno: 3,
      itemType: 'MMD',
      refId: 'MMD001',
      assetId: 'MMD001',
      type: 'Monitoring',
      name: 'Temperature Sensor',
      supplier: 'Fluke',
      location: 'Quality Lab',
      createdDate: DateTime(2024, 3, 5),
      responsibleTeam: 'Quality Team',
      nextServiceDue: null,
      availabilityStatus: 'Available',
    ),
  ];

  try {
    print('🔥 Testing export with ${sampleItems.length} sample items');
    
    final result = await ExportService.exportToExcel(sampleItems);
    
    if (result != null) {
      print('✅ Excel export successful: $result');
      print('✅ File should contain:');
      print('   - Headers: Item ID, Type, Item Name, Vendor, etc.');
      print('   - ${sampleItems.length} data rows');
      print('   - Proper Excel formatting with bold headers');
      print('   - Auto-fitted columns');
    } else {
      print('❌ Excel export failed');
    }
    
  } catch (e) {
    print('❌ Test failed with error: $e');
  }

  print('🔥 Test completed');
}