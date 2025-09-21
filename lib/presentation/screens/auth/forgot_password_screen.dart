import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailCtrl = TextEditingController();

  ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: "Enter your email")),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context
                    .read<AuthBloc>()
                    .add(AuthForgotPassword(emailCtrl.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Password reset email sent")),
                );
              },
              child: Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
