import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/vehicle_details.dart';
import '../../domain/usecases/get_vehicle_details.dart';
import 'vehicle_verification_event.dart';

part 'vehicle_verification_state.dart';

class VehicleVerificationBloc extends Bloc<VehicleVerificationEvent, VehicleVerificationState> {
  final GetVehicleDetailsUseCase getVehicleDetailsUseCase;

  VehicleVerificationBloc({
    required this.getVehicleDetailsUseCase,
  }) : super(VehicleVerificationInitial()) {
    
    on<GetVehicleDetails>((event, emit) async {
      try {
        emit(VehicleVerificationLoading());
        
        final vehicleDetails = await getVehicleDetailsUseCase(event.vehicleNumber);
        
        emit(VehicleVerificationLoaded(vehicleDetails: vehicleDetails));
      } catch (e) {
        String errorMessage = e.toString();
        
        // Handle specific rate limiting errors
        if (errorMessage.toLowerCase().contains('rate limit')) {
          errorMessage = 'Too many requests. Please wait 3 seconds before trying again.';
        } else if (errorMessage.toLowerCase().contains('subscription')) {
          errorMessage = 'API subscription required. Please check your RapidAPI subscription.';
        } else if (errorMessage.toLowerCase().contains('network')) {
          errorMessage = 'Network error. Please check your internet connection.';
        }
        
        emit(VehicleVerificationError(message: errorMessage));
      }
    });

    on<ResetVehicleVerification>((event, emit) {
      emit(VehicleVerificationInitial());
    });
  }
}