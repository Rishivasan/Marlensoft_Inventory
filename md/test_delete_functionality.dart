// Test script to verify delete functionality
import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  print('🔥 Testing Delete Functionality');
  
  final dio = Dio(BaseOptions(
    baseUrl: "http://localhost:5069",
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    sendTimeout: const Duration(seconds: 8),
    headers: {"Content-Type": "application/json"},
  ));

  // Add logging
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
    logPrint: (obj) => print('[DIO] $obj'),
  ));

  try {
    // 1. First, get all tools to see what's available
    print('\n🔥 Step 1: Getting all tools...');
    final toolsResponse = await dio.get('/api/tools');
    final tools = toolsResponse.data as List;
    print('Found ${tools.length} active tools');
    
    if (tools.isEmpty) {
      print('❌ No tools found to test delete functionality');
      return;
    }

    // Get the first tool for testing
    final testTool = tools.first;
    final toolId = testTool['toolsId'];
    print('Using tool ID: $toolId for testing');

    // 2. Test delete API
    print('\n🔥 Step 2: Testing delete API...');
    try {
      final deleteResponse = await dio.delete('/api/Tools/$toolId');
      print('✅ Delete API response: ${deleteResponse.statusCode} - ${deleteResponse.data}');
    } catch (e) {
      print('❌ Delete API failed: $e');
      return;
    }

    // 3. Verify soft delete worked
    print('\n🔥 Step 3: Verifying soft delete...');
    final verifyResponse = await dio.get('/api/tools');
    final remainingTools = verifyResponse.data as List;
    print('Found ${remainingTools.length} active tools after delete');

    // Check if deleted tool is still in the list
    final deletedToolStillExists = remainingTools.any((tool) => tool['toolsId'] == toolId);
    if (deletedToolStillExists) {
      print('❌ FAILED: Deleted tool $toolId is still in the active list!');
    } else {
      print('✅ SUCCESS: Deleted tool $toolId is not in the active list');
    }

    // 4. Test master list API
    print('\n🔥 Step 4: Testing master list API...');
    try {
      final masterResponse = await dio.get('/api/MasterRegister');
      final masterList = masterResponse.data as List;
      print('Found ${masterList.length} items in master list');
      
      // Check if deleted tool is in master list
      final deletedInMaster = masterList.any((item) => item['refId'] == toolId);
      if (deletedInMaster) {
        print('❌ FAILED: Deleted tool $toolId is still in the master list!');
      } else {
        print('✅ SUCCESS: Deleted tool $toolId is not in the master list');
      }
    } catch (e) {
      print('❌ Master list API failed: $e');
    }

  } catch (e) {
    print('❌ Test failed with error: $e');
  }

  print('\n🔥 Test completed');
}