// lib/core/exceptions/survey_exceptions.dart
// Survey and feedback module specific exceptions

/// Base class for all survey exceptions
abstract class SurveyException implements Exception {
  final String message;
  final String? errorCode;
  
  const SurveyException(this.message, {this.errorCode});
  
  @override
  String toString() => message;
}

/// Survey data exceptions
class SurveyDataNotFoundException extends SurveyException {
  const SurveyDataNotFoundException({String? errorCode}) 
      : super('Survey data not found. Please try refreshing.', errorCode: errorCode);
}

class SurveyLoadFailedException extends SurveyException {
  const SurveyLoadFailedException({String? errorCode}) 
      : super('Failed to load survey. Please try again.', errorCode: errorCode);
}

class SurveyConfigurationException extends SurveyException {
  const SurveyConfigurationException({String? errorCode}) 
      : super('Survey configuration error. Please contact support.', errorCode: errorCode);
}

/// Form validation exceptions
class SurveyValidationException extends SurveyException {
  const SurveyValidationException({String? errorCode}) 
      : super('Please complete all required survey fields.', errorCode: errorCode);
}

class InvalidSurveyResponseException extends SurveyException {
  const InvalidSurveyResponseException({String? errorCode}) 
      : super('Invalid survey response. Please check your answers.', errorCode: errorCode);
}

class SurveyFieldRequiredException extends SurveyException {
  const SurveyFieldRequiredException(String fieldName, {String? errorCode}) 
      : super('$fieldName is required. Please provide this information.', errorCode: errorCode);
}

class InvalidRatingException extends SurveyException {
  const InvalidRatingException({String? errorCode}) 
      : super('Please provide a valid rating between 1 and 5.', errorCode: errorCode);
}

class InvalidEmailFormatException extends SurveyException {
  const InvalidEmailFormatException({String? errorCode}) 
      : super('Please provide a valid email address.', errorCode: errorCode);
}

class InvalidPhoneNumberException extends SurveyException {
  const InvalidPhoneNumberException({String? errorCode}) 
      : super('Please provide a valid phone number.', errorCode: errorCode);
}

/// Submission exceptions
class SurveySubmissionException extends SurveyException {
  const SurveySubmissionException({String? errorCode}) 
      : super('Failed to submit survey. Please try again.', errorCode: errorCode);
}

class SurveySaveException extends SurveyException {
  const SurveySaveException({String? errorCode}) 
      : super('Failed to save survey progress. Please try again.', errorCode: errorCode);
}

class DuplicateSurveySubmissionException extends SurveyException {
  const DuplicateSurveySubmissionException({String? errorCode}) 
      : super('Survey has already been submitted. Thank you for your feedback.', errorCode: errorCode);
}

class SurveySubmissionTimeoutException extends SurveyException {
  const SurveySubmissionTimeoutException({String? errorCode}) 
      : super('Survey submission timed out. Please try again.', errorCode: errorCode);
}

/// Feedback specific exceptions
class FeedbackSubmissionException extends SurveyException {
  const FeedbackSubmissionException({String? errorCode}) 
      : super('Failed to submit feedback. Please try again.', errorCode: errorCode);
}

class FeedbackTooShortException extends SurveyException {
  const FeedbackTooShortException({String? errorCode}) 
      : super('Feedback message is too short. Please provide more details.', errorCode: errorCode);
}

class FeedbackTooLongException extends SurveyException {
  const FeedbackTooLongException({String? errorCode}) 
      : super('Feedback message is too long. Please keep it under 1000 characters.', errorCode: errorCode);
}

class InappropriateContentException extends SurveyException {
  const InappropriateContentException({String? errorCode}) 
      : super('Content contains inappropriate language. Please revise your message.', errorCode: errorCode);
}

/// Survey service exceptions
class SurveyServiceUnavailableException extends SurveyException {
  const SurveyServiceUnavailableException({String? errorCode}) 
      : super('Survey service is currently unavailable. Please try again later.', errorCode: errorCode);
}

class SurveyAPIException extends SurveyException {
  const SurveyAPIException({String? errorCode}) 
      : super('Survey service error occurred. Please try again.', errorCode: errorCode);
}

class SurveyRateLimitException extends SurveyException {
  const SurveyRateLimitException({String? errorCode}) 
      : super('Too many survey submissions. Please try again later.', errorCode: errorCode);
}

/// Survey session exceptions
class SurveySessionExpiredException extends SurveyException {
  const SurveySessionExpiredException({String? errorCode}) 
      : super('Survey session has expired. Please restart the survey.', errorCode: errorCode);
}

class SurveyStateException extends SurveyException {
  const SurveyStateException({String? errorCode}) 
      : super('Survey state error occurred. Please restart the survey.', errorCode: errorCode);
}

class SurveyInitializationException extends SurveyException {
  const SurveyInitializationException({String? errorCode}) 
      : super('Failed to initialize survey. Please try again.', errorCode: errorCode);
}

/// User eligibility exceptions
class SurveyNotAvailableException extends SurveyException {
  const SurveyNotAvailableException({String? errorCode}) 
      : super('Survey is not available at this time.', errorCode: errorCode);
}

class SurveyExpiredException extends SurveyException {
  const SurveyExpiredException({String? errorCode}) 
      : super('This survey has expired and is no longer available.', errorCode: errorCode);
}

class UserNotEligibleException extends SurveyException {
  const UserNotEligibleException({String? errorCode}) 
      : super('You are not eligible for this survey.', errorCode: errorCode);
}

/// Network related survey exceptions
class SurveyNetworkException extends SurveyException {
  const SurveyNetworkException({String? errorCode}) 
      : super('Network error during survey operation. Please check your connection.', errorCode: errorCode);
}

/// Generic survey exception
class GenericSurveyException extends SurveyException {
  const GenericSurveyException([String? customMessage, String? errorCode]) 
      : super(customMessage ?? 'A survey error occurred. Please try again.', errorCode: errorCode);
}

/// Survey analytics exceptions
class SurveyAnalyticsException extends SurveyException {
  const SurveyAnalyticsException({String? errorCode}) 
      : super('Failed to record survey analytics. Continuing with survey.', errorCode: errorCode);
}

/// Survey notification exceptions
class SurveyNotificationException extends SurveyException {
  const SurveyNotificationException({String? errorCode}) 
      : super('Failed to send survey notification. Please check your settings.', errorCode: errorCode);
}