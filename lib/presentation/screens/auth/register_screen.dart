import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';
import '../../widgets/common_background.dart';
import '../../../app/theme.dart';
import '../../../utilities/dialogs/error_dialog.dart';

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
        listener: (context, state) async {
          if (state is AuthError) {
            // Handle specific error messages like mynotes pattern
            String errorMessage = state.message.toLowerCase();
            if (errorMessage.contains('password is too weak') || 
                errorMessage.contains('weak password')) {
              await showErrorDialog(context, 'Password is Weak');
            } else if (errorMessage.contains('email already exists') || 
                       errorMessage.contains('account with this email already exists')) {
              await showErrorDialog(context, 'Email is already taken, use another email or login instead');
            } else if (errorMessage.contains('please enter a valid email') || 
                       errorMessage.contains('invalid email')) {
              await showErrorDialog(context, 'Enter valid Email');
            } else {
              await showErrorDialog(context, 'Authentication Error');
            }
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
                      height: 200,
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
          final email = emailCtrl.text.trim();
          final password = passCtrl.text;
          context.read<AuthBloc>().add(AuthRegister(email, password));
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

}