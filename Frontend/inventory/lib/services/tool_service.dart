import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory/model/tool_model.dart';

class ToolService {
  static const String baseUrl = "http://localhost:5069";

  Future<List<ToolModel>> getAllTools() async {
    
    final url = Uri.parse("$baseUrl/api/tools");
    final response = await http.get(url);
   


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      //  print("API STATUS: ${response.statusCode}");
      // print("API BODY: ${response.body}");

      if (data is List) {
        return data.map((e) => ToolModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception("Failed to load tools: ${response.statusCode}");
    }
  }
}
