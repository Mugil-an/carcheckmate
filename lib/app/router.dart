// lib/app/router.dart
import 'package:flutter/material.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/email_verification_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/checklist/checklist_screen.dart';
import '../presentation/screens/car_selection/car_selection_screen.dart';
import '../presentation/screens/ocr/ocr_screen.dart';
import '../presentation/screens/rto_lien_verification_screen.dart';
import '../presentation/screens/fraud_awareness_screen.dart';
import '../presentation/screens/survey_feedback_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) =>  LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case '/verify':
        return MaterialPageRoute(builder: (_) => const EmailVerificationScreen());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) =>  ForgotPasswordScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/checklist':
        if (settings.arguments is Map<String, dynamic>) {
          final car = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(builder: (_) => ChecklistScreen(selectedCar: car));
        }
        // allow opening checklist without pre-selected car
        return MaterialPageRoute(builder: (_) => const ChecklistScreen());
      case '/car_selection':
        return MaterialPageRoute(builder: (_) => const CarSelectionScreen());
      case '/ocr':
        return MaterialPageRoute(builder: (_) => const OCRScreen());
      case '/rto':
        return MaterialPageRoute(builder: (_) => const RtoLienVerificationScreen());
      case '/fraud-awareness':
        return MaterialPageRoute(builder: (_) => const FraudAwarenessScreen());
      case '/survey':
        return MaterialPageRoute(builder: (_) => const SurveyFeedbackScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
