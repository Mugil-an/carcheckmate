import '../entities/vehicle_details.dart';

abstract class VehicleRepository {
  Future<VehicleDetails> getVehicleDetails(String vehicleNumber);
}