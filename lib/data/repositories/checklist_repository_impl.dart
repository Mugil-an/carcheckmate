// lib/data/repositories/checklist_repository_impl.dart
import 'package:carcheckmate/domain/repositories/checklist_repository.dart';
import 'package:carcheckmate/domain/entities/car.dart';
import 'package:carcheckmate/data/datasources/local_checklist_datasource.dart';
import 'package:carcheckmate/data/models/checklist_item.dart' as dmodel;
import 'package:carcheckmate/data/models/car_model.dart';
import '../../core/exceptions/checklist_exceptions.dart';

class ChecklistRepositoryImpl implements ChecklistRepository {
  final LocalChecklistDataSource _local;

  ChecklistRepositoryImpl(this._local);

  @override
  Future<List<Car>> getCarList() async {
    try {
      final carModels = await _local.loadCarModels();
      if (carModels.isEmpty) {
        throw const CarListLoadFailedException();
      }
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

      final carModels = await _local.loadCarModels();
      if (carModels.isEmpty) {
        throw const CarListLoadFailedException();
      }

      final carModel = carModels.firstWhere(
        (car) =>
            car.brand == brand &&
            car.model == model &&
            car.year.toString() == year.toString(),
        orElse: () => throw const CarDataNotFoundException(),
      );
      
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