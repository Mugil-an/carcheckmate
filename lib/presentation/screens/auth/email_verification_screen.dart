import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Use post-frame callback to avoid navigation conflicts
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, "/home");
              }
            });
          } else if (state is AuthError) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade200, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
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
                  Text(
                    'A verification email has been sent to your email address. Please verify your email to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 30),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
                      }
                      return _buildCheckVerifiedButton(context);
                    },
                  ),
                  SizedBox(height: 20),
                  _buildResendButton(context),
                  SizedBox(height: 20),
                  _buildBackButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckVerifiedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<AuthBloc>().add(AuthCheckVerified());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(
          "I have verified my email",
          style: TextStyle(fontSize: 18, color: Colors.blue.shade800),
        ),
      ),
    );
  }

  Widget _buildResendButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.read<AuthBloc>().add(AuthSendVerification());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification email sent again.")),
        );
      },
      child: Text(
        "Resend verification email",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        try {
          // Let AuthGuard handle navigation after logout
          context.read<AuthBloc>().add(AuthLogout());
        } catch (e) {
          // Fallback navigation if bloc is not available
          Navigator.pushReplacementNamed(context, "/login");
        }
      },
      child: Text(
        "Back to Login",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}