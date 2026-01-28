import 'package:inventory/core/api/dio_client.dart';
import 'package:inventory/model/master_list_model.dart';

class MasterListService {
  static const String baseUrl = "http://localhost:5069";

  Future<List<MasterListModel>> getMasterList() async {
    try {
      final dio = DioClient.getDio();
      final response = await dio.get("/api/enhanced-master-list");

      if (response.statusCode == 200) {
        final decoded = response.data;

        if (decoded is List) {
          final items = decoded.map((e) => MasterListModel.fromJson(e)).toList();
          
          // Remove duplicates based on ItemID to prevent UI duplicates
          final uniqueItems = <String, MasterListModel>{};
          for (final item in items) {
            uniqueItems[item.assetId] = item;
          }
          
          final result = uniqueItems.values.toList();
          print('DEBUG: MasterListService - Fetched ${items.length} items, filtered to ${result.length} unique items');
          
          return result;
        } else {
          throw Exception("Invalid API Response: Expected List");
        }
      } else {
        throw Exception("Failed: ${response.statusCode} - ${response.data}");
      }
    } catch (e) {
      print("MasterListService Error: $e");
      throw Exception("Failed to fetch master list: $e");
    }
  }
}
