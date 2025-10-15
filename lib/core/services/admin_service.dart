// lib/core/services/admin_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carcheckmate/data/models/car_model.dart';
import 'package:carcheckmate/data/datasources/firebase_checklist_datasource.dart';
import '../config/admin_config.dart';
import '../../core/exceptions/admin_exceptions.dart';

class AdminService {
  static String get _adminEmail => AdminConfig.adminEmail;
  final FirebaseAuth _auth;
  final FirebaseChecklistDataSource _checklistDataSource;

  AdminService(this._auth, this._checklistDataSource);

  /// Check if current user is admin
  bool get isCurrentUserAdmin {
    final user = _auth.currentUser;
    if (user == null || !user.emailVerified) {
      return false;
    }
    return user.email?.toLowerCase() == _adminEmail.toLowerCase();
  }

  /// Get current user email
  String? get currentUserEmail => _auth.currentUser?.email;

  /// Validate admin access and throw exception if not admin
  void validateAdminAccess() {
    if (!isCurrentUserAdmin) {
      throw AdminAccessDeniedException(
        userEmail: currentUserEmail ?? 'unknown',
      );
    }
  }

  /// Add a new car model to Firebase
  Future<void> addCarModel({
    required String brand,
    required String model,
    required int year,
    required List<String> issues,
    required List<String> severities,
    required List<int> estimatedCostsINR,
  }) async {
    validateAdminAccess();

    try {
      // Validate input data
      if (brand.trim().isEmpty || model.trim().isEmpty) {
        throw const InvalidCarDataException('Brand and model cannot be empty');
      }

      if (year < 1900 || year > DateTime.now().year + 5) {
        throw const InvalidCarDataException('Invalid year');
      }

      if (issues.isEmpty) {
        throw const InvalidCarDataException('At least one issue must be provided');
      }

      if (issues.length != severities.length || issues.length != estimatedCostsINR.length) {
        throw const InvalidCarDataException('Issues, severities, and costs must have the same length');
      }

      // Create car model
      final carModel = CarModel(
        id: '${brand.trim()}-${model.trim()}-$year',
        displayName: '${brand.trim()} ${model.trim()} ($year)',
        brand: brand.trim(),
        model: model.trim(),
        year: year,
        issues: issues.map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        severities: severities.map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        estimatedCostsINR: estimatedCostsINR.where((e) => e > 0).toList(),
      );

      // Save to Firebase
      await _checklistDataSource.saveCarModel(carModel);
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminOperationFailedException('Failed to add car model: ${e.toString()}');
    }
  }

  /// Check if a car model already exists
  Future<bool> carModelExists(String brand, String model, int year) async {
    try {
      final existing = await _checklistDataSource.getCarByModelDetails(brand, model, year);
      return existing != null;
    } catch (e) {
      return false;
    }
  }

  /// Get total count of car models in database
  Future<int> getCarModelCount() async {
    try {
      final cars = await _checklistDataSource.loadCarModels();
      return cars.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get recent car models (last 10 added)
  Future<List<CarModel>> getRecentCarModels() async {
    try {
      final cars = await _checklistDataSource.loadCarModels();
      // Sort by display name and return last 10
      cars.sort((a, b) => b.displayName.compareTo(a.displayName));
      return cars.take(10).toList();
    } catch (e) {
      return [];
    }
  }
}