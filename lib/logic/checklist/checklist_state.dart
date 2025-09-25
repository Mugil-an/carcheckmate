part of 'checklist_bloc.dart';

enum ChecklistStatus { initial, loading, loaded, error }

class ChecklistState extends Equatable {
  final ChecklistStatus status;
  final List<Car> carList;
  final Car? selectedCar;
  final List<ChecklistItem> checklistItems;
  final Map<String, bool> itemSelections;
  final double riskScore;
  final String? errorMessage;

  const ChecklistState({
    this.status = ChecklistStatus.initial,
    this.carList = const [],
    this.selectedCar,
    this.checklistItems = const [],
    this.itemSelections = const {},
    this.riskScore = 100.0,
    this.errorMessage,
  });

  ChecklistState copyWith({
    ChecklistStatus? status,
    List<Car>? carList,
    Car? selectedCar,
    List<ChecklistItem>? checklistItems,
    Map<String, bool>? itemSelections,
    double? riskScore,
    String? errorMessage,
  }) {
    return ChecklistState(
      status: status ?? this.status,
      carList: carList ?? this.carList,
      selectedCar: selectedCar ?? this.selectedCar,
      checklistItems: checklistItems ?? this.checklistItems,
      itemSelections: itemSelections ?? this.itemSelections,
      riskScore: riskScore ?? this.riskScore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, carList, selectedCar, checklistItems, itemSelections, riskScore, errorMessage];
}
