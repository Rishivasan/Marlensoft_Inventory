import 'package:dio/dio.dart';

class ToolService {
  final Dio dio;
  ToolService(this.dio);

  Future<List<dynamic>> getTools() async {
    final res = await dio.get("/api/tools");
    return res.data;
  }

  Future<void> addTool(Map<String, dynamic> body) async {
    await dio.post("/api/addtools", data: body);
  }
}

