// lib/core/exceptions/app_exceptions.dart
// General application exceptions and utility functions

import 'auth_exceptions.dart' as auth;
import 'checklist_exceptions.dart';
import 'rto_exceptions.dart';
import 'ocr_exceptions.dart';
import 'survey_exceptions.dart';
import 'fraud_awareness_exceptions.dart';
import 'network_exceptions.dart' as network;

/// Base class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final String? errorCode;
  final DateTime timestamp;
  
  AppException(this.message, {this.errorCode, DateTime? timestamp}) 
      : timestamp = timestamp ?? DateTime.now();
  
  @override
  String toString() => message;
}

/// Storage and database exceptions
class StorageException extends AppException {
  StorageException(super.message, {super.errorCode});
}

class DatabaseException extends AppException {
  DatabaseException(super.message, {super.errorCode});
}

class CacheException extends AppException {
  CacheException(super.message, {super.errorCode});
}

/// Permission exceptions
class PermissionException extends AppException {
  PermissionException(super.message, {super.errorCode});
}

class CameraPermissionDeniedException extends PermissionException {
  CameraPermissionDeniedException({String? errorCode}) 
      : super('Camera permission denied. Please enable camera access in settings.', errorCode: errorCode);
}

class StoragePermissionDeniedException extends PermissionException {
  StoragePermissionDeniedException({String? errorCode}) 
      : super('Storage permission denied. Please enable storage access in settings.', errorCode: errorCode);
}

class LocationPermissionDeniedException extends PermissionException {
  LocationPermissionDeniedException({String? errorCode}) 
      : super('Location permission denied. Please enable location access in settings.', errorCode: errorCode);
}

/// Device exceptions
class DeviceException extends AppException {
  DeviceException(super.message, {super.errorCode});
}

class DeviceNotSupportedException extends DeviceException {
  DeviceNotSupportedException({String? errorCode}) 
      : super('This feature is not supported on your device.', errorCode: errorCode);
}

class InsufficientStorageException extends DeviceException {
  InsufficientStorageException({String? errorCode}) 
      : super('Insufficient storage space. Please free up space and try again.', errorCode: errorCode);
}

class LowMemoryException extends DeviceException {
  LowMemoryException({String? errorCode}) 
      : super('Device is low on memory. Please close other apps and try again.', errorCode: errorCode);
}

/// Configuration and setup exceptions
class ConfigurationException extends AppException {
  ConfigurationException(super.message, {super.errorCode});
}

class InvalidConfigurationException extends ConfigurationException {
  InvalidConfigurationException({String? errorCode}) 
      : super('Invalid app configuration. Please contact support.', errorCode: errorCode);
}

class MissingConfigurationException extends ConfigurationException {
  MissingConfigurationException({String? errorCode}) 
      : super('Missing app configuration. Please update the app.', errorCode: errorCode);
}

/// Navigation exceptions
class NavigationException extends AppException {
  NavigationException(super.message, {super.errorCode});
}

class RouteNotFoundException extends NavigationException {
  RouteNotFoundException(String routeName, {String? errorCode}) 
      : super('Route not found: $routeName', errorCode: errorCode);
}

class NavigationContextException extends NavigationException {
  NavigationContextException({String? errorCode}) 
      : super('Navigation context is not available.', errorCode: errorCode);
}

/// Validation exceptions
class ValidationException extends AppException {
  ValidationException(super.message, {super.errorCode});
}

class RequiredFieldException extends ValidationException {
  RequiredFieldException(String fieldName, {String? errorCode}) 
      : super('$fieldName is required.', errorCode: errorCode);
}

class InvalidFormatException extends ValidationException {
  InvalidFormatException(String fieldName, {String? errorCode}) 
      : super('Invalid format for $fieldName.', errorCode: errorCode);
}

class OutOfRangeException extends ValidationException {
  OutOfRangeException(String fieldName, String range, {String? errorCode}) 
      : super('$fieldName must be within $range.', errorCode: errorCode);
}

/// File system exceptions
class FileSystemException extends AppException {
  FileSystemException(super.message, {super.errorCode});
}

class FileNotFoundException extends FileSystemException {
  FileNotFoundException(String fileName, {String? errorCode}) 
      : super('File not found: $fileName', errorCode: errorCode);
}

class FileAccessException extends FileSystemException {
  FileAccessException({String? errorCode}) 
      : super('Cannot access file. Please check permissions.', errorCode: errorCode);
}

class FileCorruptedException extends FileSystemException {
  FileCorruptedException({String? errorCode}) 
      : super('File is corrupted or unreadable.', errorCode: errorCode);
}

/// Initialization exceptions
class InitializationException extends AppException {
  InitializationException(super.message, {super.errorCode});
}

class ServiceInitializationException extends InitializationException {
  ServiceInitializationException(String serviceName, {String? errorCode}) 
      : super('Failed to initialize $serviceName service.', errorCode: errorCode);
}

class DatabaseInitializationException extends InitializationException {
  DatabaseInitializationException({String? errorCode}) 
      : super('Failed to initialize database.', errorCode: errorCode);
}

/// Generic app exception for unhandled cases
class GenericAppException extends AppException {
  GenericAppException([String? customMessage, String? errorCode]) 
      : super(customMessage ?? 'An unexpected error occurred. Please try again.', errorCode: errorCode);
}

/// Utility class for exception handling across modules
class ExceptionHelper {
  /// Determine the module type based on exception
  static String getModuleFromException(Exception exception) {
    if (exception is auth.AuthException) return 'Authentication';
    if (exception is ChecklistException) return 'Checklist';
    if (exception is RTOException) return 'RTO Verification';
    if (exception is OCRException) return 'Document Processing';
    if (exception is SurveyException) return 'Survey';
    if (exception is FraudAwarenessException) return 'Fraud Awareness';
    if (exception is network.NetworkException) return 'Network';
    if (exception is AppException) return 'Application';
    return 'System';
  }
  
  /// Get user-friendly error message
  static String getUserFriendlyMessage(Exception exception) {
    if (exception is AppException) {
      return exception.message;
    }
    if (exception is auth.AuthException) {
      return exception.message;
    }
    if (exception is ChecklistException) {
      return exception.message;
    }
    if (exception is RTOException) {
      return exception.message;
    }
    if (exception is OCRException) {
      return exception.message;
    }
    if (exception is SurveyException) {
      return exception.message;
    }
    if (exception is FraudAwarenessException) {
      return exception.message;
    }
    if (exception is network.NetworkException) {
      return exception.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
  
  /// Check if exception is recoverable
  static bool isRecoverable(Exception exception) {
    // Network errors are usually recoverable
    if (exception is network.NetworkException) return true;
    
    // Permission errors are recoverable by user action
    if (exception is PermissionException) return true;
    
    // Validation errors are recoverable by fixing input
    if (exception is ValidationException) return true;
    
    // Most app exceptions are recoverable
    if (exception is AppException) {
      // Configuration errors usually need app update
      if (exception is ConfigurationException) return false;
      // Device compatibility issues are not recoverable
      if (exception is DeviceNotSupportedException) return false;
      return true;
    }
    
    return true; // Default to recoverable
  }
  
  /// Get suggested action for exception
  static String? getSuggestedAction(Exception exception) {
    if (exception is network.NoInternetConnectionException) {
      return 'Check your internet connection and try again';
    }
    if (exception is CameraPermissionDeniedException) {
      return 'Go to Settings > Permissions > Camera and enable access';
    }
    if (exception is StoragePermissionDeniedException) {
      return 'Go to Settings > Permissions > Storage and enable access';
    }
    if (exception is InsufficientStorageException) {
      return 'Free up storage space on your device';
    }
    if (exception is auth.TooManyRequestsException || exception is network.TooManyRequestsException) {
      return 'Please wait a few minutes before trying again';
    }
    if (exception is ValidationException) {
      return 'Please check your input and try again';
    }
    return null;
  }
}