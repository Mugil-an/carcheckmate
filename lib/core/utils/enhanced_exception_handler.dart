// lib/core/utils/enhanced_exception_handler.dart
// Enhanced exception handler that uses module-specific exceptions
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../exceptions/app_exceptions.dart';
import '../exceptions/auth_exceptions.dart' as auth;
import '../exceptions/checklist_exceptions.dart';
import '../exceptions/rto_exceptions.dart';
import '../exceptions/ocr_exceptions.dart';
import '../exceptions/survey_exceptions.dart';
import '../exceptions/fraud_awareness_exceptions.dart';
import '../exceptions/network_exceptions.dart' as network;
import '../../app/theme.dart';

class EnhancedExceptionHandler {
  /// Show error dialog with module-specific styling
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
    String? moduleName,
    bool isRecoverable = true,
  }) async {
    Color moduleColor = _getModuleColor(moduleName);
    IconData moduleIcon = _getModuleIcon(moduleName);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: moduleColor.withOpacity(0.3), width: 1),
          ),
          title: Row(
            children: [
              Icon(
                moduleIcon,
                color: moduleColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (moduleName != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: moduleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      moduleName,
                      style: TextStyle(
                        color: moduleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  message,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                if (!isRecoverable) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This error may require app restart or update.',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (actionText != null && onAction != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: moduleColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(actionText),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                backgroundColor: moduleColor.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Handle exceptions with module-specific logic
  static Future<void> handleException(
    BuildContext context,
    Exception exception, {
    String? customTitle,
    String? customMessage,
    String? actionText,
    VoidCallback? onAction,
  }) async {
    String moduleName = ExceptionHelper.getModuleFromException(exception);
    String message = customMessage ?? ExceptionHelper.getUserFriendlyMessage(exception);
    String title = customTitle ?? _getDefaultTitle(exception);
    bool isRecoverable = ExceptionHelper.isRecoverable(exception);
    String? suggestedAction = ExceptionHelper.getSuggestedAction(exception);

    // Use suggested action if no custom action provided
    if (actionText == null && onAction == null && suggestedAction != null) {
      actionText = 'Learn More';
      onAction = () => _showSuggestedActionDialog(context, suggestedAction);
    }

    // Log error for debugging with module context
    debugPrint('[$moduleName] Error handled: $exception');

    await showErrorDialog(
      context,
      title: title,
      message: message,
      actionText: actionText,
      onAction: onAction,
      moduleName: moduleName,
      isRecoverable: isRecoverable,
    );
  }

  /// Handle Firebase Auth exceptions specifically
  static Future<void> handleAuthException(
    BuildContext context,
    FirebaseAuthException exception, {
    String? customTitle,
    VoidCallback? onRetry,
  }) async {
    auth.AuthException authException = _convertFirebaseAuthException(exception);
    
    await handleException(
      context,
      authException,
      customTitle: customTitle ?? 'Authentication Error',
      actionText: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }

  /// Convert FirebaseAuthException to custom AuthException
  static auth.AuthException _convertFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return auth.WeakPasswordException(errorCode: e.code);
      case 'email-already-in-use':
        return auth.EmailAlreadyInUseException(errorCode: e.code);
      case 'invalid-email':
        return auth.InvalidEmailException(errorCode: e.code);
      case 'user-disabled':
        return auth.UserDisabledException(errorCode: e.code);
      case 'user-not-found':
        return auth.UserNotFoundException(errorCode: e.code);
      case 'wrong-password':
        return auth.IncorrectPasswordException(errorCode: e.code);
      case 'too-many-requests':
        return auth.TooManyRequestsException(errorCode: e.code);
      case 'network-request-failed':
        return auth.AuthNetworkException(errorCode: e.code);
      case 'requires-recent-login':
        return auth.RequiresRecentLoginException(errorCode: e.code);
      case 'invalid-credential':
        return auth.InvalidCredentialsException(errorCode: e.code);
      default:
        return auth.GenericAuthException(e.message, e.code);
    }
  }

  /// Show suggested action dialog
  static Future<void> _showSuggestedActionDialog(BuildContext context, String action) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Suggested Action',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            action,
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: TextStyle(color: AppColors.accent),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Get module-specific color
  static Color _getModuleColor(String? moduleName) {
    switch (moduleName) {
      case 'Authentication':
        return Colors.blue;
      case 'Checklist':
        return Colors.green;
      case 'RTO Verification':
        return Colors.orange;
      case 'Document Processing':
        return Colors.purple;
      case 'Survey':
        return Colors.teal;
      case 'Fraud Awareness':
        return Colors.red;
      case 'Network':
        return Colors.indigo;
      case 'Application':
        return Colors.grey;
      default:
        return AppColors.error;
    }
  }

  /// Get module-specific icon
  static IconData _getModuleIcon(String? moduleName) {
    switch (moduleName) {
      case 'Authentication':
        return Icons.person_outline;
      case 'Checklist':
        return Icons.checklist;
      case 'RTO Verification':
        return Icons.verified_user;
      case 'Document Processing':
        return Icons.document_scanner;
      case 'Survey':
        return Icons.poll;
      case 'Fraud Awareness':
        return Icons.security;
      case 'Network':
        return Icons.wifi_off;
      case 'Application':
        return Icons.error_outline;
      default:
        return Icons.error_outline;
    }
  }

  /// Get default title for exception type
  static String _getDefaultTitle(Exception exception) {
    if (exception is auth.AuthException) {
      return 'Authentication Error';
    }
    if (exception is ChecklistException) {
      return 'Checklist Error';
    }
    if (exception is RTOException) {
      return 'RTO Verification Error';
    }
    if (exception is OCRException) {
      return 'Document Processing Error';
    }
    if (exception is SurveyException) {
      return 'Survey Error';
    }
    if (exception is FraudAwarenessException) {
      return 'Fraud Awareness Error';
    }
    if (exception is network.NetworkException) {
      return 'Network Error';
    }
    if (exception is AppException) {
      return 'Application Error';
    }
    return 'Error';
  }

  /// Create exception from error type and module
  static Exception createException(String errorType, String module, {String? customMessage}) {
    switch (module.toLowerCase()) {
      case 'auth':
        return _createAuthException(errorType, customMessage);
      case 'checklist':
        return _createChecklistException(errorType, customMessage);
      case 'rto':
        return _createRTOException(errorType, customMessage);
      case 'ocr':
        return _createOCRException(errorType, customMessage);
      case 'survey':
        return _createSurveyException(errorType, customMessage);
      case 'fraud':
        return _createFraudException(errorType, customMessage);
      case 'network':
        return _createNetworkException(errorType, customMessage);
      default:
        return GenericAppException(customMessage);
    }
  }

  static Exception _createAuthException(String errorType, String? customMessage) {
    switch (errorType.toLowerCase()) {
      case 'user_not_found':
        return auth.UserNotFoundException();
      case 'wrong_password':
        return auth.IncorrectPasswordException();
      case 'email_exists':
        return auth.EmailAlreadyInUseException();
      case 'weak_password':
        return auth.WeakPasswordException();
      case 'invalid_email':
        return auth.InvalidEmailException();
      default:
        return auth.GenericAuthException(customMessage);
    }
  }

  static Exception _createChecklistException(String errorType, String? customMessage) {
    switch (errorType.toLowerCase()) {
      case 'data_not_found':
        return ChecklistDataNotFoundException();
      case 'load_failed':
        return ChecklistLoadFailedException();
      case 'car_not_found':
        return CarDataNotFoundException();
      case 'validation_failed':
        return ChecklistValidationFailedException();
      default:
        return GenericChecklistException(customMessage);
    }
  }

  static Exception _createRTOException(String errorType, String? customMessage) {
    switch (errorType.toLowerCase()) {
      case 'invalid_number':
        return InvalidVehicleNumberException();
      case 'not_found':
        return VehicleNumberNotFoundException();
      case 'api_error':
        return RTOAPIException();
      case 'timeout':
        return RTOAPITimeoutException();
      default:
        return GenericRTOException(customMessage);
    }
  }

  static Exception _createOCRException(String errorType, String? customMessage) {
    switch (errorType.toLowerCase()) {
      case 'processing_failed':
        return DocumentProcessingException();
      case 'invalid_format':
        return DocumentFormatException();
      case 'file_too_large':
        return DocumentSizeException();
      case 'poor_quality':
        return DocumentQualityException();
      default:
        return GenericOCRException(customMessage);
    }
  }

  static Exception _createSurveyException(String errorType, String? customMessage) {
    switch (errorType.toLowerCase()) {
      case 'validation_failed':
        return SurveyValidationException();
      case 'submission_failed':
        return SurveySubmissionException();
      case 'not_found':
        return SurveyDataNotFoundException();
      default:
        return GenericSurveyException(customMessage);
    }
  }

  static Exception _createFraudException(String errorType, String? customMessage) {
    switch (errorType.toLowerCase()) {
      case 'content_not_found':
        return FraudContentNotFoundException();
      case 'load_failed':
        return FraudContentLoadFailedException();
      default:
        return GenericFraudAwarenessException(customMessage);
    }
  }

  static Exception _createNetworkException(String errorType, String? customMessage) {
    switch (errorType.toLowerCase()) {
      case 'no_internet':
        return network.NoInternetConnectionException();
      case 'timeout':
        return network.ConnectionTimeoutException();
      case 'server_error':
        return network.InternalServerErrorException();
      case 'not_found':
        return network.NotFoundException();
      default:
        return network.GenericNetworkException(customMessage);
    }
  }
}