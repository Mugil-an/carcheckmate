// lib/presentation/utils/auth_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';

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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A4174),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Login Required',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'You need to login to access this feature. Would you like to login now?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login').then((_) {
                // After login, check if user is authenticated and navigate to intended route
                if (isAuthenticated(context)) {
                  Navigator.pushNamed(context, intendedRoute, arguments: arguments);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7BBDE8),
              foregroundColor: Colors.white,
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}