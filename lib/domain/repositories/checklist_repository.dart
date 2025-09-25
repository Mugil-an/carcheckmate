// lib/domain/repositories/checklist_repository.dart
import 'package:carcheckmate/domain/entities/car.dart';

abstract class ChecklistRepository {
  Future<List<Car>> getCarList();
  Future<Car?> getCarByModelDetails(String brand, String model, int year);
}