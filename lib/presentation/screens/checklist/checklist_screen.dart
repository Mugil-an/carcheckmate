import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/checklist/checklist_bloc.dart';
import '../../widgets/common_background.dart';
import '../widgets/risk_meter.dart';
import '../../../app/theme.dart';

class ChecklistScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedCar;

  const ChecklistScreen({super.key, this.selectedCar});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {

  @override
  void initState() {
    super.initState();
    // Always load all cars first
    context.read<ChecklistBloc>().add(LoadInitialData());
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CommonAppBar(title: 'Vehicle Checklist'),
        body: BlocBuilder<ChecklistBloc, ChecklistState>(
          builder: (context, state) {
            if (state.status == ChecklistStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }
            
            if (state.status == ChecklistStatus.error) {
              return Center(
                child: Text(
                  state.errorMessage ?? "Error loading",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            
            return Column(
              children: [
                // Car Selection Dropdown
                if (state.carList.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/car_selection');
                      },
                      icon: const Icon(Icons.directions_car),
                      label: Text(
                        state.selectedCar?.displayName ?? 'Select a vehicle to inspect',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        minimumSize: const Size(double.infinity, 56),
                      ),
                    ),
                  ),
                ],
                
                // Risk Meter - shown when checklist is loaded
                if (state.selectedCar != null && state.checklistItems.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: RiskMeter(score: state.riskScore),
                  ),
                ],
                
                // Checklist Items
                Expanded(
                  child: _buildChecklistContent(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  // Helper method to get severity color
  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green[600] ?? Colors.green;
      case 'medium':
        return Colors.orange[600] ?? Colors.orange;
      case 'high':
        return Colors.red[600] ?? Colors.red;
      default:
        return Colors.grey[600] ?? Colors.grey;
    }
  }
  
  // Helper method to get cost color based on amount
  Color _getCostColor(int cost) {
    return Colors.grey[600] ?? Colors.grey;
  }
  
  Widget _buildChecklistContent(ChecklistState state) {
    if (state.selectedCar == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'Please select a vehicle from the dropdown above',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    if (state.checklistItems.isEmpty) {
      return const Center(
        child: Text(
          'No checklist items available for this vehicle',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: state.checklistItems.length,
      itemBuilder: (context, index) {
        final item = state.checklistItems[index];
        final isSelected = state.itemSelections[item.issue] ?? false;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primaryDark
                  : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (bool? value) {
              context.read<ChecklistBloc>().add(
                ToggleChecklistItem(
                  issue: item.issue,
                  selected: value ?? false,
                ),
              );
            },
            title: Text(
              item.issue,
              style: TextStyle(
                color: isSelected ? AppColors.primaryDark : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Severity Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(item.severity),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.severity.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Cost Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCostColor(item.estimatedCost),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '₹${item.estimatedCost}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            activeColor: Colors.red,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.trailing,
          ),
        );
      },
    );
  }
}