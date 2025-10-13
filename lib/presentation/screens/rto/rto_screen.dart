import 'package:flutter/material.dart';
import '../../widgets/common_background.dart';
import '../rto_lien_verification_screen.dart';
import '../../../app/theme.dart';

class RTOScreen extends StatefulWidget {
  const RTOScreen({super.key});

  @override
  State<RTOScreen> createState() => _RTOScreenState();
}

class _RTOScreenState extends State<RTOScreen> {
  final TextEditingController _registrationController = TextEditingController();
  bool _isSearching = false;

  void _onSearch() async {
    final vehicleNumber = _registrationController.text.trim();
    if (vehicleNumber.isEmpty || _isSearching) return;
    
    setState(() {
      _isSearching = true;
    });
    
    // Navigate to the actual RTO verification screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RtoLienVerificationScreen(),
      ),
    );
    
    // Reset after navigation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'RTO & Lien Verification',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter registration number to fetch RC/VIN/engine, tax, fitness, hypothecation and e-Challan summary.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Registration Number Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _registrationController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            hintText: 'TN22AB1122',
                            hintStyle: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 20),
                          ),
                          onSubmitted: (_) => _onSearch(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Search Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isSearching ? null : _onSearch,
                    icon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF2E3A59),
                              ),
                            ),
                          )
                        : const Icon(Icons.search, size: 24),
                    label: Text(
                      _isSearching ? 'Searching...' : 'Verify Vehicle',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.95),
                      foregroundColor: AppColors.primaryDark,
                      elevation: 4,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Features Section
                _buildFeaturesList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.assignment, 'text': 'RC Number Verification'},
      {'icon': Icons.security, 'text': 'VIN/Chassis Number Check'},
      {'icon': Icons.build, 'text': 'Engine Number Validation'},
      {'icon': Icons.account_balance, 'text': 'Tax & Fitness Status'},
      {'icon': Icons.warning, 'text': 'Blacklist Verification'},
      {'icon': Icons.gavel, 'text': 'Hypothecation Details'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What You\'ll Get:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        size: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature['text'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }



  @override
  void dispose() {
    _registrationController.dispose();
    super.dispose();
  }
}