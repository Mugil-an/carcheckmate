import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, "/home");
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
                TextField(controller: passCtrl, decoration: InputDecoration(labelText: "Password"), obscureText: true),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthSignIn(emailCtrl.text, passCtrl.text));
                  },
                  child: Text("Login"),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, "/register"),
                  child: Text("Register"),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, "/forgot"),
                  child: Text("Forgot Password?"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
