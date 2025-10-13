// lib/core/exceptions/checklist_exceptions.dart
// Checklist module specific exceptions

/// Base class for all checklist exceptions
abstract class ChecklistException implements Exception {
  final String message;
  final String? errorCode;
  
  const ChecklistException(this.message, {this.errorCode});
  
  @override
  String toString() => message;
}

/// Data loading exceptions
class ChecklistDataNotFoundException extends ChecklistException {
  const ChecklistDataNotFoundException({String? errorCode}) 
      : super('Checklist data not found. Please try refreshing.', errorCode: errorCode);
}

class ChecklistLoadFailedException extends ChecklistException {
  const ChecklistLoadFailedException({String? errorCode}) 
      : super('Failed to load checklist data. Please try again.', errorCode: errorCode);
}

class CarDataNotFoundException extends ChecklistException {
  const CarDataNotFoundException({String? errorCode}) 
      : super('Car data not found. Please select a valid vehicle.', errorCode: errorCode);
}

class CarListLoadFailedException extends ChecklistException {
  const CarListLoadFailedException({String? errorCode}) 
      : super('Failed to load car list. Please check your connection and try again.', errorCode: errorCode);
}

/// Validation exceptions
class InvalidCarSelectionException extends ChecklistException {
  const InvalidCarSelectionException({String? errorCode}) 
      : super('Please select a valid car before proceeding.', errorCode: errorCode);
}

class ChecklistValidationFailedException extends ChecklistException {
  const ChecklistValidationFailedException({String? errorCode}) 
      : super('Checklist validation failed. Please complete all required items.', errorCode: errorCode);
}

class InvalidChecklistItemException extends ChecklistException {
  const InvalidChecklistItemException({String? errorCode}) 
      : super('Invalid checklist item selected. Please try again.', errorCode: errorCode);
}

/// Risk calculation exceptions
class RiskCalculationFailedException extends ChecklistException {
  const RiskCalculationFailedException({String? errorCode}) 
      : super('Failed to calculate risk score. Please try again.', errorCode: errorCode);
}

class InvalidRiskDataException extends ChecklistException {
  const InvalidRiskDataException({String? errorCode}) 
      : super('Invalid risk calculation data. Please check your selections.', errorCode: errorCode);
}

/// Submission exceptions
class ChecklistSubmissionFailedException extends ChecklistException {
  const ChecklistSubmissionFailedException({String? errorCode}) 
      : super('Failed to submit checklist. Please try again.', errorCode: errorCode);
}

class ChecklistSaveFailedException extends ChecklistException {
  const ChecklistSaveFailedException({String? errorCode}) 
      : super('Failed to save checklist progress. Please try again.', errorCode: errorCode);
}

/// State management exceptions
class ChecklistStateException extends ChecklistException {
  const ChecklistStateException({String? errorCode}) 
      : super('Checklist state error occurred. Please restart the checklist.', errorCode: errorCode);
}

class ChecklistInitializationException extends ChecklistException {
  const ChecklistInitializationException({String? errorCode}) 
      : super('Failed to initialize checklist. Please try again.', errorCode: errorCode);
}

/// Car selection specific exceptions
class CarSelectionException extends ChecklistException {
  const CarSelectionException({String? errorCode}) 
      : super('Car selection error occurred. Please try selecting again.', errorCode: errorCode);
}

class CarFilterException extends ChecklistException {
  const CarFilterException({String? errorCode}) 
      : super('Failed to filter car list. Please clear filters and try again.', errorCode: errorCode);
}

/// Network related checklist exceptions
class ChecklistNetworkException extends ChecklistException {
  const ChecklistNetworkException({String? errorCode}) 
      : super('Network error while loading checklist. Please check your connection.', errorCode: errorCode);
}

/// Generic checklist exception
class GenericChecklistException extends ChecklistException {
  const GenericChecklistException([String? customMessage, String? errorCode]) 
      : super(customMessage ?? 'A checklist error occurred. Please try again.', errorCode: errorCode);
}

/// Checklist timeout exceptions
class ChecklistTimeoutException extends ChecklistException {
  const ChecklistTimeoutException({String? errorCode}) 
      : super('Checklist operation timed out. Please try again.', errorCode: errorCode);
}

/// Permission exceptions
class ChecklistPermissionException extends ChecklistException {
  const ChecklistPermissionException({String? errorCode}) 
      : super('Permission denied for checklist operation.', errorCode: errorCode);
}