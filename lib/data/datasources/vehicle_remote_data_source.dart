import '../../domain/entities/vehicle_details.dart';
import '../../core/services/http_client.dart';
import '../../core/config/api_config.dart';
import '../../core/config/api_keys.dart';


abstract class VehicleRemoteDataSource {
  Future<VehicleDetails> getVehicleDetails(String vehicleNumber);
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final HttpClient httpClient;
  
  VehicleRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<VehicleDetails> getVehicleDetails(String vehicleNumber) async {
    print('🚀 Starting vehicle details fetch for: $vehicleNumber');
    print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    
    // Validate and format vehicle number
    final formattedVehicleNumber = vehicleNumber.toUpperCase().replaceAll(' ', '');
    print('🔄 Formatted vehicle number: $formattedVehicleNumber');
    
    // Validate API key first
    _validateApiKey();
    
    // Make API call directly without rate limiting
    final response = await _makeApiCallWithRetry(formattedVehicleNumber);
    
    print('📝 Raw API Response: $response');
    print('📊 Response keys: ${response.keys.toList()}');
    print('📊 Response structure:');
    response.forEach((key, value) {
      print('   $key: ${value.runtimeType} = ${value.toString().length > 100 ? value.toString().substring(0, 100) + '...' : value}');
    });
    
    // Handle RapidAPI response format - check multiple status fields
    final status = response['status'] as bool? ?? response['success'] as bool?;
    final message = response['message'] as String? ?? response['error'] as String? ?? response['msg'] as String?;
    
    print('🔍 Status field: $status');
    print('🔍 Message field: $message');
    
    if (status == false) {
      print('❌ API returned error status');
      print('❌ Error message: $message');
      print('❌ Full response: $response');
      
      // Check if it's a validation error vs data not found
      if (message != null && (message.contains('vehicle no') || message.contains('not found') || message.contains('invalid'))) {
        throw Exception('Vehicle not found: $message\n\nPlease verify:\n• Vehicle number format (e.g., MH12AB1234)\n• Vehicle is registered in India\n• Try a different vehicle number');
      }
      
      throw Exception('API Error: ${message ?? 'Unknown error'}');
    }
    
    // Parse response even if status is not explicitly true (some APIs don't include status field)
    return _parseRapidApiResponse(response, formattedVehicleNumber);
  }

  void _validateApiKey() {
    // Properly validate API key configuration
    try {
      print('🔍 Validating API configuration...');
      
      // Validate RapidAPI key
      final rapidKey = ApiKeys.rapidApiKey;
      final rapidHost = ApiKeys.rapidApiHost;
      
      print('🔧 RapidAPI Key length: ${rapidKey.length}');
      print('🔧 RapidAPI Host: $rapidHost');
      print('🔧 Base URL: ${ApiConfig.rapidApiBaseUrl}');

      if (rapidKey.isEmpty || rapidKey == 'your-rapid-api-key-here') {
        print('❌ RapidAPI key not configured properly!');
        throw Exception('RapidAPI key is not configured. Please add RAPIDAPI_KEY to .env file');
      }
      
      if (rapidHost.isEmpty) {
        print('❌ RapidAPI host not configured properly!');
        throw Exception('RapidAPI host is not configured. Please add RAPIDAPI_HOST to .env file');
      }

      // Note: Surepass integration available but not currently active
      print('ℹ️  Using RapidAPI for vehicle verification');

      print('✅ API configuration validated');
      ApiKeys.debugApiKeyStatus();
    } catch (e) {
      print('❌ API configuration error: $e');
      throw Exception('Invalid API configuration. Please check your setup: $e');
    }
  }

  Future<Map<String, dynamic>> _makeApiCallWithRetry(String vehicleNumber) async {
    int attemptCount = 0;
    Exception? lastException;
    
    while (attemptCount < ApiConfig.maxRetries) {
      attemptCount++;
      print('🔄 Attempt $attemptCount of ${ApiConfig.maxRetries}');
      
      try {
        return await _tryMultipleEndpoints(vehicleNumber);
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        final errorMessage = e.toString().toLowerCase();
        
        print('⚠️  Attempt $attemptCount failed: $errorMessage');
        
        // Handle specific non-retryable errors
        if (errorMessage.contains('rate limit') || errorMessage.contains('too many requests') || errorMessage.contains('429')) {
          print('❌ Rate limit error - not retrying');
          throw Exception('Rate limit exceeded. Please wait a moment and try again.');
        }
        
        if (errorMessage.contains('not subscribed') || errorMessage.contains('403') || errorMessage.contains('unauthorized') || errorMessage.contains('401')) {
          print('❌ Authentication error - not retrying');
          throw Exception('API subscription required. Please check your RapidAPI subscription and API key.');
        }
        
        if (errorMessage.contains('invalid') && errorMessage.contains('vehicle')) {
          print('❌ Invalid vehicle number - not retrying');
          throw Exception('Vehicle number not found or invalid format.');
        }
        
        // Retry for transient errors (network, timeout, 5xx errors)
        if (attemptCount < ApiConfig.maxRetries) {
          final retryable = errorMessage.contains('timeout') || 
                           errorMessage.contains('network') ||
                           errorMessage.contains('502') ||
                           errorMessage.contains('503') ||
                           errorMessage.contains('504');
          
          if (retryable) {
            final delaySeconds = ApiConfig.retryDelay.inSeconds * attemptCount; // Exponential backoff
            print('🔄 Retrying in $delaySeconds seconds...');
            await Future.delayed(Duration(seconds: delaySeconds));
            continue;
          }
        }
        
        // Re-throw if not retryable or max retries reached
        if (attemptCount >= ApiConfig.maxRetries) {
          print('❌ Max retries reached. Giving up.');
        }
      }
    }
    
    // If we get here, all retries failed
    throw lastException ?? Exception('API request failed after ${ApiConfig.maxRetries} attempts');
  }

  Future<Map<String, dynamic>> _tryMultipleEndpoints(String vehicleNumber) async {
    print('📞 Making API request for vehicle: $vehicleNumber');
    final fullUrl = '${ApiConfig.rapidApiBaseUrl}${ApiConfig.vehicleDetailsEndpoint}';
    print('🌐 Full URL: $fullUrl');
    print('🌐 Base URL: ${ApiConfig.rapidApiBaseUrl}');
    print('🌐 Endpoint: ${ApiConfig.vehicleDetailsEndpoint}');
    print('🌐 RapidAPI Host Header: ${ApiKeys.rapidApiHost}');
    
    final requestBody = {
      'vehicle_no': vehicleNumber.toUpperCase(),
      'consent': 'Y',
      'consent_text': 'I hereby give my consent for Eccentric Labs API to fetch my information'
    };
    
    print('📤 Request body: $requestBody');
    print('⏱️  Request timestamp: ${DateTime.now().toIso8601String()}');
    print('💡 Testing with known working vehicle numbers:');
    print('   • MH12AB1234 (Mumbai)');
    print('   • DL1CAB1234 (Delhi)');
    print('   • KA01AB1234 (Karnataka)');
    
    try {
      final response = await httpClient.post(
        ApiConfig.vehicleDetailsEndpoint,
        body: requestBody,
      );
      
      print('✅ API response received successfully');
      print('📥 Response type: ${response.runtimeType}');
      print('📥 Response length: ${response.toString().length} characters');
      return response;
    } catch (e, stackTrace) {
      print('❌ API request failed: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  VehicleDetails _parseRapidApiResponse(Map<String, dynamic> response, String vehicleNumber) {
    try {
      print('🔍 Parsing API response: ${response.toString()}');
      
      // Check if response has the expected structure
      final data = response['data'] as Map<String, dynamic>?;
      
      if (data == null) {
        print('❌ No data field in response, using fallback parsing');
        // Fallback: try to parse response directly
        return _parseDirectResponse(response, vehicleNumber);
      }
      
      // Parse the actual API response structure
      return VehicleDetails(
        rc: data['rc']?.toString() ?? vehicleNumber,
        vinMasked: data['vin_masked']?.toString() ?? data['chassis_no']?.toString() ?? 'N/A',
        engineNoMasked: data['engine_no_masked']?.toString() ?? data['engine_no']?.toString() ?? 'N/A',
        makerModel: '${data['maker']?.toString() ?? 'Unknown'} ${data['model']?.toString() ?? ''}',
        fuel: data['fuel_type']?.toString() ?? data['fuel']?.toString() ?? 'Unknown',
        taxStatus: data['tax_status']?.toString() ?? 'Unknown',
        rcValidTill: data['rc_valid_till']?.toString() ?? data['rc_validity']?.toString() ?? 'Unknown',
        blacklist: data['blacklist_status']?.toString() ?? 'No',
        fitnessStatus: FitnessStatus(
          status: data['fitness_status']?.toString() ?? 'Unknown',
          fitnessValidTill: data['fitness_valid_till']?.toString() ?? 'Unknown',
          rcValidTill: data['rc_valid_till']?.toString() ?? 'Unknown',
        ),
        lienStatus: data['hypothecation'] != null 
          ? LienStatus(
              status: data['hypothecation']['status']?.toString() ?? 'Clear',
              bank: data['hypothecation']['bank']?.toString() ?? 'None',
              activeFrom: data['hypothecation']['active_from']?.toString() ?? 'N/A',
              activeTo: data['hypothecation']['active_to']?.toString() ?? 'N/A',
            )
          : const LienStatus(
              status: 'Clear',
              bank: 'None',
              activeFrom: 'N/A',
              activeTo: 'N/A',
            ),
      );
    } catch (e) {
      print('❌ Error parsing API response: $e');
      print('🔍 Raw response: $response');
      
      // Return a minimal response with error info
      return VehicleDetails(
        rc: vehicleNumber,
        vinMasked: 'Parsing Error',
        engineNoMasked: 'Check API Response Format',
        makerModel: 'Error: $e',
        fuel: 'Unknown',
        taxStatus: 'Unknown',
        rcValidTill: 'Unknown',
        blacklist: 'Unknown',
        fitnessStatus: const FitnessStatus(
          status: 'Error parsing response',
          fitnessValidTill: 'Unknown',
          rcValidTill: 'Unknown',
        ),
      );
    }
  }

  VehicleDetails _parseDirectResponse(Map<String, dynamic> response, String vehicleNumber) {
    // Direct parsing when no 'data' wrapper
    return VehicleDetails(
      rc: response['rc']?.toString() ?? vehicleNumber,
      vinMasked: response['vin_masked']?.toString() ?? response['chassis_no']?.toString() ?? 'Direct parse - no VIN',
      engineNoMasked: response['engine_no_masked']?.toString() ?? 'Direct parse - no engine',
      makerModel: '${response['maker']?.toString() ?? 'Unknown'} ${response['model']?.toString() ?? ''}',
      fuel: response['fuel_type']?.toString() ?? 'Unknown',
      taxStatus: response['tax_status']?.toString() ?? 'Unknown',
      rcValidTill: response['rc_valid_till']?.toString() ?? 'Unknown',
      blacklist: response['blacklist_status']?.toString() ?? 'No',
      fitnessStatus: FitnessStatus(
        status: response['fitness_status']?.toString() ?? 'Unknown',
        fitnessValidTill: response['fitness_valid_till']?.toString() ?? 'Unknown',
        rcValidTill: response['rc_valid_till']?.toString() ?? 'Unknown',
      ),
      lienStatus: const LienStatus(
        status: 'Clear',
        bank: 'None', 
        activeFrom: 'N/A',
        activeTo: 'N/A',
      ),
    );
  }

  void dispose() {
    httpClient.dispose();
  }
}