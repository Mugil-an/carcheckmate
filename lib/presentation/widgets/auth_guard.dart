// lib/presentation/widgets/auth_guard.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';
import '../../app/theme.dart';
import '../../utilities/dialogs/error_dialog.dart';
import 'common_background.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  
  const AuthGuard({
    super.key,
    required this.child,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _hasCheckedAuth = false;

  @override
  void initState() {
    super.initState();
    // Check authentication status when guard is initialized
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    if (!_hasCheckedAuth && mounted) {
      try {
        context.read<AuthBloc>().add(AuthCheckCurrent());
        _hasCheckedAuth = true;
      } catch (e) {
        // Handle case where bloc might not be available
        debugPrint('Error checking auth status: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle navigation on state changes
        if (state is AuthError) {
          // Show error dialog for authentication errors
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              if (mounted && context.mounted) {
                await showErrorDialog(context, state.message);
                if (mounted && context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              }
            } catch (e) {
              debugPrint('Error showing auth error dialog: $e');
              // Fallback navigation without dialog
              if (mounted && context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            }
          });
        } else if (state is Unauthenticated) {
          // User is not authenticated, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              if (mounted && context.mounted) {
                if (Navigator.canPop(context)) {
                  Navigator.pushReplacementNamed(context, '/login');
                } else {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              }
            } catch (e) {
              debugPrint('Error during navigation: $e');
            }
          });
        }
      },
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          // Show loading while checking authentication
          return AppBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentLightest),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Checking authentication...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        if (state is Authenticated) {
          // User is authenticated, show the protected content
          return widget.child;
        }
        
        // Show loading state while redirecting
        return AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentLightest),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Redirecting to login...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}