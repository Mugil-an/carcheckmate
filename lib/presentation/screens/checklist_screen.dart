import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/checklist/checklist_bloc.dart';
import '../screens/widgets/risk_meter.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checklist')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<ChecklistBloc, ChecklistState>(
          builder: (context, state) {
            if (state.status == ChecklistStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == ChecklistStatus.error) {
              return Center(child: Text(state.errorMessage ?? 'Error'));
            }

            // Display risk meter and checklist
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: RiskMeter(score: state.riskScore, size: 220)),
                  const SizedBox(height: 18),
                  Text(
                    state.selectedCar != null ? state.selectedCar!.displayName : 'Select a car',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.checklistItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 8),
                    itemBuilder: (context, index) {
                      final item = state.checklistItems[index];
                      final selected = state.itemSelections[item.issue] ?? false;
                      return ListTile(
                        title: Text(item.issue),
                        subtitle: Text('${item.severity} · ₹${item.estimatedCost.toStringAsFixed(0)}'),
                        trailing: Switch(
                          value: selected,
                          onChanged: (v) {
                            context.read<ChecklistBloc>().add(ToggleChecklistItem(issue: item.issue, selected: v));
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
