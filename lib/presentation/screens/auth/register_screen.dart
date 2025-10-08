import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';
import '../../widgets/common_background.dart';
import '../../../app/theme.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  RegisterScreen({super.key});

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
            Navigator.pushReplacementNamed(context, "/verify");
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/carcheckmate_logo.png',
                      height: 150,
                      semanticLabel: 'CarCheckMate Logo',
                    ),
                    SizedBox(height: 40),
                    _buildTextField(emailCtrl, "Email", false),
                    SizedBox(height: 20),
                    _buildTextField(passCtrl, "Password", true),
                    SizedBox(height: 30),
                    if (state is AuthLoading)
                      CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    else
                      _buildRegisterButton(context),
                    SizedBox(height: 20),
                    _buildLoginButton(context),
                  ],
                ),
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

  Widget _buildRegisterButton(BuildContext context) {
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
          if (passCtrl.text.length < 6) {
            _showErrorDialog(context, 'Password must be at least 6 characters long');
            return;
          }
          
          context.read<AuthBloc>().add(AuthRegister(emailCtrl.text.trim(), passCtrl.text));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Create Account",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/login");
          },
          child: const Text(
            "Sign In",
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
                'Registration Error',
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
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        return 'An account with this email address already exists. Please sign in or use a different email address.';
      case 'ERROR_INVALID_EMAIL':
        return 'The email address is not valid. Please enter a valid email address.';
      case 'ERROR_WEAK_PASSWORD':
        return 'The password is too weak. Please choose a stronger password with at least 6 characters.';
      case 'ERROR_OPERATION_NOT_ALLOWED':
        return 'Email/password registration is not enabled. Please contact support.';
      case 'ERROR_INVALID_CREDENTIAL':
        return 'The registration credentials are invalid or malformed. Please check your information and try again.';
      case 'ERROR_NETWORK_REQUEST_FAILED':
        return 'Network error. Please check your internet connection and try again.';
      default:
        return e.message ?? 'Registration failed. Please try again.';
    }
  }

  String _getUserFriendlyMessage(String errorMessage) {
    final lowercaseMessage = errorMessage.toLowerCase();
    
    if (lowercaseMessage.contains('email-already-in-use') || 
        lowercaseMessage.contains('already exists')) {
      return 'An account with this email address already exists. Please sign in or use a different email address.';
    } else if (lowercaseMessage.contains('weak-password')) {
      return 'The password is too weak. Please choose a stronger password with at least 6 characters.';
    } else if (lowercaseMessage.contains('invalid-email')) {
      return 'The email address is not valid. Please enter a valid email address.';
    } else if (lowercaseMessage.contains('operation-not-allowed')) {
      return 'Email/password registration is not enabled. Please contact support.';
    } else if (lowercaseMessage.contains('invalid-credential') ||
               lowercaseMessage.contains('error_invalid_credential') ||
               lowercaseMessage.contains('malformed or has expired')) {
      return 'The registration credentials are invalid or malformed. Please check your information and try again.';
    } else if (lowercaseMessage.contains('network')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (lowercaseMessage.contains('timeout')) {
      return 'Request timed out. Please check your internet connection and try again.';
    } else if (lowercaseMessage.contains('platformexception')) {
      return 'Registration failed. Please check your information and try again.';
    } else {
      return errorMessage.isNotEmpty ? errorMessage : 'An unexpected error occurred. Please try again.';
    }
  }
}