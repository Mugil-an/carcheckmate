import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/vehicle_verification/vehicle_verification_bloc.dart';
import '../../logic/vehicle_verification/vehicle_verification_event.dart';
import '../../core/utils/exception_handler.dart';
import '../../app/theme.dart';

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
    
    // Validate vehicle number format
    if (!_isValidVehicleNumber(vehicleNumber)) {
      ExceptionHandler.handleError(
        context,
        'Invalid vehicle number format',
        title: 'Validation Error',
        customMessage: 'Please enter a valid vehicle number (e.g., DL01AB1234)',
      );
      return;
    }
    
    setState(() {
      _isSearching = true;
    });
    
    try {
      context.read<VehicleVerificationBloc>().add(GetVehicleDetails(vehicleNumber));
    } catch (e) {
      if (mounted) {
        ExceptionHandler.handleError(
          context,
          e,
          title: 'Search Error',
          customMessage: 'Failed to search for vehicle details. Please try again.',
        );
        setState(() {
          _isSearching = false;
        });
      }
      return;
    }
    
    // Reset after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  bool _isValidVehicleNumber(String vehicleNumber) {
    // Basic validation for Indian vehicle number format
    final regex = RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,2}[0-9]{1,4}$');
    return regex.hasMatch(vehicleNumber.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Input Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
              backgroundColor: Colors.white.withValues(alpha: 0.95),
              foregroundColor: AppColors.primaryDark,
              elevation: 4,
              shadowColor: Colors.black26,
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