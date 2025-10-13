part of 'vehicle_verification_bloc.dart';

abstract class VehicleVerificationState {
  const VehicleVerificationState();
}

class VehicleVerificationInitial extends VehicleVerificationState {}

class VehicleVerificationLoading extends VehicleVerificationState {}

class VehicleVerificationLoaded extends VehicleVerificationState {
  final VehicleDetails vehicleDetails;

  const VehicleVerificationLoaded({required this.vehicleDetails});
}

class VehicleVerificationError extends VehicleVerificationState {
  final String message;

  const VehicleVerificationError({required this.message});
}