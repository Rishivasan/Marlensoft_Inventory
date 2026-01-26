import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing deactivate API endpoints...');
  
  const baseUrl = 'http://localhost:5069';
  
  // Test getting master list first
  try {
    print('\n1. Testing GET master list...');
    final response = await http.get(
      Uri.parse('$baseUrl/api/enhanced-master-list'),
      headers: {'Content-Type': 'application/json'},
    );
    
    print('Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        print('Found ${data.length} items in master list');
        
        // Get first item for testing
        final firstItem = data[0];
        print('First item: ${firstItem['refId']} (${firstItem['itemType']})');
        
        // Test delete endpoint based on item type
        String deleteEndpoint = '';
        switch (firstItem['itemType'].toString().toLowerCase()) {
          case 'tool':
            deleteEndpoint = '/api/Tools/${firstItem['refId']}';
            break;
          case 'asset':
          case 'consumable':
            deleteEndpoint = '/api/AssetsConsumables/${firstItem['refId']}';
            break;
          case 'mmd':
            deleteEndpoint = '/api/Mmds/${firstItem['refId']}';
            break;
        }
        
        if (deleteEndpoint.isNotEmpty) {
          print('\n2. Testing DELETE endpoint: $deleteEndpoint');
          final deleteResponse = await http.delete(
            Uri.parse('$baseUrl$deleteEndpoint'),
            headers: {'Content-Type': 'application/json'},
          );
          
          print('Delete Status: ${deleteResponse.statusCode}');
          print('Delete Response: ${deleteResponse.body}');
          
          if (deleteResponse.statusCode == 200 || deleteResponse.statusCode == 204) {
            print('✅ Delete endpoint working correctly');
          } else {
            print('❌ Delete endpoint failed');
          }
        }
      } else {
        print('No items found in master list');
      }
    } else {
      print('Failed to get master list: ${response.body}');
    }
  } catch (e) {
    print('Error testing API: $e');
  }
}