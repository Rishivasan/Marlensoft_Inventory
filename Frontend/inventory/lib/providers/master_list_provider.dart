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

// final masterListProvider = FutureProvider<List<MasterListModel>>((ref) async {
//   final service = ref.read(masterListServiceProvider);
//   return service.getMasterList();

  
// });

final masterListProvider =
    FutureProvider<List<MasterListModel>>((ref) async {
  return MasterListService().getMasterList();
  
});
