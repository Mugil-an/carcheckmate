import '../entities/vehicle_details.dart';
import '../repositories/vehicle_repository.dart';
import '../../core/error/failures.dart';

class GetVehicleDetailsUseCase {
  final VehicleRepository repository;

  GetVehicleDetailsUseCase(this.repository);

  Future<VehicleDetails> call(String vehicleNumber) async {
    // Input validation
    if (vehicleNumber.isEmpty) {
      throw const ValidationFailure('Vehicle number cannot be empty');
    }
    
    // Clean and format vehicle number
    final cleanVehicleNumber = vehicleNumber.replaceAll(' ', '').toUpperCase();
    
    // Validate Indian vehicle registration format
    if (!_isValidIndianVehicleNumber(cleanVehicleNumber)) {
      throw const ValidationFailure(
        'Invalid vehicle number format. Please enter a valid Indian registration number (e.g., MH12AB1234)'
      );
    }

    try {
      return await repository.getVehicleDetails(cleanVehicleNumber);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  bool _isValidIndianVehicleNumber(String vehicleNumber) {
    // Indian vehicle number format: 2 letters + 2 digits + 2 letters + 4 digits
    // Examples: MH12AB1234, TN22AB1122, KA01BC2345
    final regex = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$');
    return regex.hasMatch(vehicleNumber) && vehicleNumber.length >= 8 && vehicleNumber.length <= 10;
  }
}