// lib/presentation/screens/admin/data_migration_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/admin_service.dart';
import '../../../data/datasources/firebase_checklist_datasource.dart';
import '../../../core/exceptions/admin_exceptions.dart';
import '../../widgets/common_background.dart';
import '../../../utilities/dialogs/error_dialog.dart';

class DataMigrationScreen extends StatefulWidget {
  const DataMigrationScreen({super.key});

  @override
  State<DataMigrationScreen> createState() => _DataMigrationScreenState();
}

class _DataMigrationScreenState extends State<DataMigrationScreen> {
  late final AdminService _adminService;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  
  // Issues list
  final List<TextEditingController> _issueControllers = [];
  final List<String> _severityValues = [];
  final List<TextEditingController> _costControllers = [];
  
  bool _isLoading = false;
  String _statusMessage = '';
  int _carCount = 0;
  bool _isAdmin = false;

    @override
  void initState() {
    super.initState();
    _adminService = AdminService(
      FirebaseAuth.instance,
      FirebaseChecklistDataSourceImpl(FirebaseFirestore.instance),
    );
    _checkAdminAccess();
    _loadCarCount();
    
    // Initialize with one empty issue field
    _addIssueField();
  }

  void _checkAdminAccess() {
    setState(() {
      _isAdmin = _adminService.isCurrentUserAdmin;
      if (!_isAdmin) {
        _statusMessage = 'Access denied. Only ${_adminService.currentUserEmail} can access admin features.';
      }
    });
  }

  Future<void> _loadCarCount() async {
    try {
      final count = await _adminService.getCarModelCount();
      setState(() {
        _carCount = count;
        if (_isAdmin) {
          _statusMessage = 'Database has $_carCount car models. Add new models below.';
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading car count: $e';
      });
    }
  }

  Future<void> _addCarModel() async {
    if (_formKey.currentState?.validate() != true) return;
    
    try {
      _adminService.validateAdminAccess();
      
      setState(() {
        _isLoading = true;
        _statusMessage = 'Adding car model...';
      });

      // Collect issues, severities, and costs
      final issues = _issueControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      
      final severities = _severityValues.take(issues.length).toList();
      
      final costs = _costControllers
          .take(issues.length)
          .map((controller) {
            final text = controller.text.trim();
            return text.isEmpty ? 0 : int.tryParse(text) ?? 0;
          })
          .toList();

      await _adminService.addCarModel(
        brand: _brandController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        issues: issues,
        severities: severities,
        estimatedCostsINR: costs,
      );

      setState(() {
        _isLoading = false;
        _statusMessage = 'Car model added successfully!';
      });

      _clearForm();
      await _loadCarCount();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car model added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Failed to add car model';
      if (e is AdminAccessDeniedException) {
        errorMessage = 'Access denied: ${e.message}';
      } else if (e is InvalidCarDataException) {
        errorMessage = 'Invalid data: ${e.message}';
      } else {
        errorMessage = 'Error: $e';
      }
      
      setState(() {
        _isLoading = false;
        _statusMessage = errorMessage;
      });

      if (mounted) {
        showErrorDialog(context, errorMessage);
      }
    }
  }

  void _clearForm() {
    _brandController.clear();
    _modelController.clear();
    _yearController.clear();
    
    // Clear issue controllers
    for (final controller in _issueControllers) {
      controller.dispose();
    }
    _issueControllers.clear();
    _severityValues.clear();
    for (final controller in _costControllers) {
      controller.dispose();
    }
    _costControllers.clear();
    
    // Add one default empty issue
    _addIssueField();
  }

  void _addIssueField() {
    setState(() {
      _issueControllers.add(TextEditingController());
      _severityValues.add('Low');
      _costControllers.add(TextEditingController());
    });
  }

  void _removeIssueField(int index) {
    if (_issueControllers.length > 1) {
      setState(() {
        _issueControllers[index].dispose();
        _costControllers[index].dispose();
        _issueControllers.removeAt(index);
        _severityValues.removeAt(index);
        _costControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Admin Panel'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Access Denied',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Admin Panel - Add Car Details'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Database Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            color: _carCount > 0 ? Colors.green : Colors.orange,
                          ),
                        ),
                        if (_isLoading) ...[
                          const SizedBox(height: 16),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Car Details Form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add New Car Model',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Brand Field
                        TextFormField(
                          controller: _brandController,
                          decoration: const InputDecoration(
                            labelText: 'Brand',
                            hintText: 'e.g., Toyota, Honda, BMW',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Brand is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Model Field
                        TextFormField(
                          controller: _modelController,
                          decoration: const InputDecoration(
                            labelText: 'Model',
                            hintText: 'e.g., Corolla, Civic, X3',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Model is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Year Field
                        TextFormField(
                          controller: _yearController,
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            hintText: '2020',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Year is required';
                            }
                            final year = int.tryParse(value);
                            if (year == null || year < 1900 || year > 2030) {
                              return 'Enter a valid year (1900-2030)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Issues Section
                        Row(
                          children: [
                            const Text(
                              'Common Issues',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _addIssueField,
                              icon: const Icon(Icons.add),
                              tooltip: 'Add Issue',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Issues List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _issueControllers.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text('Issue ${index + 1}'),
                                        const Spacer(),
                                        if (_issueControllers.length > 1)
                                          IconButton(
                                            onPressed: () => _removeIssueField(index),
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            iconSize: 20,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _issueControllers[index],
                                      decoration: const InputDecoration(
                                        labelText: 'Issue Description',
                                        hintText: 'e.g., Engine overheating',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Issue description is required';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            value: _severityValues[index],
                                            decoration: const InputDecoration(
                                              labelText: 'Severity',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                            items: ['Low', 'Medium', 'High', 'Critical']
                                                .map((severity) => DropdownMenuItem(
                                                      value: severity,
                                                      child: Text(severity),
                                                    ))
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _severityValues[index] = value!;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _costControllers[index],
                                            decoration: const InputDecoration(
                                              labelText: 'Estimated Cost (₹)',
                                              hintText: '5000',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value != null && value.trim().isNotEmpty) {
                                                final cost = int.tryParse(value);
                                                if (cost == null || cost < 0) {
                                                  return 'Enter valid cost';
                                                }
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _addCarModel,
                            icon: const Icon(Icons.add_circle),
                            label: const Text('Add Car Model'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    
    for (final controller in _issueControllers) {
      controller.dispose();
    }
    for (final controller in _costControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }
}