import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../data/tool_service.dart';

final dioProvider = Provider<Dio>((ref) {
  return DioClient.getDio();
});

final toolServiceProvider = Provider<ToolService>((ref) {
  return ToolService(ref.read(dioProvider));
});

final toolListProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.read(toolServiceProvider).getTools();
});

