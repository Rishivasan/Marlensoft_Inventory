import 'dart:convert';
import 'package:http/http.dart' as http;

class QualityService {
  // Use the same base URL pattern as the main API service
  static const String baseUrl = 'http://localhost:5069/api';

  static Future<List<dynamic>> getFinalProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Quality/final-products'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('DEBUG: Final products response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DEBUG: Final products data: $data');
        return data;
      } else {
        print('DEBUG: Final products failed with status: ${response.statusCode}');
        throw Exception('Failed to load final products');
      }
    } catch (e) {
      print('Error fetching final products: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getValidationTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Quality/validation-types'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('DEBUG: Validation types response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DEBUG: Validation types data: $data');
        return data;
      } else {
        print('DEBUG: Validation types failed with status: ${response.statusCode}');
        throw Exception('Failed to load validation types');
      }
    } catch (e) {
      print('Error fetching validation types: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getMaterials(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Quality/materials/$productId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('DEBUG: Materials response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DEBUG: Materials data: $data');
        return data;
      } else {
        print('DEBUG: Materials failed with status: ${response.statusCode}');
        throw Exception('Failed to load materials');
      }
    } catch (e) {
      print('Error fetching materials: $e');
      return [];
    }
  }

  static Future<int> createTemplate(Map<String, dynamic> templateData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Quality/templates'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(templateData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['templateId'] ?? 0;
      } else {
        throw Exception('Failed to create template');
      }
    } catch (e) {
      print('Error creating template: $e');
      return 0;
    }
  }

  static Future<List<dynamic>> getControlPoints(int templateId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Quality/templates/$templateId/control-points'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load control points');
      }
    } catch (e) {
      print('Error fetching control points: $e');
      return [];
    }
  }

  static Future<bool> addControlPoint(Map<String, dynamic> controlPointData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Quality/control-points'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(controlPointData),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding control point: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getControlPointTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Quality/control-point-types'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('DEBUG: Control point types response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DEBUG: Control point types data: $data');
        return data;
      } else {
        print('DEBUG: Control point types failed with status: ${response.statusCode}');
        throw Exception('Failed to load control point types');
      }
    } catch (e) {
      print('Error fetching control point types: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getUnits() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Quality/units'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('DEBUG: Units response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DEBUG: Units data: $data');
        return data;
      } else {
        print('DEBUG: Units failed with status: ${response.statusCode}');
        throw Exception('Failed to load units');
      }
    } catch (e) {
      print('Error fetching units: $e');
      return [];
    }
  }
}