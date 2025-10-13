import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/vehicle_verification/vehicle_verification_bloc.dart';
import '../../logic/vehicle_verification/vehicle_verification_event.dart';
import '../widgets/vehicle_details_card.dart';
import '../widgets/vehicle_search_bar.dart';

class RtoLienVerificationScreen extends StatelessWidget {
  const RtoLienVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Car CheckMate',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'RTO & Lien Verification',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Enter registration number to fetch RC/VIN/engine, tax, fitness, hypothecation and e-Challan summary.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: VehicleSearchBar(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<VehicleVerificationBloc, VehicleVerificationState>(
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
    );
  }
}