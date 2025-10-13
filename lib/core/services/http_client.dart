import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/api_keys.dart';
import '../error/failures.dart';

class HttpClient {
  final http.Client _client;

  HttpClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      () => _client.get(
        _buildUri(endpoint, queryParameters),
        headers: _buildHeaders(headers),
      ),
    );
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    return _makeRequest(
      () => _client.post(
        _buildUri(endpoint, queryParameters),
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Uri _buildUri(String endpoint, Map<String, String>? queryParameters) {
    final uri = Uri.parse('${ApiConfig.rapidApiBaseUrl}$endpoint');
    if (queryParameters != null) {
      return uri.replace(queryParameters: queryParameters);
    }
    return uri;
  }

  Map<String, String> _buildHeaders(Map<String, String>? additionalHeaders) {
    final headers = <String, String>{};
    headers.addAll(ApiConfig.defaultHeaders);
    headers.addAll(ApiKeys.rapidApiHeaders);
    
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }

  Future<Map<String, dynamic>> _makeRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(ApiConfig.connectionTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw const NetworkFailure('Request timeout - please check your internet connection');
    } on SocketException catch (e) {
      throw NetworkFailure('Connection failed: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkFailure('Network error: ${e.message}');
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body;
    
    if (body.isEmpty) {
      throw const ServerFailure('Empty response from server');
    }

    try {
      final jsonData = jsonDecode(body) as Map<String, dynamic>;
      
      switch (response.statusCode) {
        case 200:
        case 201:
          return jsonData;
        case 400:
          throw ValidationFailure(
            jsonData['message'] ?? 'Bad request',
          );
        case 401:
          throw const ServerFailure('Unauthorized - Check API key');
        case 403:
          throw const ServerFailure('Forbidden - API key may be invalid');
        case 404:
          throw const ServerFailure('Vehicle not found');
        case 429:
          throw const ServerFailure('Rate limit exceeded');
        case 500:
        case 502:
        case 503:
          throw ServerFailure(
            jsonData['message'] ?? 'Server error',
          );
        default:
          throw ServerFailure(
            'HTTP ${response.statusCode}: ${jsonData['message'] ?? 'Unknown error'}',
          );
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to parse response: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}