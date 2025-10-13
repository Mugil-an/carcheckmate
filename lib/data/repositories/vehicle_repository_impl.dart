import '../../domain/entities/vehicle_details.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/vehicle_remote_data_source.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<VehicleDetails> getVehicleDetails(String vehicleNumber) async {
    try {
      return await remoteDataSource.getVehicleDetails(vehicleNumber);
    } on NetworkFailure {
      rethrow;
    } on ServerFailure {
      rethrow;
    } on ValidationFailure {
      rethrow;
    } catch (e) {
      // Convert unknown exceptions to ServerFailure
      throw ServerFailure('Failed to fetch vehicle details: ${e.toString()}');
    }
  }
}