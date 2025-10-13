// lib/core/exceptions/rto_exceptions.dart
// RTO and vehicle verification specific exceptions

/// Base class for all RTO exceptions
abstract class RTOException implements Exception {
  final String message;
  final String? errorCode;
  
  const RTOException(this.message, {this.errorCode});
  
  @override
  String toString() => message;
}

/// Vehicle number validation exceptions
class InvalidVehicleNumberException extends RTOException {
  const InvalidVehicleNumberException({String? errorCode}) 
      : super('Invalid vehicle registration number format. Please check and try again.', errorCode: errorCode);
}

class VehicleNumberNotFoundException extends RTOException {
  const VehicleNumberNotFoundException({String? errorCode}) 
      : super('Vehicle registration number not found in RTO database.', errorCode: errorCode);
}

class VehicleNumberFormatException extends RTOException {
  const VehicleNumberFormatException({String? errorCode}) 
      : super('Please enter vehicle number in correct format (e.g., TN01AB1234).', errorCode: errorCode);
}

/// RTO API and service exceptions
class RTOAPIException extends RTOException {
  const RTOAPIException({String? errorCode}) 
      : super('RTO service is currently unavailable. Please try again later.', errorCode: errorCode);
}

class RTOAPITimeoutException extends RTOException {
  const RTOAPITimeoutException({String? errorCode}) 
      : super('RTO verification request timed out. Please try again.', errorCode: errorCode);
}

class RTOAPIRateLimitException extends RTOException {
  const RTOAPIRateLimitException({String? errorCode}) 
      : super('Too many RTO verification requests. Please try again after some time.', errorCode: errorCode);
}

class RTODataNotFoundException extends RTOException {
  const RTODataNotFoundException({String? errorCode}) 
      : super('No RTO data found for this vehicle. Please verify the registration number.', errorCode: errorCode);
}

/// Document verification exceptions
class RCVerificationFailedException extends RTOException {
  const RCVerificationFailedException({String? errorCode}) 
      : super('RC document verification failed. Please check your documents.', errorCode: errorCode);
}

class VINVerificationFailedException extends RTOException {
  const VINVerificationFailedException({String? errorCode}) 
      : super('VIN/Chassis number verification failed. Please check the number.', errorCode: errorCode);
}

class EngineNumberVerificationFailedException extends RTOException {
  const EngineNumberVerificationFailedException({String? errorCode}) 
      : super('Engine number verification failed. Please check the number.', errorCode: errorCode);
}

/// Lien and hypothecation exceptions
class LienVerificationException extends RTOException {
  const LienVerificationException({String? errorCode}) 
      : super('Failed to verify lien status. Please try again.', errorCode: errorCode);
}

class HypothecationDataException extends RTOException {
  const HypothecationDataException({String? errorCode}) 
      : super('Failed to fetch hypothecation details. Please try again.', errorCode: errorCode);
}

class LienStatusUnavailableException extends RTOException {
  const LienStatusUnavailableException({String? errorCode}) 
      : super('Lien status information is not available for this vehicle.', errorCode: errorCode);
}

/// Tax and fitness exceptions
class TaxStatusException extends RTOException {
  const TaxStatusException({String? errorCode}) 
      : super('Failed to fetch tax status information. Please try again.', errorCode: errorCode);
}

class FitnessStatusException extends RTOException {
  const FitnessStatusException({String? errorCode}) 
      : super('Failed to fetch fitness certificate status. Please try again.', errorCode: errorCode);
}

class InsuranceStatusException extends RTOException {
  const InsuranceStatusException({String? errorCode}) 
      : super('Failed to fetch insurance status. Please try again.', errorCode: errorCode);
}

/// Challan and penalty exceptions
class ChallanDataException extends RTOException {
  const ChallanDataException({String? errorCode}) 
      : super('Failed to fetch e-Challan data. Please try again.', errorCode: errorCode);
}

class PenaltyVerificationException extends RTOException {
  const PenaltyVerificationException({String? errorCode}) 
      : super('Failed to verify pending penalties. Please try again.', errorCode: errorCode);
}

/// Blacklist verification exceptions
class BlacklistVerificationException extends RTOException {
  const BlacklistVerificationException({String? errorCode}) 
      : super('Failed to verify blacklist status. Please try again.', errorCode: errorCode);
}

class VehicleBlacklistedException extends RTOException {
  const VehicleBlacklistedException({String? errorCode}) 
      : super('This vehicle is blacklisted. Please verify with authorities.', errorCode: errorCode);
}

/// Authentication and permission exceptions
class RTOAuthenticationException extends RTOException {
  const RTOAuthenticationException({String? errorCode}) 
      : super('Authentication failed for RTO service. Please try again.', errorCode: errorCode);
}

class RTOPermissionException extends RTOException {
  const RTOPermissionException({String? errorCode}) 
      : super('Permission denied for RTO verification service.', errorCode: errorCode);
}

/// Network related RTO exceptions
class RTONetworkException extends RTOException {
  const RTONetworkException({String? errorCode}) 
      : super('Network error during RTO verification. Please check your connection.', errorCode: errorCode);
}

/// Generic RTO exception
class GenericRTOException extends RTOException {
  const GenericRTOException([String? customMessage, String? errorCode]) 
      : super(customMessage ?? 'An RTO verification error occurred. Please try again.', errorCode: errorCode);
}

/// Service maintenance exceptions
class RTOServiceMaintenanceException extends RTOException {
  const RTOServiceMaintenanceException({String? errorCode}) 
      : super('RTO service is under maintenance. Please try again later.', errorCode: errorCode);
}

class RTODatabaseException extends RTOException {
  const RTODatabaseException({String? errorCode}) 
      : super('RTO database error occurred. Please try again later.', errorCode: errorCode);
}