import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});
 
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Already register,Please log in.'));
        }
        final user = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Main Page'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          body: Center(
            child: Text('Welcome, ${user.email ?? "User"}!'),
          ),
        );
      },
    );
  }
}