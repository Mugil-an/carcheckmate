import 'package:flutter/material.dart';
import 'package:carcheckmate/core/di/service_locator.dart';

class CarSelectionScreen extends StatefulWidget {
  const CarSelectionScreen({super.key});

  @override
  State<CarSelectionScreen> createState() => _CarSelectionScreenState();
}

class _CarSelectionScreenState extends State<CarSelectionScreen> {
  final List<Map<String, dynamic>> _carsForSelection = sl<List<Map<String, dynamic>>>(instanceName: 'carsForSelection');
  List<Map<String, dynamic>> _filteredCars = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carsForSelection.sort((a, b) => a['display'].compareTo(b['display']));
    _filteredCars = _carsForSelection;
    _searchController.addListener(_filterCars);
  }

  void _filterCars() {
    setState(() {
      _filteredCars = _carsForSelection
          .where((car) => car['display'].toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Car'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCars.length,
              itemBuilder: (context, index) {
                final car = _filteredCars[index];
                return ListTile(
                  title: Text(car['display']),
                  onTap: () {
                    Navigator.pop(context, car);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}