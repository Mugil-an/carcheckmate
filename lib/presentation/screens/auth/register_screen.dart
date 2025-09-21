import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, "/verify");
          }
        },
        builder: (context, state) {
          if (state is AuthLoading)
            return Center(child: CircularProgressIndicator());
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(labelText: "Email")),
                TextField(
                    controller: passCtrl,
                    decoration: InputDecoration(labelText: "Password"),
                    obscureText: true),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<AuthBloc>()
                        .add(AuthRegister(emailCtrl.text, passCtrl.text));
                  },
                  child: Text("Register"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
