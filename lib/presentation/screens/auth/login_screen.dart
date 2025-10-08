import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';
import '../../widgets/common_background.dart';
import '../../../app/theme.dart';

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
              _showErrorDialog(context, state.message);
            } else if (state is Authenticated) {
              Navigator.pushReplacementNamed(context, "/home");
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
          if (emailCtrl.text.trim().isEmpty) {
            _showErrorDialog(context, 'Please enter your email address');
            return;
          }
          if (passCtrl.text.isEmpty) {
            _showErrorDialog(context, 'Please enter your password');
            return;
          }
          if (!_isValidEmail(emailCtrl.text.trim())) {
            _showErrorDialog(context, 'Please enter a valid email address');
            return;
          }
          
          context.read<AuthBloc>().add(AuthLogin(emailCtrl.text.trim(), passCtrl.text));
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

  void _showErrorDialog(BuildContext context, dynamic error) {
    String message;
    if (error is PlatformException) {
      message = _handlePlatformException(error);
    } else {
      message = error.toString();
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.borderColor.withOpacity(0.3)),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Login Error',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            _getUserFriendlyMessage(message),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'ERROR_INVALID_CREDENTIAL':
        return 'The login credentials are incorrect, malformed, or have expired. Please check your email and password and try again.';
      case 'ERROR_USER_NOT_FOUND':
        return 'No account found with this email address. Please check your email or sign up for a new account.';
      case 'ERROR_WRONG_PASSWORD':
        return 'The password is incorrect. Please check your password and try again.';
      case 'ERROR_USER_DISABLED':
        return 'This account has been disabled. Please contact support for assistance.';
      case 'ERROR_TOO_MANY_REQUESTS':
        return 'Too many failed login attempts. Please wait a moment before trying again.';
      case 'ERROR_OPERATION_NOT_ALLOWED':
        return 'Email/password sign in is not enabled. Please contact support.';
      case 'ERROR_INVALID_EMAIL':
        return 'The email address is not valid. Please enter a valid email address.';
      case 'ERROR_NETWORK_REQUEST_FAILED':
        return 'Network error. Please check your internet connection and try again.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  String _getUserFriendlyMessage(String errorMessage) {
    final lowercaseMessage = errorMessage.toLowerCase();
    
    if (lowercaseMessage.contains('user-not-found') || 
        lowercaseMessage.contains('user not found')) {
      return 'No account found with this email address. Please check your email or sign up for a new account.';
    } else if (lowercaseMessage.contains('wrong-password') || 
               lowercaseMessage.contains('invalid-credential') ||
               lowercaseMessage.contains('error_invalid_credential') ||
               lowercaseMessage.contains('incorrect password') ||
               lowercaseMessage.contains('malformed or has expired')) {
      return 'The login credentials are incorrect or have expired. Please check your email and password, or try signing in again.';
    } else if (lowercaseMessage.contains('invalid-email')) {
      return 'The email address is not valid. Please enter a valid email address.';
    } else if (lowercaseMessage.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support for assistance.';
    } else if (lowercaseMessage.contains('too-many-requests')) {
      return 'Too many failed login attempts. Please wait a moment before trying again.';
    } else if (lowercaseMessage.contains('network')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (lowercaseMessage.contains('timeout')) {
      return 'Request timed out. Please check your internet connection and try again.';
    } else if (lowercaseMessage.contains('platformexception')) {
      return 'Authentication failed. Please check your credentials and try again.';
    } else {
      return errorMessage.isNotEmpty ? errorMessage : 'An unexpected error occurred. Please try again.';
    }
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