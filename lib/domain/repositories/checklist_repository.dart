  // lib/domain/repositories/checklist_repository.dart
  import 'package:carcheckmate/domain/entities/car.dart';
  import 'package:carcheckmate/domain/entities/car_summary.dart';

  abstract class ChecklistRepository {
    Future<List<CarSummary>> getCarSummaries();
    Future<Car?> getCarById(String carId);
    Future<Car?> getCarByModelDetails(String brand, String model, dynamic year);
  }