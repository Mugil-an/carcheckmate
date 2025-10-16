part of 'checklist_bloc.dart';

abstract class ChecklistEvent extends Equatable {
  const ChecklistEvent();

  @override
  List<Object?> get props => [];
}

class LoadCarList extends ChecklistEvent {
  const LoadCarList();
}

class CarSelected extends ChecklistEvent {
  final CarSummary carSummary;

  const CarSelected(this.carSummary);

  @override
  List<Object?> get props => [carSummary];
}

class ToggleChecklistItem extends ChecklistEvent {
  final String issue;
  final bool selected;

  const ToggleChecklistItem({required this.issue, required this.selected});

  @override
  List<Object?> get props => [issue, selected];
}