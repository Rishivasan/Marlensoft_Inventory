import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/model/tool_model.dart';
import 'package:inventory/services/tool_service.dart';

final toolServiceProvider = Provider<ToolService>((ref) {
  return ToolService();
});

final toolListProvider = FutureProvider<List<ToolModel>>((ref) async {
  return ref.read(toolServiceProvider).getAllTools();
});
