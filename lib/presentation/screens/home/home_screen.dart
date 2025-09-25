// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carcheckmate/logic/checklist/checklist_bloc.dart';
import 'package:carcheckmate/domain/entities/car.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Car? _selected;

  @override
  void initState() {
    super.initState();
    // load cars
    context.read<ChecklistBloc>().add(LoadInitialData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CarCheckMate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<ChecklistBloc, ChecklistState>(
          listener: (context, state) {
            if (state.status == ChecklistStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Error')),
              );
            }
          },
          builder: (context, state) {
            if (state.status == ChecklistStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final cars = state.carList;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Select your car', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                DropdownButton<Car>(
                  value: _selected,
                  hint: const Text('Choose car model'),
                  items: cars.map((c) => DropdownMenuItem(value: c, child: Text(c.displayName))).toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => _selected = val);
                    // dispatch CarSelected
                    context.read<ChecklistBloc>().add(CarSelected(val));
                    // navigate to checklist screen
                    Navigator.pushNamed(context, '/checklist');
                  },
                ),
                const SizedBox(height: 24),
                const Text('Or pick from the list below', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: cars.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final c = cars[i];
                      return ListTile(
                        title: Text(c.displayName),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.read<ChecklistBloc>().add(CarSelected(c));
                          Navigator.pushNamed(context, '/checklist');
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
