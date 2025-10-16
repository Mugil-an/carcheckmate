import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:carcheckmate/domain/entities/car.dart';
import 'package:carcheckmate/domain/entities/car_summary.dart';
import 'package:carcheckmate/domain/repositories/checklist_repository.dart';
import 'package:carcheckmate/data/models/checklist_item.dart';
import 'package:carcheckmate/core/services/risk_calculator_service.dart';
import '../../core/exceptions/checklist_exceptions.dart';

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
    on<LoadCarList>(_onLoadCarList);
    on<CarSelected>(_onCarSelected);
    on<ToggleChecklistItem>(_onToggleChecklistItem);
  }

  Future<void> _onLoadCarList(
      LoadCarList event, Emitter<ChecklistState> emit) async {
    emit(state.copyWith(
      status: ChecklistStatus.loading,
      resetSelectedCar: true,
      resetChecklistItems: true,
      resetItemSelections: true,
      riskScore: 100.0,
      resetErrorMessage: true,
    ));
    try {
      final cars = await _repository.getCarSummaries();
      emit(state.copyWith(
        status: ChecklistStatus.loaded,
        carList: cars,
        resetSelectedCar: true,
        resetChecklistItems: true,
        resetItemSelections: true,
        riskScore: 100.0,
      ));
    } on ChecklistException catch (e) {
      emit(state.copyWith(
        status: ChecklistStatus.error,
        errorMessage: e.message,
        resetSelectedCar: true,
        resetChecklistItems: true,
        resetItemSelections: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ChecklistStatus.error,
        errorMessage: const GenericChecklistException().message,
        resetSelectedCar: true,
        resetChecklistItems: true,
        resetItemSelections: true,
      ));
    }
  }

  Future<void> _onCarSelected(
      CarSelected event, Emitter<ChecklistState> emit) async {
    emit(state.copyWith(
      status: ChecklistStatus.loading,
      resetSelectedCar: true,
      resetChecklistItems: true,
      resetItemSelections: true,
      riskScore: 100.0,
      resetErrorMessage: true,
    ));

    try {
      final car = await _repository.getCarById(event.carSummary.id);

      if (car == null) {
        throw const CarDataNotFoundException();
      }

      final items = car.checklistItems;

      if (items.isEmpty) {
        throw const ChecklistDataNotFoundException();
      }

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
    } on ChecklistException catch (e) {
      emit(state.copyWith(
        status: ChecklistStatus.error,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ChecklistStatus.error,
        errorMessage: const CarSelectionException().message,
      ));
    }
  }

  void _onToggleChecklistItem(
      ToggleChecklistItem event, Emitter<ChecklistState> emit) {
    try {
      // Validate checklist item
      if (!state.itemSelections.containsKey(event.issue)) {
        throw const InvalidChecklistItemException();
      }

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
    } on ChecklistException catch (e) {
      emit(state.copyWith(
        status: ChecklistStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChecklistStatus.error,
        errorMessage: const RiskCalculationFailedException().message,
      ));
    }
  }
}