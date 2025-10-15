// lib/core/exceptions/admin_exceptions.dart
// Admin module specific exceptions

/// Base class for all admin exceptions
abstract class AdminException implements Exception {
  final String message;
  final String? errorCode;
  
  const AdminException(this.message, {this.errorCode});
  
  @override
  String toString() => message;
}

/// Access control exceptions
class AdminAccessDeniedException extends AdminException {
  final String userEmail;
  
  const AdminAccessDeniedException({
    required this.userEmail,
    String? errorCode,
  }) : super(
    'Access denied. Only authorized administrators can perform this action.\nCurrent user: $userEmail', 
    errorCode: errorCode
  );
}

class AdminAuthenticationRequiredException extends AdminException {
  const AdminAuthenticationRequiredException({String? errorCode}) 
      : super('Administrator authentication required. Please sign in with admin credentials.', errorCode: errorCode);
}

class AdminEmailNotVerifiedException extends AdminException {
  const AdminEmailNotVerifiedException({String? errorCode}) 
      : super('Email verification required for admin access. Please verify your email address.', errorCode: errorCode);
}

/// Data validation exceptions
class InvalidCarDataException extends AdminException {
  const InvalidCarDataException(String details, {String? errorCode}) 
      : super('Invalid car data: $details', errorCode: errorCode);
}

class DuplicateCarModelException extends AdminException {
  const DuplicateCarModelException(String carDetails, {String? errorCode}) 
      : super('Car model already exists: $carDetails', errorCode: errorCode);
}

/// Operation exceptions
class AdminOperationFailedException extends AdminException {
  const AdminOperationFailedException(String operation, {String? errorCode}) 
      : super('Admin operation failed: $operation', errorCode: errorCode);
}

class CarModelCreationException extends AdminException {
  const CarModelCreationException({String? errorCode}) 
      : super('Failed to create car model. Please check your input and try again.', errorCode: errorCode);
}

class CarModelUpdateException extends AdminException {
  const CarModelUpdateException({String? errorCode}) 
      : super('Failed to update car model. Please try again.', errorCode: errorCode);
}

class CarModelDeletionException extends AdminException {
  const CarModelDeletionException({String? errorCode}) 
      : super('Failed to delete car model. Please try again.', errorCode: errorCode);
}

/// Database exceptions
class AdminDatabaseException extends AdminException {
  const AdminDatabaseException({String? errorCode}) 
      : super('Database error occurred during admin operation.', errorCode: errorCode);
}

class AdminNetworkException extends AdminException {
  const AdminNetworkException({String? errorCode}) 
      : super('Network error during admin operation. Please check your connection.', errorCode: errorCode);
}

/// Validation helper exceptions
class AdminValidationException extends AdminException {
  const AdminValidationException(String details, {String? errorCode}) 
      : super('Validation error: $details', errorCode: errorCode);
}

/// Generic admin exception
class GenericAdminException extends AdminException {
  const GenericAdminException([String? customMessage, String? errorCode]) 
      : super(customMessage ?? 'An admin error occurred. Please try again.', errorCode: errorCode);
}