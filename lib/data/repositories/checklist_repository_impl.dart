// lib/data/repositories/checklist_repository_impl.dart
import 'package:carcheckmate/domain/repositories/checklist_repository.dart';
import 'package:carcheckmate/domain/entities/car.dart';
import 'package:carcheckmate/data/datasources/local_checklist_datasource.dart';
import 'package:carcheckmate/data/models/checklist_item.dart' as dmodel;
import 'package:carcheckmate/data/models/car_model.dart';

class ChecklistRepositoryImpl implements ChecklistRepository {
  final LocalChecklistDataSource _local;

  ChecklistRepositoryImpl(this._local);

  @override
  Future<List<Car>> getCarList() async {
    final carModels = await _local.loadCarModels();
    return carModels.map((m) => _toDomainCar(m)).toList();
  }

  @override
  Future<Car?> getCarByModelDetails(String brand, String model, dynamic year) async {
    final carModels = await _local.loadCarModels();
    try {
      final carModel = carModels.firstWhere((car) =>
          car.brand == brand &&
          car.model == model &&
          car.year.toString() == year.toString());
      return _toDomainCar(carModel);
    } catch (e) {
      return null;
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