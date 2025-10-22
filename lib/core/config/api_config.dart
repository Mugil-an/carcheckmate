class ApiConfig {
  static const String rapidApiBaseUrl = 'https://rto-vehicle-information-india.p.rapidapi.com';
  
  // RapidAPI RTO endpoints (from official documentation)
  static const String vehicleDetailsEndpoint = '/getVehicleInfo';
  static const String vehicleChallanEndpoint = '/getVehicleChallan';
  static const String vehicleFullDetailsEndpoint = '/getVehicleInfo';
  
  // API Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeout configurations (reduced for better UX)
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  
  // Rate limiting - Conservative settings for RapidAPI
  static const int maxRetries = 2;
  static const Duration retryDelay = Duration(seconds: 3);
}