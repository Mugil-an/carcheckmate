import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';
import '../../widgets/common_background.dart';
import '../../../app/theme.dart';
import '../../../utilities/dialogs/error_dialog.dart';

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
          listener: (context, state) async {
            if (state is AuthError) {
              // Handle specific error messages like mynotes pattern
              String errorMessage = state.message.toLowerCase();
              if (errorMessage.contains('no account found') || 
                  errorMessage.contains('user not found') ||
                  errorMessage == 'user not found') {
                if (context.mounted) {
                  await showErrorDialog(context, 'User not Found');
                }
              } else if (errorMessage.contains('incorrect password') || 
                         errorMessage.contains('wrong password') ||
                         errorMessage.contains('invalid email or password') ||
                         errorMessage.contains('invalid credentials') ||
                         errorMessage.contains('credential is incorrect')) {
                if (context.mounted) {
                  await showErrorDialog(context, 'Wrong Password');
                }
              } else {
                if (context.mounted) {
                  await showErrorDialog(context, 'Authentication Error');
                }
              }
            } else if (state is Authenticated) {
              // Use post-frame callback to avoid navigation conflicts
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  final user = state.user;
                  if (user.emailVerified) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil('/verify-email', (route) => false);
                  }
                }
              });
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                      MediaQuery.of(context).padding.top - 
                      MediaQuery.of(context).padding.bottom - 48,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    const SizedBox(height: 60),
                    Image.asset(
                      'assets/images/carcheckmate_logo.png',
                      height: 200,
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
        onPressed: () async {
          final email = emailCtrl.text.trim();
          final password = passCtrl.text;
          try {
            // Use the existing BLoC but handle exceptions at UI level
            context.read<AuthBloc>().add(AuthLogin(email, password));
          } catch (e) {
            // This won't catch BLoC exceptions, but we'll handle them in the listener
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