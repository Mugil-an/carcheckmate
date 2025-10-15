// lib/presentation/utils/auth_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../utilities/dialogs/generic_dialog.dart';

class AuthUtils {
  /// Navigate to a route with authentication check
  static Future<void> navigateWithAuthCheck(
    BuildContext context, 
    String routeName, {
    Object? arguments,
  }) async {
    try {
      final authState = context.read<AuthBloc>().state;
      
      if (authState is Authenticated) {
        Navigator.pushNamed(context, routeName, arguments: arguments);
      } else {
        // Show login dialog or redirect to login
        await _showLoginDialog(context, routeName, arguments);
      }
    } catch (e) {
      // Fallback if bloc is not available
      Navigator.pushNamed(context, '/login');
    }
  }

  /// Replace current route with authentication check
  static void navigateAndReplaceWithAuthCheck(
    BuildContext context, 
    String routeName, {
    Object? arguments,
  }) {
    try {
      final authState = context.read<AuthBloc>().state;
      
      if (authState is Authenticated) {
        Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // Fallback if bloc is not available
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// Check if user is authenticated
  static bool isAuthenticated(BuildContext context) {
    try {
      final authState = context.read<AuthBloc>().state;
      return authState is Authenticated;
    } catch (e) {
      // Return false if bloc is not available
      return false;
    }
  }

  /// Show login dialog when user tries to access protected content
  static Future<void> _showLoginDialog(
    BuildContext context, 
    String intendedRoute, 
    Object? arguments,
  ) async {
    final result = await showGenericDialog<bool>(
      context: context,
      title: 'Login Required',
      content: 'You need to login to access this feature. Would you like to login now?',
      optionsBuilder: () => {
        'Cancel': false,
        'Login': true,
      },
    );
    
    if (result == true && context.mounted) {
      Navigator.pushNamed(context, '/login').then((_) {
        if (!context.mounted) return;
        if (isAuthenticated(context)) {
          Navigator.pushNamed(context, intendedRoute, arguments: arguments);
        }
      });
    }
  }
}