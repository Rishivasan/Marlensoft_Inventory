import 'package:inventory/core/api/dio_client.dart';
import 'package:inventory/providers/product_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

class NextServiceSyncService {
  final Dio _dio = DioClient.getDio();
  
  NextServiceSyncService();
  
  // Sync Next Service Due for a specific asset from its maintenance records
  Future<void> syncNextServiceDueForAsset(String assetId, WidgetRef ref) async {
    try {
      print('DEBUG: Syncing Next Service Due for asset: $assetId');
      
      // Get the latest maintenance record for this asset
      final response = await _dio.get('/api/maintenance/$assetId');
      
      if (response.statusCode == 200 && response.data != null) {
        final maintenanceRecords = response.data as List;
        
        if (maintenanceRecords.isNotEmpty) {
          // Find the most recent maintenance record with NextServiceDue
          DateTime? latestNextServiceDue;
          DateTime? latestServiceDate;
          
          for (var record in maintenanceRecords) {
            final nextServiceDueStr = record['nextServiceDue'] ?? record['NextServiceDue'];
            final serviceDateStr = record['serviceDate'] ?? record['ServiceDate'];
            
            if (nextServiceDueStr != null && serviceDateStr != null) {
              final nextServiceDue = DateTime.tryParse(nextServiceDueStr);
              final serviceDate = DateTime.tryParse(serviceDateStr);
              
              if (nextServiceDue != null && serviceDate != null) {
                if (latestServiceDate == null || serviceDate.isAfter(latestServiceDate)) {
                  latestServiceDate = serviceDate;
                  latestNextServiceDue = nextServiceDue;
                }
              }
            }
          }
          
          if (latestNextServiceDue != null) {
            // Update the reactive state with the latest Next Service Due
            final updateProductState = ref.read(updateProductStateProvider);
            final nextServiceDueString = "${latestNextServiceDue.year}-${latestNextServiceDue.month.toString().padLeft(2, '0')}-${latestNextServiceDue.day.toString().padLeft(2, '0')}";
            
            updateProductState(
              assetId,
              nextServiceDue: nextServiceDueString,
            );
            
            print('DEBUG: Synced Next Service Due for $assetId: $nextServiceDueString');
            return;
          }
        }
      }
      
      print('DEBUG: No maintenance records with Next Service Due found for asset: $assetId');
    } catch (e) {
      print('DEBUG: Error syncing Next Service Due for asset $assetId: $e');
    }
  }
  
  // Sync Next Service Due for multiple assets
  Future<void> syncNextServiceDueForAssets(List<String> assetIds, WidgetRef ref) async {
    print('DEBUG: Syncing Next Service Due for ${assetIds.length} assets');
    
    for (final assetId in assetIds) {
      await syncNextServiceDueForAsset(assetId, ref);
      // Add small delay to avoid overwhelming the server
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    print('DEBUG: Completed syncing Next Service Due for all assets');
  }
  
  // Sync all assets in the current master list
  Future<void> syncAllAssetsNextServiceDue(WidgetRef ref) async {
    try {
      print('DEBUG: Starting sync of all assets Next Service Due');
      
      // Get all assets from master list
      final response = await _dio.get('/api/ItemDetails/enhanced');
      
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data as List;
        final assetIds = items.map((item) => item['assetId']?.toString() ?? '').where((id) => id.isNotEmpty).toList();
        
        print('DEBUG: Found ${assetIds.length} assets to sync');
        
        // Sync in batches to avoid overwhelming the server
        const batchSize = 10;
        for (int i = 0; i < assetIds.length; i += batchSize) {
          final batch = assetIds.skip(i).take(batchSize).toList();
          await syncNextServiceDueForAssets(batch, ref);
          
          // Longer delay between batches
          if (i + batchSize < assetIds.length) {
            await Future.delayed(const Duration(milliseconds: 200));
          }
        }
        
        print('DEBUG: Completed syncing all assets Next Service Due');
      }
    } catch (e) {
      print('DEBUG: Error syncing all assets Next Service Due: $e');
    }
  }
}

// Provider for the sync service
final nextServiceSyncServiceProvider = Provider<NextServiceSyncService>((ref) => NextServiceSyncService());