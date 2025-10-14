import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';
import '../../widgets/common_background.dart';
import '../../../core/utils/exception_handler.dart';
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
            ExceptionHandler.handleError(
              context,
              state.message,
              title: 'Registration Error',
            );
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
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
          if (passCtrl.text.length < 6) {
            ExceptionHandler.handleError(
              context,
              'Password must be at least 6 characters long',
              title: 'Validation Error',
            );
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


}