import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Auth App",
      theme: appTheme,// from theme.dart
      initialRoute: '/login',
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false, 
    );
  }
}