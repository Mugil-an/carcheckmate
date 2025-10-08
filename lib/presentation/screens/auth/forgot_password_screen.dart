import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';
import '../../widgets/common_background.dart';
import '../../../app/theme.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailCtrl = TextEditingController();

  ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            _showErrorDialog(context, state.message);
          } else if (state is AuthForgotPasswordSuccess) {
            _showSuccessDialog(context);
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/carcheckmate_logo.png',
                    height: 120,
                    semanticLabel: 'CarCheckMate Logo',
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter your email address and we\'ll send you a password reset link',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(emailCtrl, "Email"),
                  SizedBox(height: 30),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
                      }
                      return _buildResetButton(context);
                    },
                  ),
                  SizedBox(height: 20),
                  _buildBackButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
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

  Widget _buildResetButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // Validate input
          if (emailCtrl.text.trim().isEmpty) {
            _showErrorDialog(context, 'Please enter your email address');
            return;
          }
          if (!_isValidEmail(emailCtrl.text.trim())) {
            _showErrorDialog(context, 'Please enter a valid email address');
            return;
          }
          
          context.read<AuthBloc>().add(AuthForgotPassword(emailCtrl.text.trim()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Send Reset Link",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text(
        "Back to Login",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
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
                'Error',
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

  void _showSuccessDialog(BuildContext context) {
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
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Email Sent',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'A password reset link has been sent to your email address. Please check your inbox and follow the instructions.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'ERROR_USER_NOT_FOUND':
        return 'No account found with this email address. Please check your email or create a new account.';
      case 'ERROR_INVALID_EMAIL':
        return 'The email address is not valid. Please enter a valid email address.';
      case 'ERROR_TOO_MANY_REQUESTS':
        return 'Too many password reset requests. Please wait a moment before trying again.';
      case 'ERROR_INVALID_CREDENTIAL':
        return 'Unable to process password reset request. Please check your email address and try again.';
      case 'ERROR_NETWORK_REQUEST_FAILED':
        return 'Network error. Please check your internet connection and try again.';
      default:
        return e.message ?? 'Password reset failed. Please try again.';
    }
  }

  String _getUserFriendlyMessage(String errorMessage) {
    final lowercaseMessage = errorMessage.toLowerCase();
    
    if (lowercaseMessage.contains('user-not-found') || 
        lowercaseMessage.contains('user not found')) {
      return 'No account found with this email address. Please check your email or create a new account.';
    } else if (lowercaseMessage.contains('invalid-email')) {
      return 'The email address is not valid. Please enter a valid email address.';
    } else if (lowercaseMessage.contains('too-many-requests')) {
      return 'Too many password reset requests. Please wait a moment before trying again.';
    } else if (lowercaseMessage.contains('invalid-credential') ||
               lowercaseMessage.contains('error_invalid_credential') ||
               lowercaseMessage.contains('malformed or has expired')) {
      return 'Unable to process password reset request. Please check your email address and try again.';
    } else if (lowercaseMessage.contains('network')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (lowercaseMessage.contains('timeout')) {
      return 'Request timed out. Please check your internet connection and try again.';
    } else if (lowercaseMessage.contains('platformexception')) {
      return 'Password reset failed. Please check your email address and try again.';
    } else {
      return errorMessage.isNotEmpty ? errorMessage : 'An unexpected error occurred. Please try again.';
    }
  }
}