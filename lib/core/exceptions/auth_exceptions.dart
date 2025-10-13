// lib/core/exceptions/auth_exceptions.dart
// Authentication related exceptions

/// Base class for all authentication exceptions
abstract class AuthException implements Exception {
  final String message;
  final String? errorCode;
  
  const AuthException(this.message, {this.errorCode});
  
  @override
  String toString() => message;
}

/// Login specific exceptions
class UserNotFoundException extends AuthException {
  const UserNotFoundException({String? errorCode}) 
      : super('No account found with this email address.', errorCode: errorCode);
}

class IncorrectPasswordException extends AuthException {
  const IncorrectPasswordException({String? errorCode}) 
      : super('Incorrect password. Please check and try again.', errorCode: errorCode);
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException({String? errorCode}) 
      : super('Invalid email or password combination.', errorCode: errorCode);
}

class UserDisabledException extends AuthException {
  const UserDisabledException({String? errorCode}) 
      : super('This account has been disabled. Please contact support.', errorCode: errorCode);
}

class TooManyRequestsException extends AuthException {
  const TooManyRequestsException({String? errorCode}) 
      : super('Too many failed attempts. Please try again later.', errorCode: errorCode);
}

/// Registration specific exceptions
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException({String? errorCode}) 
      : super('An account with this email already exists.', errorCode: errorCode);
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException({String? errorCode}) 
      : super('Password is too weak. Please use at least 6 characters.', errorCode: errorCode);
}

class InvalidEmailException extends AuthException {
  const InvalidEmailException({String? errorCode}) 
      : super('Please enter a valid email address.', errorCode: errorCode);
}

/// Password reset exceptions
class PasswordResetFailedException extends AuthException {
  const PasswordResetFailedException({String? errorCode}) 
      : super('Failed to send password reset email. Please try again.', errorCode: errorCode);
}

class InvalidPasswordResetCodeException extends AuthException {
  const InvalidPasswordResetCodeException({String? errorCode}) 
      : super('Invalid or expired password reset code.', errorCode: errorCode);
}

/// Email verification exceptions
class EmailVerificationFailedException extends AuthException {
  const EmailVerificationFailedException({String? errorCode}) 
      : super('Failed to send verification email. Please try again.', errorCode: errorCode);
}

class EmailNotVerifiedException extends AuthException {
  const EmailNotVerifiedException({String? errorCode}) 
      : super('Please verify your email before continuing.', errorCode: errorCode);
}

/// Session and token exceptions
class UserNotLoggedInException extends AuthException {
  const UserNotLoggedInException({String? errorCode}) 
      : super('You need to log in to perform this action.', errorCode: errorCode);
}

class SessionExpiredException extends AuthException {
  const SessionExpiredException({String? errorCode}) 
      : super('Your session has expired. Please log in again.', errorCode: errorCode);
}

class RequiresRecentLoginException extends AuthException {
  const RequiresRecentLoginException({String? errorCode}) 
      : super('Please log out and log in again to perform this action.', errorCode: errorCode);
}

/// Network related auth exceptions
class AuthNetworkException extends AuthException {
  const AuthNetworkException({String? errorCode}) 
      : super('Network error during authentication. Please check your connection.', errorCode: errorCode);
}

/// Generic auth exception for unhandled cases
class GenericAuthException extends AuthException {
  const GenericAuthException([String? customMessage, String? errorCode]) 
      : super(customMessage ?? 'An authentication error occurred. Please try again.', errorCode: errorCode);
}

/// Auth service unavailable
class AuthServiceUnavailableException extends AuthException {
  const AuthServiceUnavailableException({String? errorCode}) 
      : super('Authentication service is currently unavailable. Please try again later.', errorCode: errorCode);
}