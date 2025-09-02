import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLogin = true;

  void togglePage() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLogin
        ? LoginPage(onRegisterTap: togglePage)
        : RegisterPage(onLoginTap: togglePage);
  }
}