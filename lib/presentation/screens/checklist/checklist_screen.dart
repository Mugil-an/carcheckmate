import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/checklist/checklist_bloc.dart';
import '../../widgets/common_background.dart';
import '../widgets/risk_meter.dart';
import '../../../app/theme.dart';
import '../../../utilities/dialogs/error_dialog.dart';

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
        body: BlocConsumer<ChecklistBloc, ChecklistState>(
          listener: (context, state) async {
            if (state.status == ChecklistStatus.error) {
              await showErrorDialog(
                context,
                state.errorMessage ?? 'An error occurred while loading checklist data',
              );
            }
          },
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading checklist',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ChecklistBloc>().add(LoadInitialData());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            return Column(
              children: [
                // Show message when no cars are available
                if (state.carList.isEmpty) ...[
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Car Data Available',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'The checklist database is empty. You need to migrate data from local files to Firebase.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pushNamed(context, '/admin/migration');
                          },
                          icon: const Icon(Icons.upload),
                          label: const Text('Go to Data Migration'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Car Selection Dropdown
                if (state.carList.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final result = await Navigator.pushNamed(context, '/car_selection');
                          // If car was selected, the bloc should already be updated
                          // But let's add some debugging and error recovery
                          if (mounted && result == null) {
                            // User might have canceled selection
                            debugPrint('Car selection was canceled or no car was selected');
                          }
                        } catch (e) {
                          if (mounted) {
                            showErrorDialog(context, 'Failed to open car selection. Please try again.');
                          }
                        }
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
                
                // Risk Meter - shown when car is selected and risk score is available
                if (state.selectedCar != null && state.status == ChecklistStatus.loaded) ...[
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
    
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.checklistItems.length,
            itemBuilder: (context, index) {
        final item = state.checklistItems[index];
        final isSelected = state.itemSelections[item.issue] ?? false;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primaryDark
                  : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (value) async {
              try {
                context.read<ChecklistBloc>().add(
                  ToggleChecklistItem(
                    issue: item.issue,
                    selected: value ?? false,
                  ),
                );
              } catch (e) {
                await showErrorDialog(context, 'Failed to update checklist item. Please try again.');
              }
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
    ),
        ),
        // Risk Score Button
      ],
    );
  }

}