import '../../domain/entities/vehicle_details.dart';
import '../../core/services/http_client.dart';
import '../../core/config/api_config.dart';


abstract class VehicleRemoteDataSource {
  Future<VehicleDetails> getVehicleDetails(String vehicleNumber);
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final HttpClient httpClient;
  
  VehicleRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<VehicleDetails> getVehicleDetails(String vehicleNumber) async {
    print('🚀 Starting vehicle details fetch for: $vehicleNumber');
    
    // Validate API key first
    _validateApiKey();
    
    // Make API call directly without rate limiting
    final response = await _makeApiCallWithRetry(vehicleNumber);
    
    print('📝 Raw API Response: $response');
    
    // Handle RapidAPI response format - check multiple status fields
    final status = response['status'] as bool? ?? response['success'] as bool?;
    final message = response['message'] as String? ?? response['error'] as String?;
    
    if (status == false) {
      throw Exception('API Error: ${message ?? 'Unknown error'}');
    }
    
    // Parse response even if status is not explicitly true (some APIs don't include status field)
    return _parseRapidApiResponse(response, vehicleNumber);
  }

  void _validateApiKey() {
    // Add basic API key validation using the ApiKeys class
    try {
      print('🔧 API Base URL: ${ApiConfig.rapidApiBaseUrl}');
      print('✅ API configuration loaded');
      // The actual key validation happens in HttpClient._buildHeaders
    } catch (e) {
      print('❌ API configuration error: $e');
      throw Exception('Invalid API configuration. Please check your setup.');
    }
  }

  Future<Map<String, dynamic>> _makeApiCallWithRetry(String vehicleNumber) async {
    try {
      // Make single API call - no retries to avoid rate limiting
      return await _tryMultipleEndpoints(vehicleNumber);
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      
      // Handle specific rate limiting errors
      if (errorMessage.contains('rate limit') || errorMessage.contains('too many requests') || errorMessage.contains('429')) {
        throw Exception('Rate limit exceeded. Please wait a moment and try again.');
      }
      
      // Handle subscription errors
      if (errorMessage.contains('not subscribed') || errorMessage.contains('403')) {
        throw Exception('API subscription required. Please check your RapidAPI subscription.');
      }
      
      // Re-throw other errors
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _tryMultipleEndpoints(String vehicleNumber) async {
    print('� Making API request for vehicle: $vehicleNumber');
    
    final requestBody = {
      'vehicle_no': vehicleNumber,
      'consent': 'Y',
      'consent_text': 'I hereby give my consent for Eccentric Labs API to fetch my information'
    };
    
    final response = await httpClient.post(
      ApiConfig.vehicleDetailsEndpoint,
      body: requestBody,
    );
    
    print('✅ API response received');
    return response;
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