import '../../domain/entities/vehicle_details.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../core/error/failures.dart';
import '../../core/exceptions/rto_exceptions.dart';
import '../datasources/vehicle_remote_data_source.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<VehicleDetails> getVehicleDetails(String vehicleNumber) async {
    try {
      // Validate vehicle number format
      if (vehicleNumber.isEmpty) {
        throw const InvalidVehicleNumberException();
      }

      // Basic format validation
      final cleanVehicleNumber = vehicleNumber.replaceAll(' ', '').toUpperCase();
      if (cleanVehicleNumber.length < 8) {
        throw const VehicleNumberFormatException();
      }

      return await remoteDataSource.getVehicleDetails(cleanVehicleNumber);
    } on RTOException {
      rethrow;
    } on NetworkFailure {
      throw const RTONetworkException();
    } on ServerFailure catch (e) {
      if (e.message.toLowerCase().contains('not found')) {
        throw const VehicleNumberNotFoundException();
      } else if (e.message.toLowerCase().contains('timeout')) {
        throw const RTOAPITimeoutException();
      } else if (e.message.toLowerCase().contains('rate limit')) {
        throw const RTOAPIRateLimitException();
      } else {
        throw const RTOAPIException();
      }
    } on ValidationFailure {
      throw const InvalidVehicleNumberException();
    } catch (e) {
      // Convert unknown exceptions to generic RTO exception
      throw GenericRTOException('Failed to fetch vehicle details: ${e.toString()}');
    }
  }
}