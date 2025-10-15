// lib/data/repositories/checklist_repository_impl.dart
import 'package:carcheckmate/domain/repositories/checklist_repository.dart';
import 'package:carcheckmate/domain/entities/car.dart';
import 'package:carcheckmate/data/datasources/firebase_checklist_datasource.dart';
import 'package:carcheckmate/data/models/checklist_item.dart' as dmodel;
import 'package:carcheckmate/data/models/car_model.dart';
import '../../core/exceptions/checklist_exceptions.dart';

class ChecklistRepositoryImpl implements ChecklistRepository {
  final FirebaseChecklistDataSource _firebaseDataSource;

  ChecklistRepositoryImpl(this._firebaseDataSource);

  @override
  Future<List<Car>> getCarList() async {
    try {
      final carModels = await _firebaseDataSource.loadCarModels();
      // Empty list is acceptable - Firebase might be empty before migration
      return carModels.map((m) => _toDomainCar(m)).toList();
    } catch (e) {
      if (e is ChecklistException) rethrow;
      throw const ChecklistLoadFailedException();
    }
  }

  @override
  Future<Car?> getCarByModelDetails(String brand, String model, dynamic year) async {
    try {
      // Validate input parameters
      if (brand.isEmpty || model.isEmpty) {
        throw const InvalidCarSelectionException();
      }

      // Convert year to int if it's not already
      int yearInt;
      if (year is String) {
        yearInt = int.tryParse(year) ?? 0;
      } else if (year is int) {
        yearInt = year;
      } else {
        throw const InvalidCarSelectionException();
      }

      final carModel = await _firebaseDataSource.getCarByModelDetails(brand, model, yearInt);
      
      if (carModel == null) {
        throw const CarDataNotFoundException();
      }
      
      return _toDomainCar(carModel);
    } on ChecklistException {
      rethrow;
    } catch (e) {
      throw const CarDataNotFoundException();
    }
  }

  Car _toDomainCar(CarModel m) {
    final issues = m.issues;
    final severities = m.severities;
    final costs = m.estimatedCostsINR;

    final List<dmodel.ChecklistItem> items = [];
    for (int i = 0; i < issues.length; i++) {
      final issue = issues[i];
      final severity = i < severities.length ? severities[i] : (severities.isNotEmpty ? severities.first : 'low');
      final cost = i < costs.length ? costs[i] : 0;
      items.add(dmodel.ChecklistItem(issue: issue, severity: severity, estimatedCost: cost));
    }

    return Car(
      id: _idFor(m),
      displayName: m.displayName,
      checklistItems: items,
    );
  }

  String _idFor(CarModel m) => m.id;
}