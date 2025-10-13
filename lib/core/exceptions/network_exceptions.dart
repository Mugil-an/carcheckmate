// lib/core/exceptions/network_exceptions.dart
// Network and connectivity specific exceptions

/// Base class for all network exceptions
abstract class NetworkException implements Exception {
  final String message;
  final String? errorCode;
  
  const NetworkException(this.message, {this.errorCode});
  
  @override
  String toString() => message;
}

/// Connection exceptions
class NoInternetConnectionException extends NetworkException {
  const NoInternetConnectionException({String? errorCode}) 
      : super('No internet connection. Please check your network settings.', errorCode: errorCode);
}

class ConnectionTimeoutException extends NetworkException {
  const ConnectionTimeoutException({String? errorCode}) 
      : super('Connection timed out. Please try again.', errorCode: errorCode);
}

class ConnectionRefusedException extends NetworkException {
  const ConnectionRefusedException({String? errorCode}) 
      : super('Connection was refused by the server. Please try again later.', errorCode: errorCode);
}

class ConnectionLostException extends NetworkException {
  const ConnectionLostException({String? errorCode}) 
      : super('Connection lost. Please check your network and try again.', errorCode: errorCode);
}

/// HTTP exceptions
class HTTPException extends NetworkException {
  final int? statusCode;
  
  const HTTPException(String message, {this.statusCode, String? errorCode}) 
      : super(message, errorCode: errorCode);
}

class BadRequestException extends HTTPException {
  const BadRequestException({String? errorCode}) 
      : super('Bad request. Please check your input and try again.', statusCode: 400, errorCode: errorCode);
}

class UnauthorizedException extends HTTPException {
  const UnauthorizedException({String? errorCode}) 
      : super('Unauthorized access. Please log in and try again.', statusCode: 401, errorCode: errorCode);
}

class ForbiddenException extends HTTPException {
  const ForbiddenException({String? errorCode}) 
      : super('Access forbidden. You don\'t have permission to perform this action.', statusCode: 403, errorCode: errorCode);
}

class NotFoundException extends HTTPException {
  const NotFoundException({String? errorCode}) 
      : super('Resource not found. Please try again.', statusCode: 404, errorCode: errorCode);
}

class MethodNotAllowedException extends HTTPException {
  const MethodNotAllowedException({String? errorCode}) 
      : super('Method not allowed.', statusCode: 405, errorCode: errorCode);
}

class ConflictException extends HTTPException {
  const ConflictException({String? errorCode}) 
      : super('Request conflict. Please try again.', statusCode: 409, errorCode: errorCode);
}

class TooManyRequestsException extends HTTPException {
  const TooManyRequestsException({String? errorCode}) 
      : super('Too many requests. Please try again later.', statusCode: 429, errorCode: errorCode);
}

class InternalServerErrorException extends HTTPException {
  const InternalServerErrorException({String? errorCode}) 
      : super('Internal server error. Please try again later.', statusCode: 500, errorCode: errorCode);
}

class BadGatewayException extends HTTPException {
  const BadGatewayException({String? errorCode}) 
      : super('Bad gateway. Please try again later.', statusCode: 502, errorCode: errorCode);
}

class ServiceUnavailableException extends HTTPException {
  const ServiceUnavailableException({String? errorCode}) 
      : super('Service temporarily unavailable. Please try again later.', statusCode: 503, errorCode: errorCode);
}

class GatewayTimeoutException extends HTTPException {
  const GatewayTimeoutException({String? errorCode}) 
      : super('Gateway timeout. Please try again.', statusCode: 504, errorCode: errorCode);
}

/// API specific exceptions
class APIException extends NetworkException {
  const APIException({String? errorCode}) 
      : super('API service error occurred. Please try again.', errorCode: errorCode);
}

class APIKeyException extends NetworkException {
  const APIKeyException({String? errorCode}) 
      : super('Invalid API key. Please contact support.', errorCode: errorCode);
}

class APIRateLimitException extends NetworkException {
  const APIRateLimitException({String? errorCode}) 
      : super('API rate limit exceeded. Please try again later.', errorCode: errorCode);
}

class APIVersionException extends NetworkException {
  const APIVersionException({String? errorCode}) 
      : super('API version not supported. Please update the app.', errorCode: errorCode);
}

/// Data transfer exceptions
class DataTransferException extends NetworkException {
  const DataTransferException({String? errorCode}) 
      : super('Data transfer failed. Please try again.', errorCode: errorCode);
}

class UploadFailedException extends NetworkException {
  const UploadFailedException({String? errorCode}) 
      : super('Upload failed. Please check your connection and try again.', errorCode: errorCode);
}

class DownloadFailedException extends NetworkException {
  const DownloadFailedException({String? errorCode}) 
      : super('Download failed. Please check your connection and try again.', errorCode: errorCode);
}

class DataCorruptionException extends NetworkException {
  const DataCorruptionException({String? errorCode}) 
      : super('Data corruption detected during transfer. Please try again.', errorCode: errorCode);
}

/// SSL/TLS exceptions
class SSLException extends NetworkException {
  const SSLException({String? errorCode}) 
      : super('SSL connection error. Please check your network security settings.', errorCode: errorCode);
}

class CertificateException extends NetworkException {
  const CertificateException({String? errorCode}) 
      : super('Invalid security certificate. Please try again later.', errorCode: errorCode);
}

/// DNS exceptions
class DNSException extends NetworkException {
  const DNSException({String? errorCode}) 
      : super('DNS resolution failed. Please check your network settings.', errorCode: errorCode);
}

/// Proxy exceptions
class ProxyException extends NetworkException {
  const ProxyException({String? errorCode}) 
      : super('Proxy connection error. Please check your proxy settings.', errorCode: errorCode);
}

/// Generic network exception
class GenericNetworkException extends NetworkException {
  const GenericNetworkException([String? customMessage, String? errorCode]) 
      : super(customMessage ?? 'A network error occurred. Please check your connection and try again.', errorCode: errorCode);
}

/// Connectivity monitoring exceptions
class ConnectivityMonitoringException extends NetworkException {
  const ConnectivityMonitoringException({String? errorCode}) 
      : super('Failed to monitor network connectivity.', errorCode: errorCode);
}

/// Cache exceptions related to network
class NetworkCacheException extends NetworkException {
  const NetworkCacheException({String? errorCode}) 
      : super('Network cache error. Please clear cache and try again.', errorCode: errorCode);
}