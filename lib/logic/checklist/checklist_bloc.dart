import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:carcheckmate/domain/entities/car.dart';
import 'package:carcheckmate/domain/repositories/checklist_repository.dart';
import 'package:carcheckmate/data/models/checklist_item.dart';
import 'package:carcheckmate/core/services/risk_calculator_service.dart';

part 'checklist_event.dart';
part 'checklist_state.dart';

class ChecklistBloc extends Bloc<ChecklistEvent, ChecklistState> {
  final ChecklistRepository _repository;
  final RiskCalculatorService _riskService;

  ChecklistBloc({
    required ChecklistRepository repository,
    required RiskCalculatorService riskService,
  })  : _repository = repository,
        _riskService = riskService,
        super(const ChecklistState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<CarSelected>(_onCarSelected);
    on<ToggleChecklistItem>(_onToggleChecklistItem);
  }

  Future<void> _onLoadInitialData(
      LoadInitialData event, Emitter<ChecklistState> emit) async {
    emit(state.copyWith(status: ChecklistStatus.loading));
    try {
      if (event.car == null) {
        final cars = await _repository.getCarList();
        emit(state.copyWith(status: ChecklistStatus.loaded, carList: cars));
      } else {
        final car = await _repository.getCarByModelDetails(event.car!['brand'], event.car!['model'], event.car!['year']);
        if (car != null) {
          final items = car.checklistItems;
          final Map<String, bool> selections = {
            for (var item in items) item.issue: false
          };
          final riskScore = _riskService.calculateScore(
            items: items,
            selections: selections,
          );
          emit(state.copyWith(
            status: ChecklistStatus.loaded,
            selectedCar: car,
            checklistItems: items,
            itemSelections: selections,
            riskScore: riskScore,
          ));
        } else {
          emit(state.copyWith(
            status: ChecklistStatus.error,
            errorMessage: 'Failed to load checklist for this car',
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        status: ChecklistStatus.error,
        errorMessage: 'Failed to load car list',
      ));
    }
  }

  void _onCarSelected(CarSelected event, Emitter<ChecklistState> emit) {
    emit(state.copyWith(
      status: ChecklistStatus.loading,
      selectedCar: event.selectedCar,
      checklistItems: [],
      itemSelections: {},
      riskScore: 0.0,
    ));

    try {
      final items = event.selectedCar.checklistItems;

      final Map<String, bool> selections = {
        for (var item in items) item.issue: false
      };

      final riskScore = _riskService.calculateScore(
        items: items,
        selections: selections,
      );

      emit(state.copyWith(
        status: ChecklistStatus.loaded,
        checklistItems: items,
        itemSelections: selections,
        riskScore: riskScore,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChecklistStatus.error,
        errorMessage: 'Failed to load checklist for this car',
      ));
    }
  }

  void _onToggleChecklistItem(
      ToggleChecklistItem event, Emitter<ChecklistState> emit) {
    final newSelections = Map<String, bool>.from(state.itemSelections);
    newSelections[event.issue] = event.selected;

    final newScore = _riskService.calculateScore(
      items: state.checklistItems,
      selections: newSelections,
    );

    emit(state.copyWith(
      itemSelections: newSelections,
      riskScore: newScore,
    ));
  }
}