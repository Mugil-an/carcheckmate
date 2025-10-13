// lib/core/exceptions/fraud_awareness_exceptions.dart
// Fraud awareness module specific exceptions

/// Base class for all fraud awareness exceptions
abstract class FraudAwarenessException implements Exception {
  final String message;
  final String? errorCode;
  
  const FraudAwarenessException(this.message, {this.errorCode});
  
  @override
  String toString() => message;
}

/// Content loading exceptions
class FraudContentNotFoundException extends FraudAwarenessException {
  const FraudContentNotFoundException({String? errorCode}) 
      : super('Fraud awareness content not found. Please try refreshing.', errorCode: errorCode);
}

class FraudContentLoadFailedException extends FraudAwarenessException {
  const FraudContentLoadFailedException({String? errorCode}) 
      : super('Failed to load fraud awareness content. Please try again.', errorCode: errorCode);
}

class FraudContentCorruptedException extends FraudAwarenessException {
  const FraudContentCorruptedException({String? errorCode}) 
      : super('Fraud awareness content is corrupted. Please contact support.', errorCode: errorCode);
}

/// Content parsing exceptions
class FraudContentParsingException extends FraudAwarenessException {
  const FraudContentParsingException({String? errorCode}) 
      : super('Failed to parse fraud awareness content. Please try again.', errorCode: errorCode);
}

class InvalidFraudContentFormatException extends FraudAwarenessException {
  const InvalidFraudContentFormatException({String? errorCode}) 
      : super('Invalid fraud awareness content format.', errorCode: errorCode);
}

/// Interactive content exceptions
class FraudContentInteractionException extends FraudAwarenessException {
  const FraudContentInteractionException({String? errorCode}) 
      : super('Failed to interact with fraud awareness content.', errorCode: errorCode);
}

class FraudContentDisplayException extends FraudAwarenessException {
  const FraudContentDisplayException({String? errorCode}) 
      : super('Failed to display fraud awareness content properly.', errorCode: errorCode);
}

/// Content update exceptions
class FraudContentUpdateException extends FraudAwarenessException {
  const FraudContentUpdateException({String? errorCode}) 
      : super('Failed to update fraud awareness content.', errorCode: errorCode);
}

class FraudContentVersionException extends FraudAwarenessException {
  const FraudContentVersionException({String? errorCode}) 
      : super('Fraud awareness content version mismatch. Please update the app.', errorCode: errorCode);
}

/// Storage exceptions
class FraudContentStorageException extends FraudAwarenessException {
  const FraudContentStorageException({String? errorCode}) 
      : super('Failed to store fraud awareness content locally.', errorCode: errorCode);
}

class FraudContentCacheException extends FraudAwarenessException {
  const FraudContentCacheException({String? errorCode}) 
      : super('Failed to cache fraud awareness content.', errorCode: errorCode);
}

/// Navigation exceptions
class FraudContentNavigationException extends FraudAwarenessException {
  const FraudContentNavigationException({String? errorCode}) 
      : super('Failed to navigate fraud awareness content.', errorCode: errorCode);
}

/// Service exceptions
class FraudAwarenessServiceException extends FraudAwarenessException {
  const FraudAwarenessServiceException({String? errorCode}) 
      : super('Fraud awareness service is currently unavailable.', errorCode: errorCode);
}

/// Network related fraud awareness exceptions
class FraudAwarenessNetworkException extends FraudAwarenessException {
  const FraudAwarenessNetworkException({String? errorCode}) 
      : super('Network error while loading fraud awareness content. Please check your connection.', errorCode: errorCode);
}

/// Generic fraud awareness exception
class GenericFraudAwarenessException extends FraudAwarenessException {
  const GenericFraudAwarenessException([String? customMessage, String? errorCode]) 
      : super(customMessage ?? 'A fraud awareness error occurred. Please try again.', errorCode: errorCode);
}

/// Content synchronization exceptions
class FraudContentSyncException extends FraudAwarenessException {
  const FraudContentSyncException({String? errorCode}) 
      : super('Failed to synchronize fraud awareness content.', errorCode: errorCode);
}

/// User interaction tracking exceptions
class FraudContentTrackingException extends FraudAwarenessException {
  const FraudContentTrackingException({String? errorCode}) 
      : super('Failed to track fraud awareness content interaction.', errorCode: errorCode);
}