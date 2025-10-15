import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:carcheckmate/domain/entities/car.dart';
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
        // Empty car list is acceptable - user can use migration screen to populate data
        emit(state.copyWith(status: ChecklistStatus.loaded, carList: cars));
      } else {
        final carData = event.car!;
        
        // Validate car data
        if (!carData.containsKey('brand') || !carData.containsKey('model') || !carData.containsKey('year')) {
          throw const InvalidCarSelectionException();
        }

        final car = await _repository.getCarByModelDetails(
          carData['brand'],
          carData['model'],
          carData['year'],
        );
        if (car != null) {
          final items = car.checklistItems;
          if (items.isEmpty) {
            throw const ChecklistDataNotFoundException();
          }
          
          final Map<String, bool> selections = {
            for (var item in items) item.issue: false // Start with all items unchecked (no problems)
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
          throw const CarDataNotFoundException();
        }
      }
    } on ChecklistException catch (e) {
      emit(state.copyWith(
        status: ChecklistStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChecklistStatus.error,
        errorMessage: const GenericChecklistException().message,
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
        checklistItems: items,
        itemSelections: selections,
        riskScore: riskScore,
      ));
    } on ChecklistException catch (e) {
      emit(state.copyWith(
        status: ChecklistStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
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