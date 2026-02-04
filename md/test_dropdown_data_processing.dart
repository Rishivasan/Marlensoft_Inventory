// Test script to verify dropdown data processing
void main() {
  // Simulate API response for control point types
  final controlPointTypesData = [
    {'controlPointTypeId': 3, 'typeName': 'Measure', 'description': ''},
    {'controlPointTypeId': 1, 'typeName': 'Take a picture', 'description': ''},
    {'controlPointTypeId': 2, 'typeName': 'Visual inspection', 'description': ''},
  ];

  // Simulate API response for units
  final unitsData = ['%', 'A', '°C', 'bar', 'cm', 'dB', 'g', 'Hz', 'Ω', 'kg', 'lux', 'm', 'mm', 'Pa', 'pcs', 'pH', 'psi', 'rpm', 'V', 'W'];

  // Process control point types
  final controlPointTypes = controlPointTypesData.map((item) => {
    'id': item['controlPointTypeId']?.toString() ?? item['ControlPointTypeId']?.toString() ?? '',
    'name': item['typeName']?.toString() ?? item['TypeName']?.toString() ?? '',
    'description': item['description']?.toString() ?? item['Description']?.toString() ?? '',
  }).toList();

  // Process units
  final units = unitsData.map((unit) => unit.toString()).toList();

  print('Processed Control Point Types:');
  for (var type in controlPointTypes) {
    print('  ID: ${type['id']}, Name: ${type['name']}, Description: ${type['description']}');
  }

  print('\nProcessed Units:');
  for (var unit in units) {
    print('  Unit: $unit');
  }

  // Find default type (Measure)
  final measureType = controlPointTypes.firstWhere(
    (type) => type['name'].toString().toLowerCase().contains('measure'),
    orElse: () => controlPointTypes.first,
  );
  
  print('\nDefault selected type: ${measureType['id']} - ${measureType['name']}');
}