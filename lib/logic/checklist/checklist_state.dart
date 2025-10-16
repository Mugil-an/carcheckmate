part of 'checklist_bloc.dart';

enum ChecklistStatus { initial, loading, loaded, error }

class ChecklistState extends Equatable {
  final ChecklistStatus status;
  final List<CarSummary> carList;
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
    List<CarSummary>? carList,
    Car? selectedCar,
    bool resetSelectedCar = false,
    List<ChecklistItem>? checklistItems,
    bool resetChecklistItems = false,
    Map<String, bool>? itemSelections,
    bool resetItemSelections = false,
    double? riskScore,
    String? errorMessage,
    bool resetErrorMessage = false,
  }) {
    return ChecklistState(
      status: status ?? this.status,
      carList: carList ?? this.carList,
      selectedCar: resetSelectedCar ? null : (selectedCar ?? this.selectedCar),
      checklistItems: resetChecklistItems ? const [] : (checklistItems ?? this.checklistItems),
      itemSelections: resetItemSelections ? const {} : (itemSelections ?? this.itemSelections),
      riskScore: riskScore ?? this.riskScore,
      errorMessage: resetErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, carList, selectedCar, checklistItems, itemSelections, riskScore, errorMessage];
}
