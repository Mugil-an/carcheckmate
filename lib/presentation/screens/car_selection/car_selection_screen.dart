import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/checklist/checklist_bloc.dart';
import '../../../domain/entities/car_summary.dart';
import '../../widgets/common_background.dart';
import '../../../utilities/dialogs/error_dialog.dart';
import '../../../app/theme.dart';

class CarSelectionScreen extends StatefulWidget {
  const CarSelectionScreen({super.key});

  @override
  State<CarSelectionScreen> createState() => _CarSelectionScreenState();
}

class _CarSelectionScreenState extends State<CarSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CarSummary> _filteredCars = [];
  List<CarSummary> _allCars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
    _searchController.addListener(_filterCars);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCars() async {
    try {
      context.read<ChecklistBloc>().add(const LoadCarList());
    } catch (_) {
      await showErrorDialog(context, 'Failed to load car data. Please try again.');
    }
  }

  void _filterCars() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCars = List<CarSummary>.from(_allCars);
      } else {
        _filteredCars = _allCars.where((car) {
          return car.displayName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }


  Future<void> _onCarSelected(CarSummary car) async {
    try {
      context.read<ChecklistBloc>().add(CarSelected(car));
      Navigator.of(context).pop();
    } catch (_) {
      await showErrorDialog(context, 'Failed to select ${car.displayName}. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CommonAppBar(title: 'Select Vehicle'),
        body: BlocListener<ChecklistBloc, ChecklistState>(
          listener: (context, state) {
            setState(() {
              _isLoading = state.status == ChecklistStatus.loading;
            });

            if (state.status == ChecklistStatus.loaded) {
              _allCars = List<CarSummary>.from(state.carList);
              _filteredCars = List<CarSummary>.from(state.carList);
            } else if (state.status == ChecklistStatus.error) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Car Selection Error'),
                      content: Text(state.errorMessage ?? 'Unknown error occurred'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.read<ChecklistBloc>().add(const LoadCarList());
                          },
                          child: const Text('Retry'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
            }
          },
          child: Column(
            children: [
              // Search Bar
              Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.3)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search vehicles...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              // Search Results Count
              if (_searchController.text.isNotEmpty && _filteredCars.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_filteredCars.length} vehicles found',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Cars List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                        ),
                      )
                    : _filteredCars.isEmpty
                        ? _buildEmptyState()
                        : _buildCarsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchController.text.isNotEmpty 
                  ? Icons.search_off
                  : Icons.directions_car_outlined,
              size: 80,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty 
                  ? 'No vehicles found'
                  : 'No vehicles available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty 
                  ? 'Try adjusting your search terms'
                  : 'Database appears to be empty. Use Data Migration to populate vehicle data.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
              ),
            ] else if (_allCars.isEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/admin/migration');
                },
                icon: const Icon(Icons.upload),
                label: const Text('Go to Data Migration'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCarsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _filteredCars.length,
      itemBuilder: (context, index) {
        final car = _filteredCars[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.3)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.directions_car,
                color: AppColors.accent,
                size: 24,
              ),
            ),
            title: Text(
              car.displayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${car.brand} ${car.model} (${car.year})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
            onTap: () => _onCarSelected(car),
          ),
        );
      },
    );
  }

}