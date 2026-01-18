import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_base_url.dart';
import '../errors/exceptions.dart';
import '../../config/storage/storage_service.dart';

/// Base class for all remote data sources
/// Handles common HTTP operations with error handling and authentication
abstract class BaseRemoteDataSource {
  final http.Client client;

  BaseRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Common headers for all requests
  Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
    bool isMultipart = false,
  }) async {
    final headers = <String, String>{};

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';
    }

    if (includeAuth) {
      final token = await StorageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle response and throw appropriate exceptions
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // Success responses (200-299)
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return json.decode(response.body);
      } catch (e) {
        return response.body;
      }
    }

    // Parse error message from backend
    String errorMessage = 'Something went wrong';
    try {
      final errorBody = json.decode(response.body);
      // Backend returns error in 'message' field
      errorMessage =
          errorBody['message'] ?? errorBody['detail'] ?? errorMessage;
    } catch (_) {
      errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
    }

    // Throw appropriate exception based on status code
    if (statusCode == 401) {
      throw UnauthenticatedException(errorMessage);
    } else if (statusCode >= 400 && statusCode < 500) {
      throw ServerException(errorMessage);
    } else if (statusCode >= 500) {
      throw ServerException('Server error: $errorMessage');
    } else {
      throw ServerException(errorMessage);
    }
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiBaseUrl.baseUrl}$endpoint',
      ).replace(queryParameters: queryParameters);

      final headers = await _getHeaders(includeAuth: includeAuth);

      final response = await client.get(uri, headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw ServerException('No internet connection');
    } on HttpException {
      throw ServerException('Network error occurred');
    } on UnauthenticatedException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiBaseUrl.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);

      final response = await client.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException {
      throw ServerException('No internet connection');
    } on HttpException {
      throw ServerException('Network error occurred');
    } on UnauthenticatedException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiBaseUrl.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);

      final response = await client.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException {
      throw ServerException('No internet connection');
    } on HttpException {
      throw ServerException('Network error occurred');
    } on UnauthenticatedException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  /// PATCH request
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiBaseUrl.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);

      final response = await client.patch(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException {
      throw ServerException('No internet connection');
    } on HttpException {
      throw ServerException('Network error occurred');
    } on UnauthenticatedException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool includeAuth = true,
    required Map<String, dynamic> body,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiBaseUrl.baseUrl}$endpoint',
      ).replace(queryParameters: queryParameters);

      final headers = await _getHeaders(includeAuth: includeAuth);

      // Use Request instead of delete method to include body
      final request = http.Request('DELETE', uri);
      request.headers.addAll(headers);

      // Add body if provided and not empty
      if (body.isNotEmpty) {
        request.body = json.encode(body);
      }

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw ServerException('No internet connection');
    } on HttpException {
      throw ServerException('Network error occurred');
    } on UnauthenticatedException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  /// Multipart request (for file uploads like profile pictures)
  Future<dynamic> multipart(
    String endpoint,
    String method, {
    Map<String, String>? fields,
    Map<String, File>? files,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiBaseUrl.baseUrl}$endpoint');
      final request = http.MultipartRequest(method.toUpperCase(), uri);

      // Add headers (without Content-Type for multipart)
      final headers = await _getHeaders(
        includeAuth: includeAuth,
        isMultipart: true,
      );
      request.headers.addAll(headers);

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw ServerException('No internet connection');
    } on HttpException {
      throw ServerException('Network error occurred');
    } on UnauthenticatedException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  /// Dispose client
  void dispose() {
    client.close();
  }
}
