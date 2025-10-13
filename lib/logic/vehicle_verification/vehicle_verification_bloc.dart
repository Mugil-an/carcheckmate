import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/vehicle_details.dart';
import '../../domain/usecases/get_vehicle_details.dart';
import '../../core/exceptions/rto_exceptions.dart';
import '../../core/error/failures.dart';
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
      } on RTOException catch (e) {
        // RTO exceptions are already user-friendly
        debugPrint('RTOException in BLoC: ${e.message}');
        emit(VehicleVerificationError(message: e.message));
      } on ServerFailure catch (e) {
        // Handle ServerFailure specifically
        debugPrint('ServerFailure in BLoC: ${e.message}');
        String userMessage;
        if (e.message.toLowerCase().contains('rate limit')) {
          userMessage = const RTOAPIRateLimitException().message;
        } else if (e.message.toLowerCase().contains('not found')) {
          userMessage = const VehicleNumberNotFoundException().message;
        } else if (e.message.toLowerCase().contains('timeout')) {
          userMessage = const RTOAPITimeoutException().message;
        } else if (e.message.toLowerCase().contains('unauthorized') || 
                   e.message.toLowerCase().contains('forbidden')) {
          userMessage = const RTOAuthenticationException().message;
        } else {
          userMessage = const RTOAPIException().message;
        }
        emit(VehicleVerificationError(message: userMessage));
      } on NetworkFailure catch (e) {
        // Handle NetworkFailure
        debugPrint('NetworkFailure in BLoC: ${e.message}');
        emit(VehicleVerificationError(message: const RTONetworkException().message));
      } on ValidationFailure catch (e) {
        // Handle ValidationFailure
        debugPrint('ValidationFailure in BLoC: ${e.message}');
        emit(VehicleVerificationError(message: const InvalidVehicleNumberException().message));
      } on Failure catch (e) {
        // Handle any other Failure types
        debugPrint('Other Failure in BLoC: ${e.message}');
        emit(VehicleVerificationError(message: 'Service temporarily unavailable. Please try again.'));
      } catch (e) {
        // Handle any remaining exceptions
        debugPrint('Unexpected error in BLoC: $e');
        String errorMessage = e.toString();
        String userMessage;
        
        // Handle specific rate limiting errors
        if (errorMessage.toLowerCase().contains('rate limit')) {
          userMessage = const RTOAPIRateLimitException().message;
        } else if (errorMessage.toLowerCase().contains('subscription')) {
          userMessage = const RTOAuthenticationException().message;
        } else if (errorMessage.toLowerCase().contains('network')) {
          userMessage = const RTONetworkException().message;
        } else if (errorMessage.toLowerCase().contains('not found')) {
          userMessage = const VehicleNumberNotFoundException().message;
        } else {
          userMessage = 'An unexpected error occurred. Please try again.';
        }
        
        emit(VehicleVerificationError(message: userMessage));
      }
    });

    on<ResetVehicleVerification>((event, emit) {
      emit(VehicleVerificationInitial());
    });
  }
}