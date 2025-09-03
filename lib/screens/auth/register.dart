import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_google_auth_demo/services/auth_service.dart';
import '../main_page.dart';
class RegisterPage extends StatefulWidget {
  final VoidCallback onLoginTap;
  const RegisterPage({super.key, required this.onLoginTap});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>{
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
  String? errorMessage;

  Future<void> register() async{
    try{
      authService.register(emailController.text.trim(), passwordController.text.trim());
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } on FirebaseAuthException catch(e){
      setState( (){
        errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:  Column(
          children: [
            TextField(
              controller:emailController,
              decoration: const InputDecoration(labelText: 'Email')),
            TextField(
              controller:passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (errorMessage != null)
              Text(errorMessage!,style:const TextStyle(color:Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: register,
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: widget.onLoginTap,
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}