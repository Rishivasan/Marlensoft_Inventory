import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/model/maintenance_model.dart';
import 'package:inventory/model/allocation_model.dart';

class ApiService {
  // Try multiple possible backend URLs
  static const List<String> possibleUrls = [
    "http://localhost:5069",      // Command line / Project profile
    "http://localhost:5071",      // Command line / Project profile
    "http://localhost:5070",      // Command line / Project profile
    "http://localhost:38234",     // IIS Express
    "http://localhost:7294",      // HTTPS Project profile
  ];
  
  static String baseUrl = "http://localhost:5069"; // Default

  // Get complete item details by ID and type for editing
  // Enhanced method for getting complete item details with type
  Future<Map<String, dynamic>?> getCompleteItemDetailsV2(String itemId, String itemType) async {
    print(' DEBUG: API - Getting complete details for item: $itemId, type: $itemType');
    try {
      final endpoint = '$baseUrl/api/v2/item-details/$itemId/$itemType';
      
      print(' DEBUG: API - Calling V2 endpoint: $endpoint');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 15));
      
      print(' DEBUG: API - Response status: ${response.statusCode}');
      print('DEBUG: API - Response body length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        print(' DEBUG: API - Raw response body: ${response.body}');
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print(' DEBUG: API - Successfully parsed JSON response');
        print('DEBUG: API - Response keys: ${data.keys.toList()}');
        print(' DEBUG: API - HasDetailedData: ${data['hasDetailedData']}');
        
        if (data['detailedData'] != null && data['detailedData'] is Map) {
          final detailedData = Map<String, dynamic>.from(data['detailedData'] as Map);
          print(' DEBUG: API - DetailedData keys: ${detailedData.keys.toList()}');
          print(' DEBUG: API - DetailedData sample values:');
          detailedData.forEach((key, value) {
            print('   $key: $value');
          });
          return {
            'ItemType': data['itemType'],
            'MasterData': data['masterData'] != null ? Map<String, dynamic>.from(data['masterData'] as Map) : null,
            'DetailedData': detailedData,
            'HasDetailedData': data['hasDetailedData'] == true,
          };
        } else {
          print(' DEBUG: API - No DetailedData found in response');
          return {
            'ItemType': data['itemType'],
            'MasterData': data['masterData'] != null ? Map<String, dynamic>.from(data['masterData'] as Map) : null,
            'DetailedData': <String, dynamic>{},
            'HasDetailedData': false,
          };
        }
      } else {
        print(' DEBUG: API - Failed to fetch item details: ${response.statusCode}');
        print(' DEBUG: API - Error response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print(" DEBUG: API - Error fetching complete item details: $e");
      print(" DEBUG: API - Error type: ${e.runtimeType}");
      return null;
    }
  }

  // Update item details with the new V2 endpoint
  Future<bool> updateCompleteItemDetailsV2(String itemId, String itemType, Map<String, dynamic> updateData) async {
    print('DEBUG: API - Updating item details for: $itemId, type: $itemType');
    try {
      final endpoint = '$baseUrl/api/v2/item-details/$itemId/$itemType';
      
      print('DEBUG: API - Calling V2 update endpoint: $endpoint');
      final response = await http.put(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updateData),
      ).timeout(const Duration(seconds: 15));
      
      print('DEBUG: API - Update response status: ${response.statusCode}');
      print('DEBUG: API - Update response body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('DEBUG: API - Successfully updated item details');
        return true;
      } else {
        print('DEBUG: API - Failed to update item details: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print("DEBUG: API - Error updating item details: $e");
      return false;
    }
  }
  Future<MasterListModel?> getMasterListById(String id) async {
    print('DEBUG: API - Looking for item with ID: $id');
    try {
      // First, try to get the item from the enhanced master list
      print('DEBUG: API - Fetching enhanced master list');
      final response = await http.get(Uri.parse("$baseUrl/api/enhanced-master-list"));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('DEBUG: API - Enhanced master list loaded, ${data.length} items found');
        
        // Find the item with matching ItemID
        final itemData = data.firstWhere(
          (item) => item['ItemID']?.toString() == id || item['itemID']?.toString() == id,
          orElse: () => null,
        );
        
        if (itemData != null) {
          print('DEBUG: API - Found item in enhanced master list:');
          print('  - ItemID: ${itemData['ItemID']}');
          print('  - ItemName: ${itemData['ItemName']}');
          print('  - Type: ${itemData['Type']}');
          print('  - Vendor: ${itemData['Vendor']}');
          print('  - StorageLocation: ${itemData['StorageLocation']}');
          print('  - ResponsibleTeam: ${itemData['ResponsibleTeam']}');
          print('  - AvailabilityStatus: ${itemData['AvailabilityStatus']}');
          
          return MasterListModel.fromJson(itemData);
        } else {
          print('DEBUG: API - Item not found in enhanced master list, trying regular master list');
        }
      } else {
        print('DEBUG: API - Enhanced master list request failed: ${response.statusCode}');
      }
      
      // If not found in enhanced master list, try the regular master list
      print('DEBUG: API - Trying regular master list');
      final regularResponse = await http.get(Uri.parse("$baseUrl/api/master-list"));
      
      if (regularResponse.statusCode == 200) {
        final List<dynamic> data = jsonDecode(regularResponse.body);
        print('DEBUG: API - Regular master list loaded, ${data.length} items found');
        
        // Find the item with matching refId
        final itemData = data.firstWhere(
          (item) => item['refId']?.toString() == id || item['RefId']?.toString() == id,
          orElse: () => null,
        );
        
        if (itemData != null) {
          print('DEBUG: API - Found item in regular master list: ${itemData['name'] ?? itemData['Name']}');
          return MasterListModel.fromJson(itemData);
        } else {
          print('DEBUG: API - Item not found in regular master list, trying asset-full-details');
        }
      }
      
      // If not found in master lists, try the asset-full-details endpoint
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

  // Get paginated maintenance records for an asset
  Future<Map<String, dynamic>> getMaintenancePaginated(
    String assetId, {
    int pageNumber = 1,
    int pageSize = 5,
    String? searchText,
    String? sortColumn,
    String? sortDirection,
  }) async {
    print('DEBUG: API - getMaintenancePaginated called with: assetId=$assetId, page=$pageNumber, size=$pageSize');
    try {
      final queryParams = {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        if (searchText != null && searchText.isNotEmpty) 'searchText': searchText,
        if (sortColumn != null && sortColumn.isNotEmpty) 'sortColumn': sortColumn,
        if (sortDirection != null && sortDirection.isNotEmpty) 'sortDirection': sortDirection,
      };
      
      final uri = Uri.parse('$baseUrl/api/maintenance/paginated/$assetId')
          .replace(queryParameters: queryParams);
      
      print('DEBUG: API - Calling paginated URL: $uri');
      
      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 10));
      
      print('DEBUG: API - Paginated maintenance response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('DEBUG: API - Paginated response: totalCount=${data['totalCount']}, page=${data['pageNumber']}, totalPages=${data['totalPages']}');
        return data;
      } else {
        print('DEBUG: API - Paginated maintenance failed: ${response.statusCode}');
        throw Exception('Failed to load paginated maintenance');
      }
    } catch (e) {
      print('DEBUG: API - Error fetching paginated maintenance: $e');
      rethrow;
    }
  }

  // Get paginated allocation records for an asset
  Future<Map<String, dynamic>> getAllocationsPaginated(
    String assetId, {
    int pageNumber = 1,
    int pageSize = 5,
    String? searchText,
    String? sortColumn,
    String? sortDirection,
  }) async {
    print('DEBUG: API - getAllocationsPaginated called with: assetId=$assetId, page=$pageNumber, size=$pageSize');
    try {
      final queryParams = {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        if (searchText != null && searchText.isNotEmpty) 'searchText': searchText,
        if (sortColumn != null && sortColumn.isNotEmpty) 'sortColumn': sortColumn,
        if (sortDirection != null && sortDirection.isNotEmpty) 'sortDirection': sortDirection,
      };
      
      final uri = Uri.parse('$baseUrl/api/allocation/paginated/$assetId')
          .replace(queryParameters: queryParams);
      
      print('DEBUG: API - Calling paginated URL: $uri');
      
      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 10));
      
      print('DEBUG: API - Paginated allocation response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('DEBUG: API - Paginated response: totalCount=${data['totalCount']}, page=${data['pageNumber']}, totalPages=${data['totalPages']}');
        return data;
      } else {
        print('DEBUG: API - Paginated allocation failed: ${response.statusCode}');
        throw Exception('Failed to load paginated allocations');
      }
    } catch (e) {
      print('DEBUG: API - Error fetching paginated allocations: $e');
      rethrow;
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
    print("DEBUG: API - Calling Tool API at: $baseUrl/api/addtools");
    print("DEBUG: API - Tool Data being sent: $data");
    
    final response = await http.post(
      Uri.parse("$baseUrl/api/addtools"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("DEBUG: API - Tool Response status: ${response.statusCode}");
    print("DEBUG: API - Tool Response body: ${response.body}");

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
    print("DEBUG: API - Calling Asset/Consumable API at: $baseUrl/api/add-assets-consumables");
    print("DEBUG: API - Asset/Consumable Data being sent: $data");
    
    final response = await http.post(
      Uri.parse("$baseUrl/api/add-assets-consumables"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("DEBUG: API - Asset/Consumable Response status: ${response.statusCode}");
    print("DEBUG: API - Asset/Consumable Response body: ${response.body}");

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
    print("DEBUG: API - Calling MMD API at: $baseUrl/api/addmmds");
    print("DEBUG: API - MMD Data being sent: $data");
    
    final response = await http.post(
      Uri.parse("$baseUrl/api/addmmds"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("DEBUG: API - MMD Response status: ${response.statusCode}");
    print("DEBUG: API - MMD Response body: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add MMD: ${response.body}");
    }
  }
}
