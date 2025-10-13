// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'dart:ui';

import 'core/di/service_locator.dart' as di;
import 'core/error/failures.dart';
import 'app/app.dart';
import 'logic/auth/auth_bloc.dart';
import 'logic/checklist/checklist_bloc.dart';
import 'logic/vehicle_verification/vehicle_verification_bloc.dart';

Future<void> main() async {
  // Set up global error handling
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    };

    // Handle errors outside Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Platform Error: $error');
      debugPrint('Stack trace: $stack');
      
      // Handle specific Failure objects that might escape BLoC handling
      if (error is ServerFailure) {
        debugPrint('Unhandled ServerFailure detected: ${error.message}');
        // Convert to appropriate exception for logging
        if (error.message.toLowerCase().contains('rate limit')) {
          debugPrint('Rate limit error - should be handled by UI layer');
        }
      } else if (error is NetworkFailure) {
        debugPrint('Unhandled NetworkFailure detected: ${error.message}');
      } else if (error is ValidationFailure) {
        debugPrint('Unhandled ValidationFailure detected: ${error.message}');
      }
      
      return true;
    };
    
    try {
      // Load environment variables
      await dotenv.load(fileName: ".env");
      
      await Firebase.initializeApp();
      await di.configureDependencies();
      
      runApp(const MyApp());
    } catch (e, stackTrace) {
      debugPrint('App initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Run a minimal error app
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to initialize app',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Error: ${e.toString()}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      main(); // Retry initialization
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }, (error, stack) {
    // Global zone error handler
    debugPrint('Zone Error: $error');
    debugPrint('Stack trace: $stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<ChecklistBloc>(create: (_) => di.sl<ChecklistBloc>()),
        BlocProvider<VehicleVerificationBloc>(create: (_) => di.sl<VehicleVerificationBloc>()),
      ],
      child: const App(),
    );
  }
}