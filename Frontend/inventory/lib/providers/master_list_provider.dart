// import 'dart:convert';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;

// import 'package:inventory/model/assets_table_model.dart';

// /// ✅ Your swagger shows: https://localhost:44370
// const String baseUrl = "https://localhost:44370";

// final masterListProvider = FutureProvider<List<EmployeeTableModel>>((ref) async {
//   final url = Uri.parse("$baseUrl/api/tools");

//   final response = await http.get(url);

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);

//     if (data is List) {
//       return data.map<EmployeeTableModel>((item) {
//         return EmployeeTableModel(
//           Asset: item["toolsId"]?.toString() ?? "",
//           Type: item["toolType"] ?? "",
//           AssetName: item["toolName"] ?? "",
//           Supplier: item["vendorName"] ?? "", // ✅ from swagger
//           Location: item["storageLocation"] ?? "",
//         );
//       }).toList();
//     }

//     return [];
//   } else {
//     throw Exception("Failed to load tools: ${response.statusCode}");
//   }
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/services/master_list_service.dart';

final masterListServiceProvider = Provider((ref) => MasterListService());

// Use AsyncNotifier for Riverpod 3.x
class MasterListNotifier extends AsyncNotifier<List<MasterListModel>> {
  @override
  Future<List<MasterListModel>> build() async {
    return await loadMasterList();
  }

  Future<List<MasterListModel>> loadMasterList() async {
    try {
      print('DEBUG: MasterListNotifier - Loading master list');
      final masterList = await MasterListService().getMasterList();
      print('DEBUG: MasterListNotifier - Loaded ${masterList.length} items');
      return masterList;
    } catch (error, stackTrace) {
      print('DEBUG: MasterListNotifier - Error loading: $error');
      throw error;
    }
  }

  Future<void> refresh() async {
    print('DEBUG: MasterListNotifier - Refreshing master list');
    state = const AsyncValue.loading();
    try {
      final masterList = await loadMasterList();
      state = AsyncValue.data(masterList);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final masterListProvider = AsyncNotifierProvider<MasterListNotifier, List<MasterListModel>>(() {
  return MasterListNotifier();
});

// Helper provider to trigger refresh
final refreshMasterListProvider = Provider((ref) {
  return () async {
    print('DEBUG: Triggering master list refresh');
    await ref.read(masterListProvider.notifier).refresh();
  };
});
