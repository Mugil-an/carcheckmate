// lib/presentation/utils/auth_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../core/utils/exception_handler.dart';

class AuthUtils {
  /// Navigate to a route with authentication check
  static void navigateWithAuthCheck(
    BuildContext context, 
    String routeName, {
    Object? arguments,
  }) {
    final authState = context.read<AuthBloc>().state;
    
    if (authState is Authenticated) {
      Navigator.pushNamed(context, routeName, arguments: arguments);
    } else {
      // Show login dialog or redirect to login
      _showLoginDialog(context, routeName, arguments);
    }
  }

  /// Replace current route with authentication check
  static void navigateAndReplaceWithAuthCheck(
    BuildContext context, 
    String routeName, {
    Object? arguments,
  }) {
    final authState = context.read<AuthBloc>().state;
    
    if (authState is Authenticated) {
      Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// Check if user is authenticated
  static bool isAuthenticated(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is Authenticated;
  }

  /// Show login dialog when user tries to access protected content
  static void _showLoginDialog(
    BuildContext context, 
    String intendedRoute, 
    Object? arguments,
  ) {
    ExceptionHandler.showWarningDialog(
      context,
      title: 'Login Required',
      message: 'You need to login to access this feature. Would you like to login now?',
      actionText: 'Login',
      onAction: () {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushNamed(context, '/login').then((_) {
          if (!context.mounted) return;
          if (isAuthenticated(context)) {
            Navigator.pushNamed(context, intendedRoute, arguments: arguments);
          }
        });
      },
    );
  }
}