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
      // Global error handling for navigation and builder errors
      builder: (context, child) {
        // Wrap the entire app with error handling
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return _ErrorFallbackWidget(
            error: details.exception.toString(),
            stackTrace: details.stack.toString(),
          );
        };

        return child ?? const SizedBox();
      },
    );
  }
}

class _ErrorFallbackWidget extends StatelessWidget {
  final String error;
  final String stackTrace;

  const _ErrorFallbackWidget({
    required this.error,
    required this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Application Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Something went wrong. Please restart the app.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (error.isNotEmpty) ...[
                const Text(
                  'Error Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
