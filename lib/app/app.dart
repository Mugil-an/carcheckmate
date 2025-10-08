// lib/app/app.dart
import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CarCheckMate",
      theme: appTheme,
      initialRoute: '/home',
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
