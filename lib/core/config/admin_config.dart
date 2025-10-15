// lib/core/config/admin_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminConfig {
  /// Get admin email from environment variables
  static String get adminEmail {
    final email = dotenv.env['ADMIN_EMAIL'];
    
    if (email == null || email.isEmpty) {
      throw AdminConfigException(
        'ADMIN_EMAIL not found in environment variables. '
        'Please ensure your .env file contains ADMIN_EMAIL=your_email@example.com'
      );
    }
    
    // Basic email validation
    if (!_isValidEmail(email)) {
      throw AdminConfigException(
        'Invalid ADMIN_EMAIL format in environment variables: $email'
      );
    }
    
    return email.toLowerCase().trim();
  }
  
  /// Validate email format
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Check if admin email is properly configured
  static bool get isAdminEmailConfigured {
    try {
      adminEmail;
      return true;
    } catch (e) {
      return false;
    }
  }
}

class AdminConfigException implements Exception {
  final String message;
  const AdminConfigException(this.message);
  
  @override
  String toString() => 'AdminConfigException: $message';
}