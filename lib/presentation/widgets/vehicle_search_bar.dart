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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF404040),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(
              Icons.directions_car,
              color: Colors.grey,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                hintText: 'tn22ab1122',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (_) => _onSearch(),
              textCapitalization: TextCapitalization.characters,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(4),
            child: ElevatedButton(
              onPressed: _isSearching ? null : _onSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSearching ? Colors.grey : const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: _isSearching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}