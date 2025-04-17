import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:8000/api';
  
  // For web and mobile deployment, we would use different URLs
  static String getBaseUrl() {
    // For web deployment, use the same host but different port
    if (kIsWeb) {
      // This is for when running the Flutter web app locally
      return baseUrl;
    }
    
    // For mobile emulators connecting to localhost
    return 'http://10.0.2.2:8000/api'; // Android emulator
    // return baseUrl; // iOS simulator
  }
  
  // GET request
  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${getBaseUrl()}/$endpoint');
    print('Making GET request to $url');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load data from $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      print('Error making GET request: $e');
      rethrow;
    }
  }
  
  // POST request
  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('${getBaseUrl()}/$endpoint');
    print('Making POST request to $url with data: $data');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to post data to $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      print('Error making POST request: $e');
      rethrow;
    }
  }
  
  // PUT request
  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('${getBaseUrl()}/$endpoint');
    print('Making PUT request to $url with data: $data');
    
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to update data at $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      print('Error making PUT request: $e');
      rethrow;
    }
  }
  
  // DELETE request
  static Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('${getBaseUrl()}/$endpoint');
    print('Making DELETE request to $url');
    
    try {
      final response = await http.delete(url);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to delete data at $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      print('Error making DELETE request: $e');
      rethrow;
    }
  }
  
  // Health check
  static Future<bool> checkHealth() async {
    try {
      final result = await get('health');
      return result['status'] == 'ok';
    } catch (e) {
      print('API health check failed: $e');
      return false;
    }
  }
}