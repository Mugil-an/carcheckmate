import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  // Load API keys from .env file
  static String get rapidApiKey => dotenv.env['RAPIDAPI_KEY'] ?? 'your-rapid-api-key-here';
  
  static String get rapidApiHost => dotenv.env['RAPIDAPI_HOST'] ?? 'rto-vehicle-information-india.p.rapidapi.com';
  
  // Alternative: Use a secure storage solution
  // static String? _rapidApiKey;
  // static String? _rtoApiKey;
  
  // static Future<void> loadApiKeys() async {
  //   final secureStorage = FlutterSecureStorage();
  //   _rapidApiKey = await secureStorage.read(key: 'rapid_api_key');
  //   _rtoApiKey = await secureStorage.read(key: 'rto_api_key');
  // }
  
  static Map<String, String> get rapidApiHeaders => {
    'x-rapidapi-key': rapidApiKey,
    'x-rapidapi-host': rapidApiHost,
    'x-rapidapi-ua': 'RapidAPI-Playground',
    'Content-Type': 'application/json',
  };
  
  // Debug method to check API key configuration
  static void debugApiKeyStatus() {
    print('🔑 API Key Status:');
    print('   RAPIDAPI_KEY: ${rapidApiKey.length > 10 ? '${rapidApiKey.substring(0, 10)}...' : rapidApiKey}');
    print('   Is Valid: ${rapidApiKey != 'your-rapid-api-key-here' && rapidApiKey.isNotEmpty}');
    print('   Host: rto-vehicle-information-india.p.rapidapi.com');
  }
  
  // Debug method to verify exact request format
  static void debugRequestFormat() {
    print('🔧 EXPECTED REQUEST FORMAT:');
    print('🔧 URL: https://rto-vehicle-information-india.p.rapidapi.com/getVehicleInfo');
    print('🔧 Method: POST');
    print('🔧 Headers:');
    rapidApiHeaders.forEach((key, value) {
      if (key.toLowerCase().contains('key')) {
        print('🔧   $key: ${value.length > 10 ? value.substring(0, 10) + '...' : value}');
      } else {
        print('🔧   $key: $value');
      }
    });
    print('🔧 Body: {"vehicle_no": "UP16CD1993", "consent": "Y", "consent_text": "I hereby give my consent for Eccentric Labs API to fetch my information"}');
  }
}
