import 'package:flutter/material.dart';
import '../../widgets/common_background.dart';

class RTOScreen extends StatefulWidget {
  const RTOScreen({super.key});

  @override
  State<RTOScreen> createState() => _RTOScreenState();
}

class _RTOScreenState extends State<RTOScreen> {
  final TextEditingController _registrationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CommonAppBar(title: 'RTO & Lien Verification'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RTO & Lien Verification',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter registration number to fetch RC/VIN/engine, tax, fitness, hypothecation and e-Challan summary.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),

                // Registration Number Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.white70,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _registrationController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'tn22ab1122',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Search Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement RTO search
                      if (_registrationController.text.isNotEmpty) {
                        _showRTODetails();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter registration number')),
                        );
                      }
                    },
                    icon: const Icon(Icons.search, size: 24),
                    label: const Text(
                      'Search',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2E3A59),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Features Section
                const Text(
                  'Check RC/VIN details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Verify RC number, VIN/Chassis, engine no.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),

                // Sample Data Preview (mock)
                _buildInfoSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('RC', 'TN22AB1122'),
            const SizedBox(height: 12),
            _buildInfoRow('VIN (masked)', 'MA3EKEB1S00123***'),
            const SizedBox(height: 12),
            _buildInfoRow('Engine no. (masked)', 'D13A***'),
            const SizedBox(height: 12),
            _buildInfoRow('Maker / Model', 'Volkswagen Jetta TDI Highline'),
            const SizedBox(height: 12),
            _buildInfoRow('Fuel', 'Diesel'),
            const SizedBox(height: 12),
            _buildInfoRow('Tax status', 'PAID'),
            const SizedBox(height: 12),
            _buildInfoRow('RC valid till', '2027-10-15'),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Blacklist',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _showRTODetails() {
    // Mock implementation - show bottom sheet with details
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2332),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'RTO Details Found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vehicle details have been fetched successfully. Check the details above.',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E3A59),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _registrationController.dispose();
    super.dispose();
  }
}