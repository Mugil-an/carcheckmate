import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';
import '../../widgets/common_background.dart';
import '../../../app/theme.dart';
import '../../../core/utils/exception_handler.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              String errorTitle = 'Sign-in Error';
              String? actionText;
              VoidCallback? onAction;
              
              // Provide specific guidance based on error type
              String errorMessage = state.message.toLowerCase();
              if (errorMessage.contains('user-not-found') || errorMessage.contains('user not found')) {
                errorTitle = 'Account Not Found';
                actionText = 'Create Account';
                onAction = () {
                  Navigator.pushNamed(context, '/register');
                };
              } else if (errorMessage.contains('wrong-password') || errorMessage.contains('invalid-credential')) {
                errorTitle = 'Invalid Credentials';
                actionText = 'Reset Password';
                onAction = () {
                  Navigator.pushNamed(context, '/forgot-password');
                };
              } else if (errorMessage.contains('too-many-requests')) {
                errorTitle = 'Too Many Attempts';
                actionText = 'Try Later';
              } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
                errorTitle = 'Connection Error';
                actionText = 'Retry';
                onAction = () {
                  // User can try signing in again
                };
              }
              
              ExceptionHandler.handleError(
                context,
                state.message,
                title: errorTitle,
                actionText: actionText,
                onAction: onAction,
              );
            } else if (state is Authenticated) {
              try {
                Navigator.pushReplacementNamed(context, "/home");
              } catch (e) {
                // Use simple error dialog to prevent any crashes
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Navigation Error'),
                      content: const Text('Successfully signed in, but failed to navigate to home screen. Please tap OK to continue.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                });
              }
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Image.asset(
                      'assets/images/carcheckmate_logo.png',
                      height: 120,
                      semanticLabel: 'CarCheckMate Logo',
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sign in to continue your vehicle inspection',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(emailCtrl, "Email", false),
                    const SizedBox(height: 20),
                    _buildTextField(passCtrl, "Password", true),
                    const SizedBox(height: 10),
                    _buildForgotPasswordButton(context),
                    const SizedBox(height: 30),
                    if (state is AuthLoading)
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    else
                      _buildLoginButton(context),
                    const SizedBox(height: 20),
                    _buildRegisterButton(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool obscureText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, "/forgot-password");
        },
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // Validate inputs
          if (emailCtrl.text.isEmpty) {
            ExceptionHandler.handleError(
              context,
              'Please enter your email address',
              title: 'Validation Error',
            );
            return;
          }
          if (passCtrl.text.isEmpty) {
            ExceptionHandler.handleError(
              context,
              'Please enter your password',
              title: 'Validation Error',
            );
            return;
          }
          if (!_isValidEmail(emailCtrl.text)) {
            ExceptionHandler.handleError(
              context,
              'Please enter a valid email address',
              title: 'Validation Error',
            );
            return;
          }
          
          try {
            // Show loading state
            debugPrint('Attempting to sign in with email: ${emailCtrl.text.trim()}');
            context.read<AuthBloc>().add(AuthLogin(emailCtrl.text.trim(), passCtrl.text));
          } catch (e) {
            ExceptionHandler.handleError(
              context,
              e,
              title: 'Sign-in Error',
              customMessage: 'Failed to initiate sign-in process. Please check your connection and try again.',
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Login",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }



  Widget _buildRegisterButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, "/register");
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}