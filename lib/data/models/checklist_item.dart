// lib/data/models/checklist_item.dart
import 'package:equatable/equatable.dart';

class ChecklistItem extends Equatable {
  final String issue;
  final String severity;
  final int estimatedCost;

  const ChecklistItem({
    required this.issue,
    required this.severity,
    required this.estimatedCost,
  });

  @override
  List<Object?> get props => [issue, severity, estimatedCost];
}
