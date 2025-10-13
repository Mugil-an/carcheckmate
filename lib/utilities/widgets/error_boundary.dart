import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? errorTitle;
  final VoidCallback? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorTitle,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.errorTitle ?? 'Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _errorMessage = '';
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home',
                          (route) => false,
                        );
                      },
                      child: const Text('Go Home'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    try {
      return widget.child;
    } catch (error, stackTrace) {
      debugPrint('Error caught by ErrorBoundary: $error');
      debugPrint('Stack trace: $stackTrace');
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = error.toString();
          });
          
          if (widget.onError != null) {
            widget.onError!();
          }
        }
      });
      
      // Return a temporary loading widget while error state is being set
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}

/// Helper function to wrap widgets with error boundary
Widget withErrorBoundary(Widget child, {String? errorTitle, VoidCallback? onError}) {
  return ErrorBoundary(
    errorTitle: errorTitle,
    onError: onError,
    child: child,
  );
}