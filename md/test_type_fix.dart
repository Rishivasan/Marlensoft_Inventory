// Test the type fix for control point types
void main() {
  // Simulate API response
  final controlPointTypesData = [
    {'controlPointTypeId': 3, 'typeName': 'Measure', 'description': ''},
    {'controlPointTypeId': 1, 'typeName': 'Take a picture', 'description': ''},
    {'controlPointTypeId': 2, 'typeName': 'Visual inspection', 'description': ''},
  ];

  // Process with correct types
  final List<Map<String, String>> controlPointTypes = controlPointTypesData.map((item) => <String, String>{
    'id': item['controlPointTypeId']?.toString() ?? '',
    'name': item['typeName']?.toString() ?? '',
    'description': item['description']?.toString() ?? '',
  }).toList();

  print('Processed Control Point Types (Map<String, String>):');
  for (var type in controlPointTypes) {
    print('  ID: ${type['id']}, Name: ${type['name']}, Description: ${type['description']}');
  }

  // Test dropdown item creation
  final dropdownItems = controlPointTypes
      .map((t) => {
        'value': t['id'].toString(),
        'child': t['name'].toString()
      })
      .toList();

  print('\nDropdown Items:');
  for (var item in dropdownItems) {
    print('  Value: ${item['value']}, Child: ${item['child']}');
  }
}