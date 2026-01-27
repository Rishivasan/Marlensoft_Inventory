import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/model/maintenance_model.dart';
import 'package:inventory/model/allocation_model.dart';

class ApiService {
  // Try multiple possible backend URLs
  static const List<String> possibleUrls = [
    "http://localhost:5069",      // Command line / Project profile
    "http://localhost:38234",     // IIS Express
    "http://localhost:7294",      // HTTPS Project profile
  ];
  
  static String baseUrl = "http://localhost:5069"; // Default

  // Get item by ID (for product detail screen)
  Future<MasterListModel?> getMasterListById(String id) async {
    print('DEBUG: API - Looking for item with ID: $id');
    try {
      // First, try to get the item from the master list and find by refId
      print('DEBUG: API - Fetching enhanced master list');
      final response = await http.get(Uri.parse("$baseUrl/api/enhanced-master-list"));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('DEBUG: API - Master list loaded, ${data.length} items found');
        
        // Find the item with matching refId
        final itemData = data.firstWhere(
          (item) => item['refId']?.toString() == id,
          orElse: () => null,
        );
        
        if (itemData != null) {
          print('DEBUG: API - Found item in master list: ${itemData['name'] ?? itemData['itemName']}');
          return MasterListModel.fromJson(itemData);
        } else {
          print('DEBUG: API - Item not found in master list, trying asset-full-details');
        }
      } else {
        print('DEBUG: API - Master list request failed: ${response.statusCode}');
      }
      
      // If not found in master list, try the asset-full-details endpoint
      return await _tryAssetFullDetails(id);
      
    } catch (e) {
      print("DEBUG: API - Error loading item details: $e");
      return null;
    }
  }
  
  Future<MasterListModel?> _tryAssetFullDetails(String assetId) async {
    try {
      // Try different asset types
      final assetTypes = ['Tool', 'Asset', 'Consumable', 'MMD'];
      
      for (String assetType in assetTypes) {
        try {
          final response = await http.get(
            Uri.parse("$baseUrl/api/asset-full-details?assetId=$assetId&assetType=$assetType")
          );
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['masterDetails'] != null) {
              return MasterListModel.fromJson(data['masterDetails']);
            }
          }
        } catch (e) {
          continue; // Try next asset type
        }
      }
      
      return null;
    } catch (e) {
      print("Error in asset full details: $e");
      return null;
    }
  }

  // Get maintenance records for an asset
  Future<List<MaintenanceModel>> getMaintenanceByAssetId(String assetId) async {
    print('DEBUG: API - getMaintenanceByAssetId called with: $assetId');
    try {
      final url = "$baseUrl/api/maintenance/$assetId";
      print('DEBUG: API - Calling URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 10));
      
      print('DEBUG: API - Maintenance response status: ${response.statusCode}');
      print('DEBUG: API - Maintenance response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('DEBUG: API - Parsed ${data.length} maintenance records');
        
        if (data.isNotEmpty) {
          print('DEBUG: API - Sample maintenance record: ${data.first}');
        }
        
        final maintenanceList = data.map((json) => MaintenanceModel.fromJson(json)).toList();
        print('DEBUG: API - Successfully converted to ${maintenanceList.length} MaintenanceModel objects');
        return maintenanceList;
      } else {
        print('DEBUG: API - No maintenance records found (status: ${response.statusCode})');
        print('DEBUG: API - Error response: ${response.body}');
        return []; // Return empty list if no maintenance records found
      }
    } catch (e) {
      print("DEBUG: API - Error loading maintenance data: $e");
      print("DEBUG: API - Error type: ${e.runtimeType}");
      return []; // Return empty list on error
    }
  }

  // Add new maintenance record
  Future<Map<String, dynamic>> addMaintenanceRecord(Map<String, dynamic> maintenanceData) async {
    print("DEBUG: Adding maintenance record: $maintenanceData");
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/maintenance"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(maintenanceData),
      );

      print("DEBUG: Add Maintenance Response status: ${response.statusCode}");
      print("DEBUG: Add Maintenance Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : {'success': true};
      } else {
        print("DEBUG: Add failed with status ${response.statusCode}: ${response.body}");
        throw Exception("Failed to add maintenance record: Status ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("DEBUG: Error adding maintenance record: $e");
      print("DEBUG: Error type: ${e.runtimeType}");
      throw Exception("Failed to add maintenance record: $e");
    }
  }

  // Update existing maintenance record
  Future<Map<String, dynamic>> updateMaintenanceRecord(int maintenanceId, Map<String, dynamic> maintenanceData) async {
    print("DEBUG: Updating maintenance record ID $maintenanceId: $maintenanceData");
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/api/maintenance/$maintenanceId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(maintenanceData),
      );

      print("DEBUG: Update Maintenance Response status: ${response.statusCode}");
      print("DEBUG: Update Maintenance Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : {'success': true};
      } else {
        print("DEBUG: Update failed with status ${response.statusCode}: ${response.body}");
        throw Exception("Failed to update maintenance record: Status ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("DEBUG: Error updating maintenance record: $e");
      print("DEBUG: Error type: ${e.runtimeType}");
      throw Exception("Failed to update maintenance record: $e");
    }
  }

  // Get allocation records for an asset
  Future<List<AllocationModel>> getAllocationsByAssetId(String assetId) async {
    print('DEBUG: API - getAllocationsByAssetId called with: $assetId');
    try {
      final url = "$baseUrl/api/allocation/$assetId";
      print('DEBUG: API - Calling URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 10));
      
      print('DEBUG: API - Allocation response status: ${response.statusCode}');
      print('DEBUG: API - Allocation response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('DEBUG: API - Parsed ${data.length} allocation records');
        
        if (data.isNotEmpty) {
          print('DEBUG: API - Sample allocation record: ${data.first}');
        }
        
        final allocationList = data.map((json) => AllocationModel.fromJson(json)).toList();
        print('DEBUG: API - Successfully converted to ${allocationList.length} AllocationModel objects');
        return allocationList;
      } else {
        print('DEBUG: API - No allocation records found (status: ${response.statusCode})');
        print('DEBUG: API - Error response: ${response.body}');
        return []; // Return empty list if no allocation records found
      }
    } catch (e) {
      print("DEBUG: API - Error loading allocation data: $e");
      print("DEBUG: API - Error type: ${e.runtimeType}");
      return []; // Return empty list on error
    }
  }

  // Add new allocation record
  Future<Map<String, dynamic>> addAllocationRecord(Map<String, dynamic> allocationData) async {
    try {
      print("DEBUG: Sending allocation data to API: $allocationData");
      
      final response = await http.post(
        Uri.parse("$baseUrl/api/allocation"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(allocationData),
      );

      print("DEBUG: Add Allocation Response status: ${response.statusCode}");
      print("DEBUG: Add Allocation Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : {'success': true};
      } else {
        print("DEBUG: Allocation API error - Status: ${response.statusCode}, Body: ${response.body}");
        throw Exception("Failed to add allocation record: Status ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("DEBUG: Error adding allocation record: $e");
      print("DEBUG: Error type: ${e.runtimeType}");
      throw Exception("Failed to add allocation record: $e");
    }
  }

  // Update existing allocation record
  Future<Map<String, dynamic>> updateAllocationRecord(int allocationId, Map<String, dynamic> allocationData) async {
    print("DEBUG: Updating allocation record ID $allocationId: $allocationData");
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/api/allocation/$allocationId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(allocationData),
      );

      print("DEBUG: Update Allocation Response status: ${response.statusCode}");
      print("DEBUG: Update Allocation Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : {'success': true};
      } else {
        print("DEBUG: Update failed with status ${response.statusCode}: ${response.body}");
        throw Exception("Failed to update allocation record: Status ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("DEBUG: Error updating allocation record: $e");
      print("DEBUG: Error type: ${e.runtimeType}");
      throw Exception("Failed to update allocation record: $e");
    }
  }

  // Tools
  Future<List<dynamic>> getTools() async {
    final response = await http.get(Uri.parse("$baseUrl/api/tools"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load tools");
    }
  }

  Future<void> addTool(Map<String, dynamic> data) async {
    print("DEBUG: Calling API at: $baseUrl/api/addtools");
    print("DEBUG: Data being sent: $data");
    
    final response = await http.post(
      Uri.parse("$baseUrl/api/addtools"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("DEBUG: Response status: ${response.statusCode}");
    print("DEBUG: Response body: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add tool: ${response.body}");
    }
  }

  // Assets and Consumables
  Future<List<dynamic>> getAssetsConsumables() async {
    final response = await http.get(Uri.parse("$baseUrl/api/assets-consumables"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load assets/consumables");
    }
  }

  Future<void> addAssetConsumable(Map<String, dynamic> data) async {
    print("DEBUG: Calling Asset/Consumable API at: $baseUrl/api/add-assets-consumables");
    print("DEBUG: Asset/Consumable Data being sent: $data");
    
    final response = await http.post(
      Uri.parse("$baseUrl/api/add-assets-consumables"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("DEBUG: Asset/Consumable Response status: ${response.statusCode}");
    print("DEBUG: Asset/Consumable Response body: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add asset/consumable: ${response.body}");
    }
  }

  // MMDs
  Future<List<dynamic>> getMmds() async {
    final response = await http.get(Uri.parse("$baseUrl/api/mmds"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load MMDs");
    }
  }

  Future<void> addMmd(Map<String, dynamic> data) async {
    print("DEBUG: Calling MMD API at: $baseUrl/api/addmmds");
    print("DEBUG: MMD Data being sent: $data");
    
    final response = await http.post(
      Uri.parse("$baseUrl/api/addmmds"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("DEBUG: MMD Response status: ${response.statusCode}");
    print("DEBUG: MMD Response body: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add MMD: ${response.body}");
    }
  }
}
