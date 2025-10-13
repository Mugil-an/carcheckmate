import 'package:flutter/material.dart';
import '../dialogs/generic_dialog.dart';

class ErrorDialogHelper {
  /// Show error dialog similar to mynotes pattern
  static Future<void> showErrorDialog(
    BuildContext context,
    String text, {
    String title = 'An error occurred',
  }) {
    return showGenericDialog<void>(
      context: context,
      title: title,
      content: text,
      optionsBuilder: () => {
        'OK': null,
      },
    );
  }

  /// Show error with retry option
  static Future<bool> showErrorDialogWithRetry(
    BuildContext context,
    String text, {
    String title = 'An error occurred',
    String retryText = 'Retry',
  }) {
    return showGenericDialog<bool>(
      context: context,
      title: title,
      content: text,
      optionsBuilder: () => {
        'Cancel': false,
        retryText: true,
      },
    ).then((value) => value ?? false);
  }

  /// Convert exception to user-friendly message
  static String getErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';
    
    final String errorString = error.toString().toLowerCase();
    
    // Network errors
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network connection error. Please check your internet connection and try again.';
    }
    
    // Timeout errors
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    // Authentication errors
    if (errorString.contains('user-not-found') || errorString.contains('user not found')) {
      return 'No account found with this email address.';
    }
    
    if (errorString.contains('wrong-password') || errorString.contains('incorrect password')) {
      return 'Incorrect password. Please try again.';
    }
    
    if (errorString.contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    }
    
    if (errorString.contains('weak-password')) {
      return 'Password is too weak. Please use at least 6 characters.';
    }
    
    if (errorString.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    
    // Vehicle verification errors
    if (errorString.contains('vehicle not found') || errorString.contains('registration number not found')) {
      return 'Vehicle registration number not found in database.';
    }
    
    if (errorString.contains('invalid vehicle number') || errorString.contains('invalid registration')) {
      return 'Please enter a valid vehicle registration number.';
    }
    
    if (errorString.contains('rate limit')) {
      return 'Too many requests. Please wait a moment and try again.';
    }
    
    // Generic fallback
    return error.toString();
  }
}