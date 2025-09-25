part of 'checklist_bloc.dart';

abstract class ChecklistEvent extends Equatable {
  const ChecklistEvent();

  @override
  List<Object?> get props => [];
}

class LoadInitialData extends ChecklistEvent {
  final Map<String, dynamic>? car;

  const LoadInitialData({this.car});

  @override
  List<Object?> get props => [car];
}

class CarSelected extends ChecklistEvent {
  final Car selectedCar;

  const CarSelected(this.selectedCar);

  @override
  List<Object?> get props => [selectedCar];
}

class ToggleChecklistItem extends ChecklistEvent {
  final String issue;
  final bool selected;

  const ToggleChecklistItem({required this.issue, required this.selected});

  @override
  List<Object?> get props => [issue, selected];
}