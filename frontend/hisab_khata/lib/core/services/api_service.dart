import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL
  static const String baseUrl =
      'http://10.0.2.2:8000/api'; //yo emulator ko lagi ho
  // static const String baseUrl = 'http://--/api'; //yo physical device ko lagi ho

  // Timeout duration
  static const Duration timeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET Request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url, headers: _headers).timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(url, headers: _headers, body: jsonEncode(data))
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT Request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(url, headers: _headers, body: jsonEncode(data))
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .delete(url, headers: _headers)
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle Response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: body['message'] ?? 'An error occurred',
        data: body['data'],
      );
    }
  }

  // Handle Errors
  static ApiException _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    return ApiException(statusCode: 0, message: error.toString());
  }
}

// Custom Exception Class
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  ApiException({required this.statusCode, required this.message, this.data});

  @override
  String toString() => message;
}
