import 'package:equatable/equatable.dart';

abstract class VehicleVerificationEvent extends Equatable {
  const VehicleVerificationEvent();

  @override
  List<Object?> get props => [];
}

class GetVehicleDetails extends VehicleVerificationEvent {
  final String vehicleNumber;

  const GetVehicleDetails(this.vehicleNumber);

  @override
  List<Object> get props => [vehicleNumber];
}

class ResetVehicleVerification extends VehicleVerificationEvent {}