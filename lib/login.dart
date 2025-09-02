import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_page.dart';
class LoginPage extends StatefulWidget{
  final VoidCallback onRegisterTap;
   const LoginPage({super.key,required this.onRegisterTap});

   @override
   State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage>{
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;

  Future<void> login() async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(), 
        password: passwordController.text.trim()
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } on FirebaseAuthException catch(e){
      setState((){
        errorMessage = e.message;
      });
    }
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:const Text("Login")),
      body:Padding(
        padding: const EdgeInsets.all(16),
        child : Column(
          children :[
            TextField(
              controller : emailController,
              decoration:const InputDecoration(labelText:"Email"),
              textCapitalization: TextCapitalization.none,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              autofocus: true,
            ),
            TextField(  
              controller: passwordController,
              decoration: const InputDecoration(labelText:"Password"),
              obscureText: true,
            ),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height:20),
            ElevatedButton(onPressed: login, child: const Text('Login')),
            TextButton(
                onPressed: widget.onRegisterTap,
                child: const Text('Don\'t have an account? Register'),
              ),
             ],
        )


      )
    );
  }
}