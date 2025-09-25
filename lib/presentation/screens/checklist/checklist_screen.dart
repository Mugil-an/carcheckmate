import 'package:carcheckmate/presentation/screens/car_selection/car_selection_screen.dart';
import 'package:carcheckmate/presentation/screens/widgets/risk_meter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/checklist/checklist_bloc.dart';
import '../../../data/models/checklist_item.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final TextEditingController _carSelectionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car CheckMate"),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // TODO: open drawer or menu
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Car selection row
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _carSelectionController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Selected Car',
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final selectedCar = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CarSelectionScreen()),
                    );
                    if (selectedCar != null) {
                      setState(() {
                        _carSelectionController.text = selectedCar['display'];
                      });
                      context
                          .read<ChecklistBloc>()
                          .add(LoadInitialData(car: selectedCar));
                    }
                  },
                  child: const Text("Select Car"),
                ),
              ],
            ),
          ),

          // Risk Meter
          BlocBuilder<ChecklistBloc, ChecklistState>(
            builder: (context, state) {
              if (state.status == ChecklistStatus.loaded &&
                  state.checklistItems.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: RiskMeter(score: state.riskScore),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 8),

          // Checklist
          Expanded(
            child: BlocBuilder<ChecklistBloc, ChecklistState>(
              builder: (context, state) {
                if (state.status == ChecklistStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == ChecklistStatus.error) {
                  return Center(
                      child: Text(state.errorMessage ?? "Error loading"));
                } else if (state.status == ChecklistStatus.loaded) {
                  final items = state.checklistItems;
                  if (items.isEmpty) {
                    return const Center(child: Text("No checklist available"));
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final ChecklistItem item = items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 12.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12.0),
                          title: Text(item.issue,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Row(
                            children: [
                              Chip(
                                label: Text(item.severity),
                                backgroundColor: _severityColor(item.severity),
                                labelStyle: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                              Text("₹${item.estimatedCost}",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                            ],
                          ),
                          trailing: Checkbox(
                            value: state.itemSelections[item.issue] ?? false,
                            onChanged: (val) {
                              context.read<ChecklistBloc>().add(
                                  ToggleChecklistItem(
                                      issue: item.issue,
                                      selected: val ?? false));
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          )
        ],
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _carSelectionController.dispose();
    super.dispose();
  }
}
