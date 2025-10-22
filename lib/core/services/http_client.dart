import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/api_keys.dart';
import '../error/failures.dart';
import '../exceptions/network_exceptions.dart';

class HttpClient {
  final http.Client _client;

  HttpClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    debugPrint('HttpClient: GET request to $endpoint');
    debugPrint('HttpClient: Query parameters: $queryParameters');
    
    try {
      return await _makeRequest(
        () => _client.get(
          _buildUri(endpoint, queryParameters),
          headers: _buildHeaders(headers),
        ),
      );
    } catch (e) {
      debugPrint('HttpClient: GET request failed for $endpoint - $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    debugPrint('HttpClient: POST request to $endpoint');
    debugPrint('HttpClient: Query parameters: $queryParameters');
    
    if (body != null) {
      debugPrint('HttpClient: Request body keys: ${body.keys.toList()}');
      debugPrint('HttpClient: Request body: ${jsonEncode(body)}');
    } else {
      debugPrint('HttpClient: Request body: None');
    }
    
    try {
      return await _makeRequest(
        () => _client.post(
          _buildUri(endpoint, queryParameters),
          headers: _buildHeaders(headers),
          body: body != null ? jsonEncode(body) : null,
        ),
      );
    } catch (e) {
      debugPrint('HttpClient: POST request failed for $endpoint - $e');
      rethrow;
    }
  }

  Uri _buildUri(String endpoint, Map<String, String>? queryParameters) {
    final fullUrl = '${ApiConfig.rapidApiBaseUrl}$endpoint';
    debugPrint('HttpClient: Building URI from: $fullUrl');
    
    try {
      final uri = Uri.parse(fullUrl);
      debugPrint('HttpClient: Parsed URI successfully');
      debugPrint('HttpClient: Scheme: ${uri.scheme}');
      debugPrint('HttpClient: Host: ${uri.host}');
      debugPrint('HttpClient: Port: ${uri.port}');
      debugPrint('HttpClient: Path: ${uri.path}');
      
      if (queryParameters != null) {
        debugPrint('HttpClient: Adding query parameters: $queryParameters');
        return uri.replace(queryParameters: queryParameters);
      }
      return uri;
    } catch (e) {
      debugPrint('HttpClient: ERROR parsing URI: $e');
      debugPrint('HttpClient: Attempted URL: $fullUrl');
      rethrow;
    }
  }

  Map<String, String> _buildHeaders(Map<String, String>? additionalHeaders) {
    final headers = <String, String>{};
    headers.addAll(ApiConfig.defaultHeaders);
    headers.addAll(ApiKeys.rapidApiHeaders);
    
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
      debugPrint('HttpClient: Added ${additionalHeaders.length} additional headers');
    }
    
    debugPrint('HttpClient: Built headers with ${headers.length} total entries');
    debugPrint('HttpClient: Header keys: ${headers.keys.toList()}');
    
    // Log headers safely (hide sensitive values)
    headers.forEach((key, value) {
      if (key.toLowerCase().contains('key') || key.toLowerCase().contains('auth')) {
        debugPrint('HttpClient: $key: ${value.length > 10 ? '${value.substring(0, 10)}...(${value.length} chars)' : '***'}');
      } else {
        debugPrint('HttpClient: $key: $value');
      }
    });
    
    return headers;
  }

  Future<Map<String, dynamic>> _makeRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      debugPrint('HttpClient: Making API request...');
      final response = await request().timeout(ApiConfig.connectionTimeout);
      debugPrint('HttpClient: Received response with status ${response.statusCode}');
      return _handleResponse(response);
    } on TimeoutException catch (e) {
      debugPrint('HttpClient: Timeout error - $e');
      throw const ConnectionTimeoutException();
    } on SocketException catch (e) {
      debugPrint('HttpClient: Socket error - $e');
      debugPrint('HttpClient: Socket OS Error: ${e.osError}');
      debugPrint('HttpClient: Socket address: ${e.address}');
      debugPrint('HttpClient: Socket port: ${e.port}');
      
      // Provide more specific error messages
      if (e.message.contains('Failed host lookup') || 
          e.osError?.message.contains('nodename nor servname provided') == true ||
          e.osError?.message.contains('No address associated with hostname') == true) {
        debugPrint('❌ DNS resolution failed - Cannot resolve hostname');
        debugPrint('💡 Possible causes:');
        debugPrint('   1. No internet connection on device/emulator');
        debugPrint('   2. DNS server not reachable');
        debugPrint('   3. Hostname is incorrect');
        debugPrint('   4. Firewall/Proxy blocking DNS requests');
        throw const NoInternetConnectionException();
      } else if (e.message.contains('Network is unreachable')) {
        debugPrint('❌ Network unreachable - No internet connection');
        throw const NoInternetConnectionException();
      } else {
        debugPrint('❌ Connection refused or other socket error');
        throw const ConnectionRefusedException();
      }
    } on http.ClientException catch (e) {
      debugPrint('HttpClient: Client error - $e');
      throw const ConnectionRefusedException();
    } on TlsException catch (e) {
      debugPrint('HttpClient: TLS/SSL error - $e');
      throw const ConnectionRefusedException();
    } on NetworkException catch (e) {
      debugPrint('HttpClient: Network exception - $e');
      rethrow;
    } on Failure catch (e) {
      debugPrint('HttpClient: Failure object - $e');
      rethrow;
    } on FormatException catch (e) {
      debugPrint('HttpClient: Format error - $e');
      throw const ServerFailure('Invalid response format from server');
    } catch (e, stackTrace) {
      debugPrint('HttpClient: Unexpected error - $e');
      debugPrint('HttpClient: Stack trace - $stackTrace');
      // Handle specific error patterns like in mynotes
      String errorMsg = e.toString();
      if (_isNetworkError(errorMsg)) {
        throw NetworkFailure('Network connection error: $errorMsg');
      } else if (errorMsg.toLowerCase().contains('timeout')) {
        throw const NetworkFailure('Request timeout. Please try again.');
      } else if (errorMsg.toLowerCase().contains('certificate') || errorMsg.toLowerCase().contains('ssl')) {
        throw const NetworkFailure('SSL certificate error. Please check your connection.');
      } else if (errorMsg.toLowerCase().contains('authentication') || errorMsg.toLowerCase().contains('unauthorized')) {
        throw const ServerFailure('Authentication failed. Please check your credentials.');
      } else {
        throw ServerFailure('Unexpected network error: $errorMsg');
      }
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body;
    debugPrint('HttpClient: Response status ${response.statusCode}');
    debugPrint('HttpClient: Response body length: ${body.length}');
    
    if (body.isEmpty) {
      debugPrint('HttpClient: Empty response body received');
      throw const ServerFailure('Empty response from server');
    }

    try {
      final jsonData = jsonDecode(body) as Map<String, dynamic>;
      debugPrint('HttpClient: Successfully parsed JSON response');
      
      switch (response.statusCode) {
        case 200:
        case 201:
          debugPrint('HttpClient: Success response received');
          return jsonData;
        case 400:
          debugPrint('HttpClient: Bad request error (400)');
          String errorMsg = jsonData['message'] ?? jsonData['error'] ?? 'Bad request';
          throw ValidationFailure(errorMsg);
        case 401:
          debugPrint('HttpClient: Unauthorized error (401)');
          String errorMsg = jsonData['message'] ?? jsonData['error'] ?? 'Unauthorized access';
          _handleAuthenticationError(errorMsg, 401);
          break; // This won't be reached due to throw in _handleAuthenticationError
        case 403:
          debugPrint('HttpClient: Forbidden error (403)');
          String errorMsg = jsonData['message'] ?? jsonData['error'] ?? 'Access forbidden';
          _handleAuthenticationError(errorMsg, 403);
          break; // This won't be reached due to throw in _handleAuthenticationError
        case 404:
          debugPrint('HttpClient: Not found error (404)');
          String errorMsg = jsonData['message'] ?? jsonData['error'] ?? 'Resource not found';
          if (errorMsg.toLowerCase().contains('vehicle') || 
              errorMsg.toLowerCase().contains('registration')) {
            throw ServerFailure('Vehicle not found: $errorMsg');
          }
          throw ServerFailure('Not found - $errorMsg');
        case 429:
          debugPrint('HttpClient: Rate limit exceeded (429)');
          String errorMsg = jsonData['message'] ?? jsonData['error'] ?? 'Rate limit exceeded';
          if (_isRateLimitError(errorMsg, 429)) {
            throw ServerFailure('Rate limit exceeded: $errorMsg');
          }
          throw ServerFailure('Too many requests: $errorMsg');
        case 500:
          debugPrint('HttpClient: Internal server error (500)');
          String errorMsg = jsonData['message'] ?? jsonData['error'] ?? 'Internal server error';
          throw ServerFailure('Server error (500): $errorMsg');
        case 502:
          debugPrint('HttpClient: Bad gateway error (502)');
          String errorMsg = jsonData['message'] ?? jsonData['error'] ?? 'Bad gateway';
          throw ServerFailure('Server temporarily unavailable (502): $errorMsg');
        case 503:
          debugPrint('HttpClient: Service unavailable error (503)');
          String errorMsg = jsonData['message'] ?? jsonData['error'] ?? 'Service unavailable';
          throw ServerFailure('Service temporarily unavailable (503): $errorMsg');
        case 504:
          debugPrint('HttpClient: Gateway timeout error (504)');
          throw const ServerFailure('Server timeout (504) - Please try again later');
        default:
          debugPrint('HttpClient: Unexpected status code ${response.statusCode}');
          String errorMsg = jsonData['message'] ?? jsonData['error'] ?? 'Unknown error';
          throw ServerFailure('HTTP ${response.statusCode}: $errorMsg');
      }
      
      // This should never be reached due to throws in all switch cases
      throw ServerFailure('Unhandled response case');
    } on FormatException catch (e) {
      debugPrint('HttpClient: JSON parsing failed - $e');
      debugPrint('HttpClient: Raw response body: $body');
      
      // Handle non-JSON error responses
      if (response.statusCode == 429) {
        throw const ServerFailure('Rate limit exceeded');
      } else if (response.statusCode >= 500) {
        throw ServerFailure('Server error (${response.statusCode})');
      } else if (response.statusCode == 401) {
        throw const ServerFailure('Unauthorized - Check API key');
      } else if (response.statusCode == 403) {
        throw const ServerFailure('Forbidden - API key may be invalid');
      } else if (response.statusCode == 404) {
        throw const ServerFailure('Vehicle not found');
      } else {
        throw ServerFailure('Failed to parse response (${response.statusCode}): $e');
      }
    } catch (e) {
      debugPrint('HttpClient: Response handling error - $e');
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure('Failed to handle response: $e');
    }
  }

  /// Handle authentication-specific errors like in mynotes app
  void _handleAuthenticationError(String errorMessage, int statusCode) {
    debugPrint('HttpClient: Authentication error detected - $errorMessage');
    
    String lowerMsg = errorMessage.toLowerCase();
    
    if (lowerMsg.contains('api key') || lowerMsg.contains('invalid key')) {
      throw const ServerFailure('Invalid API key - Please check your RapidAPI subscription');
    } else if (lowerMsg.contains('subscription') || lowerMsg.contains('plan')) {
      throw const ServerFailure('API subscription required - Please upgrade your RapidAPI plan');
    } else if (lowerMsg.contains('quota') || lowerMsg.contains('limit')) {
      throw const ServerFailure('API quota exceeded - Please check your usage limits');
    } else if (lowerMsg.contains('expired') || lowerMsg.contains('token')) {
      throw const ServerFailure('API token expired - Please renew your subscription');
    } else {
      throw ServerFailure('Authentication failed ($statusCode): $errorMessage');
    }
  }

  /// Check if error indicates rate limiting like in mynotes app
  bool _isRateLimitError(String errorMessage, int statusCode) {
    if (statusCode == 429) return true;
    
    String lowerMsg = errorMessage.toLowerCase();
    return lowerMsg.contains('rate limit') || 
           lowerMsg.contains('too many requests') ||
           lowerMsg.contains('throttled') ||
           lowerMsg.contains('quota exceeded');
  }

  /// Check if error indicates network connectivity issues
  bool _isNetworkError(String errorMessage) {
    String lowerMsg = errorMessage.toLowerCase();
    return lowerMsg.contains('network') ||
           lowerMsg.contains('connection') ||
           lowerMsg.contains('timeout') ||
           lowerMsg.contains('unreachable') ||
           lowerMsg.contains('dns');
  }

  void dispose() {
    debugPrint('HttpClient: Disposing HTTP client');
    _client.close();
  }
}