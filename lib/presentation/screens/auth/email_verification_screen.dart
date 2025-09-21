import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Email")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Please verify your email to continue."),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthSendVerification());
              },
              child: Text("Resend Verification"),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, "/login"),
              child: Text("Back to Login"),
            ),
          ],
        ),
      ),
    );
  }
}
