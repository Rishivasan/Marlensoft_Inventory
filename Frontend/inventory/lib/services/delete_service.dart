import 'package:dio/dio.dart';
import 'package:inventory/core/api/dio_client.dart';

class DeleteService {
  static Dio get _dio => DioClient.getDio();

  static Future<bool> deleteItem(String itemType, String itemId) async {
    try {
      String endpoint = '';
      
      switch (itemType.toLowerCase()) {
        case 'tool':
          endpoint = '/api/Tools/$itemId';
          break;
        case 'asset':
          endpoint = '/api/AssetsConsumables/$itemId';
          break;
        case 'consumable':
          endpoint = '/api/AssetsConsumables/$itemId';
          break;
        case 'mmd':
          endpoint = '/api/Mmds/$itemId';
          break;
        default:
          print('Unknown item type: $itemType');
          return false;
      }

      print('Deleting $itemType with ID: $itemId using endpoint: $endpoint');
      
      // Add timeout to prevent hanging
      final response = await _dio.delete(
        endpoint,
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      
      print('Delete response for $itemId: Status ${response.statusCode}, Data: ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Successfully deleted $itemType with ID: $itemId');
        return true;
      } else {
        print('Failed to delete $itemType with ID: $itemId. Status: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      print('DioException deleting $itemType with ID $itemId: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        print('Timeout occurred while deleting $itemType with ID $itemId');
      }
      return false;
    } catch (e) {
      print('Error deleting $itemType with ID $itemId: $e');
      return false;
    }
  }

  static Future<Map<String, bool>> deleteMultipleItems(Map<String, String> items) async {
    print('Starting parallel deletion of ${items.length} items');
    
    // Process deletions in parallel for better performance
    List<Future<MapEntry<String, bool>>> futures = [];
    
    for (String itemId in items.keys) {
      String itemType = items[itemId]!;
      print('Queuing deletion of $itemType with ID: $itemId');
      
      futures.add(
        deleteItem(itemType, itemId).then((success) {
          print('Deletion result for $itemId: $success');
          return MapEntry(itemId, success);
        })
      );
    }
    
    // Wait for all deletions to complete
    final results = await Future.wait(futures);
    
    // Convert to map
    Map<String, bool> resultMap = Map.fromEntries(results);
    
    print('Completed parallel deletion process. Results: $resultMap');
    return resultMap;
  }
}