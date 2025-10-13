import 'package:flutter/material.dart';
import '../../domain/entities/vehicle_details.dart';

class VehicleDetailsCard extends StatelessWidget {
  final VehicleDetails vehicleDetails;

  const VehicleDetailsCard({
    super.key,
    required this.vehicleDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // RC/VIN Details Card
        _buildDetailsCard(
          title: 'Check RC/VIN details',
          subtitle: 'Verify RC number, VIN/Chassis, engine no.',
          icon: Icons.search,
          child: Column(
            children: [
              _buildDetailRow('RC', vehicleDetails.rc),
              _buildDetailRow('VIN (masked)', vehicleDetails.vinMasked),
              _buildDetailRow('Engine no. (masked)', vehicleDetails.engineNoMasked),
              _buildDetailRow('Maker / Model', vehicleDetails.makerModel),
              _buildDetailRow('Fuel', vehicleDetails.fuel),
              _buildDetailRow('Tax status', vehicleDetails.taxStatus),
              _buildDetailRow('RC valid till', vehicleDetails.rcValidTill),
              _buildDetailRow('Blacklist', vehicleDetails.blacklist, 
                  isStatus: true, statusColor: Colors.green),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Hypothecation Status Card
        _buildDetailsCard(
          title: 'Hypothecation (Lien) status',
          subtitle: 'Ensure loan closure / NOC is updated in RC',
          icon: Icons.account_balance,
          child: Column(
            children: [
              if (vehicleDetails.lienStatus != null) ...[
                Row(
                  children: [
                    const Icon(Icons.account_balance, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicleDetails.lienStatus!.bank,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Status: ${vehicleDetails.lienStatus!.status}  '
                            'From: ${vehicleDetails.lienStatus!.activeFrom}  '
                            'To: ${vehicleDetails.lienStatus!.activeTo}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: vehicleDetails.lienStatus!.isActive 
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        vehicleDetails.lienStatus!.status,
                        style: TextStyle(
                          color: vehicleDetails.lienStatus!.isActive 
                              ? Colors.orange
                              : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'No active lien',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Ownership/Fitness Card
        _buildDetailsCard(
          title: 'Ownership / Fitness',
          subtitle: 'Ownership history (where available) and fitness validity',
          icon: Icons.history,
          child: Column(
            children: [
              _buildDetailRow('Fitness valid till', vehicleDetails.fitnessStatus.fitnessValidTill),
              _buildDetailRow('RC valid till', vehicleDetails.fitnessStatus.rcValidTill),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      vehicleDetails.fitnessStatus.status,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF404040),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: isStatus && statusColor != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}