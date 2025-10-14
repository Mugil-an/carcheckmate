import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/vehicle_verification/vehicle_verification_bloc.dart';
import '../../logic/vehicle_verification/vehicle_verification_event.dart';
import '../widgets/vehicle_details_card.dart';
import '../widgets/vehicle_search_bar.dart';
import '../widgets/common_background.dart';
import '../../utilities/dialogs/error_dialog.dart';

class RtoLienVerificationScreen extends StatelessWidget {
  const RtoLienVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CommonAppBar(
          title: 'RTO & Lien Verification',
        ),
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle Search',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter registration number to fetch complete vehicle details.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const VehicleSearchBar(),
                  ],
                ),
              ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocConsumer<VehicleVerificationBloc, VehicleVerificationState>(
              listener: (context, state) async {
                if (state is VehicleVerificationError) {
                  await showErrorDialog(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is VehicleVerificationInitial) {
                  return const Center(
                    child: Text(
                      'Enter a vehicle number to search',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                } else if (state is VehicleVerificationLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                } else if (state is VehicleVerificationLoaded) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: VehicleDetailsCard(
                      vehicleDetails: state.vehicleDetails,
                    ),
                  );
                } else if (state is VehicleVerificationError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<VehicleVerificationBloc>().add(ResetVehicleVerification());
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}