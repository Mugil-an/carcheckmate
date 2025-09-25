// lib/domain/entities/car.dart
import 'package:equatable/equatable.dart';
import 'package:carcheckmate/data/models/checklist_item.dart' as model;

class Car extends Equatable {
  final String id;
  final String displayName;
  final List<model.ChecklistItem> checklistItems;

  const Car({
    required this.id,
    required this.displayName,
    required this.checklistItems,
  });

  @override
  List<Object?> get props => [id, displayName, checklistItems];
}
