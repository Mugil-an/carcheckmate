// lib/core/utils/exception_handler.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/theme.dart';
import 'enhanced_exception_handler.dart';

class ExceptionHandler {
  // Show error dialog with custom styling
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.error.withOpacity(0.3), width: 1),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
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
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            if (actionText != null && onAction != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(actionText),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                backgroundColor: AppColors.accent.withOpacity(0.1),
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

  // Show success dialog
  static Future<void> showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.success.withOpacity(0.3), width: 1),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
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
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            if (actionText != null && onAction != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(actionText),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                backgroundColor: AppColors.success.withOpacity(0.1),
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

  // Show warning dialog
  static Future<void> showWarningDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.warning.withOpacity(0.3), width: 1),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: AppColors.warning,
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
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            if (actionText != null && onAction != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(actionText),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                backgroundColor: AppColors.warning.withOpacity(0.1),
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

  // Parse Firebase Auth exceptions to user-friendly messages
  static String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak. Please use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Please try signing in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email. Please check your email or register.';
      case 'wrong-password':
        return 'Incorrect password. Please check your password and try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'requires-recent-login':
        return 'Please log out and log in again to perform this action.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      default:
        return e.message ?? 'An authentication error occurred. Please try again.';
    }
  }

  // Parse general exceptions to user-friendly messages
  static String getGeneralErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return getAuthErrorMessage(error);
    }
    
    String errorMessage = error.toString().toLowerCase();
    
    if (errorMessage.contains('network') || errorMessage.contains('connection')) {
      return 'Network connection error. Please check your internet and try again.';
    } else if (errorMessage.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorMessage.contains('permission')) {
      return 'Permission denied. Please check your access rights.';
    } else if (errorMessage.contains('not found') || errorMessage.contains('404')) {
      return 'The requested resource was not found.';
    } else if (errorMessage.contains('server') || errorMessage.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (errorMessage.contains('invalid')) {
      return 'Invalid data provided. Please check your input.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Handle and show error dialog automatically
  static Future<void> handleError(
    BuildContext context,
    dynamic error, {
    String? title,
    String? customMessage,
    String? actionText,
    VoidCallback? onAction,
  }) async {
    // Use enhanced exception handler for Exception objects
    if (error is Exception) {
      await EnhancedExceptionHandler.handleException(
        context,
        error,
        customTitle: title,
        customMessage: customMessage,
        actionText: actionText,
        onAction: onAction,
      );
      return;
    }

    // Handle Firebase Auth exceptions specifically
    if (error is FirebaseAuthException) {
      await EnhancedExceptionHandler.handleAuthException(
        context,
        error,
        customTitle: title,
        onRetry: onAction,
      );
      return;
    }

    // Fallback for non-Exception errors
    String errorMessage = customMessage ?? getGeneralErrorMessage(error);
    String errorTitle = title ?? 'Error';
    
    // Log error for debugging
    debugPrint('Error handled: $error');
    
    await showErrorDialog(
      context,
      title: errorTitle,
      message: errorMessage,
      actionText: actionText,
      onAction: onAction,
    );
  }

  // Handle and show success dialog automatically
  static Future<void> handleSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) async {
    await showSuccessDialog(
      context,
      title: title,
      message: message,
      actionText: actionText,
      onAction: onAction,
    );
  }

  // Handle and show warning dialog automatically
  static Future<void> handleWarning(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) async {
    await showWarningDialog(
      context,
      title: title,
      message: message,
      actionText: actionText,
      onAction: onAction,
    );
  }
}