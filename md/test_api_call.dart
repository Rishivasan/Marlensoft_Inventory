import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Test the API service
  const String baseUrl = "http://localhost:5069";
  
  print("Testing API connection to $baseUrl");
  
  try {
    // Test GET tools
    final getResponse = await http.get(Uri.parse("$baseUrl/api/tools"));
    print("GET /api/tools - Status: ${getResponse.statusCode}");
    if (getResponse.statusCode == 200) {
      final data = jsonDecode(getResponse.body);
      print("GET /api/tools - Success: ${data.length} tools found");
    } else {
      print("GET /api/tools - Error: ${getResponse.body}");
    }
    
    // Test POST tool
    final toolData = {
      "toolsId": "TEST_API_001",
      "toolName": "Test API Tool",
      "toolType": "Manual",
      "associatedProduct": "Test Product",
      "articleCode": "ART001",
      "vendor": "Test Vendor",
      "specifications": "Test specifications",
      "storageLocation": "A1-B2",
      "poNumber": "PO001",
      "poDate": "2024-01-15T00:00:00Z",
      "invoiceNumber": "INV001",
      "invoiceDate": "2024-01-20T00:00:00Z",
      "toolCost": 100.00,
      "extraCharges": 10.00,
      "totalCost": 110.00,
      "lifespan": "5 years",
      "maintainanceFrequency": "Monthly",
      "handlingCertificate": true,
      "auditInterval": "6 months",
      "maxOutput": 1000,
      "lastAuditDate": "2024-01-01T00:00:00Z",
      "lastAuditNotes": "All good",
      "responsibleTeam": "Team A",
      "notes": "Test notes",
      "msiAsset": "MSI001",
      "kernAsset": "KERN001",
      "createdBy": "TestUser",
      "status": 1
    };
    
    final postResponse = await http.post(
      Uri.parse("$baseUrl/api/addtools"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(toolData),
    );
    
    print("POST /api/addtools - Status: ${postResponse.statusCode}");
    if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
      print("POST /api/addtools - Success: ${postResponse.body}");
    } else {
      print("POST /api/addtools - Error: ${postResponse.body}");
    }
    
  } catch (e) {
    print("Error: $e");
  }
}