import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/vehicle_verification/vehicle_verification_bloc.dart';
import '../../logic/vehicle_verification/vehicle_verification_event.dart';

class VehicleSearchBar extends StatefulWidget {
  const VehicleSearchBar({super.key});

  @override
  State<VehicleSearchBar> createState() => _VehicleSearchBarState();
}

class _VehicleSearchBarState extends State<VehicleSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch() async {
    final vehicleNumber = _controller.text.trim();
    if (vehicleNumber.isEmpty || _isSearching) return;
    
    setState(() {
      _isSearching = true;
    });
    
    context.read<VehicleVerificationBloc>().add(GetVehicleDetails(vehicleNumber));
    
    // Reset after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Input Container
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
                  controller: _controller,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
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
                  textCapitalization: TextCapitalization.characters,
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
              _isSearching ? 'Searching...' : 'Search Vehicle',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E3A59),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}