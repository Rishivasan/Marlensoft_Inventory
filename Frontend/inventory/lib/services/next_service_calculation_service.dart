import 'package:inventory/core/api/dio_client.dart';
import 'package:inventory/providers/next_service_provider.dart';
import 'package:dio/dio.dart';

class NextServiceCalculationService {
  final Dio _dio = DioClient.getDio();
  final NextServiceProvider _nextServiceProvider;
  
  NextServiceCalculationService(this._nextServiceProvider);
  
  // Calculate next service date for a new item
  Future<DateTime?> calculateNextServiceDateForNewItem({
    required String assetId,
    required String assetType,
    required DateTime createdDate,
    required String maintenanceFrequency,
  }) async {
    try {
      // First check if there's any existing maintenance record
      final lastServiceDate = await _getLastServiceDate(assetId, assetType);
      
      // Calculate next service date using provider
      _nextServiceProvider.calculateAndStoreNextServiceDate(
        assetId: assetId,
        createdDate: createdDate,
        maintenanceFrequency: maintenanceFrequency,
        lastServiceDate: lastServiceDate,
      );
      
      final nextServiceDate = _nextServiceProvider.getNextServiceDate(assetId);
      
      // Update the item's next service date in the database
      if (nextServiceDate != null) {
        await _updateItemNextServiceDate(assetId, assetType, nextServiceDate);
      }
      
      return nextServiceDate;
    } catch (e) {
      print('Error calculating next service date: $e');
      return null;
    }
  }
  
  // Get the last service date from maintenance records
  Future<DateTime?> _getLastServiceDate(String assetId, String assetType) async {
    try {
      final response = await _dio.get(
        '/api/NextService/GetLastServiceDate/$assetId/$assetType',
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final lastServiceDateStr = response.data['lastServiceDate'];
        if (lastServiceDateStr != null) {
          return DateTime.tryParse(lastServiceDateStr);
        }
      }
      return null;
    } catch (e) {
      print('Error getting last service date: $e');
      return null;
    }
  }
  
  // Update item's next service date in the database
  Future<bool> _updateItemNextServiceDate(
    String assetId, 
    String assetType, 
    DateTime nextServiceDate
  ) async {
    try {
      final response = await _dio.post(
        '/api/NextService/UpdateNextServiceDate',
        data: {
          'assetId': assetId,
          'assetType': assetType,
          'nextServiceDate': nextServiceDate.toIso8601String(),
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating next service date: $e');
      return false;
    }
  }
  
  // Calculate next service date after maintenance is performed
  Future<DateTime?> calculateNextServiceDateAfterMaintenance({
    required String assetId,
    required String assetType,
    required DateTime serviceDate,
    required String maintenanceFrequency,
  }) async {
    try {
      // Calculate using provider
      _nextServiceProvider.updateNextServiceDateAfterMaintenance(
        assetId: assetId,
        serviceDate: serviceDate,
        maintenanceFrequency: maintenanceFrequency,
      );
      
      final nextServiceDate = _nextServiceProvider.getNextServiceDate(assetId);
      
      // Update in database
      if (nextServiceDate != null) {
        await _updateItemNextServiceDate(assetId, assetType, nextServiceDate);
      }
      
      return nextServiceDate;
    } catch (e) {
      print('Error calculating next service date after maintenance: $e');
      return null;
    }
  }
  
  // Get maintenance frequency for an item
  Future<String?> getMaintenanceFrequency(String assetId, String assetType) async {
    try {
      final response = await _dio.get(
        '/api/NextService/GetMaintenanceFrequency/$assetId/$assetType',
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data['maintenanceFrequency'];
      }
      return null;
    } catch (e) {
      print('Error getting maintenance frequency: $e');
      return null;
    }
  }
  
  // Bulk calculate next service dates for multiple items
  Future<void> bulkCalculateNextServiceDates(List<Map<String, dynamic>> items) async {
    for (final item in items) {
      try {
        await calculateNextServiceDateForNewItem(
          assetId: item['assetId'],
          assetType: item['assetType'],
          createdDate: DateTime.parse(item['createdDate']),
          maintenanceFrequency: item['maintenanceFrequency'],
        );
      } catch (e) {
        print('Error calculating next service date for ${item['assetId']}: $e');
      }
    }
  }
}