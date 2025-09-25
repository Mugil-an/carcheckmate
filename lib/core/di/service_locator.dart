// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';

import '../../core/services/risk_calculator_service.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/datasources/local_checklist_datasource.dart';
import '../../data/repositories/checklist_repository_impl.dart';
import '../../data/repositories/auth_repository.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/checklist/checklist_bloc.dart';
import '../../domain/repositories/checklist_repository.dart';
import '../utils/json_parser.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Services first
  sl.registerLazySingleton(() => FirebaseAuthService());
  sl.registerLazySingleton(() => RiskCalculatorService());

  // Data sources
  sl.registerLazySingleton<LocalChecklistDataSource>(() => LocalChecklistDataSourceImpl());

  // Repositories (they depend on services / datasources)
  sl.registerLazySingleton(() => AuthRepository(sl()));
  sl.registerLazySingleton<ChecklistRepository>(() => ChecklistRepositoryImpl(sl()));

  // Blocs (factories for fresh instances)
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => ChecklistBloc(repository: sl(), riskService: sl()));

  // Load and register cars for selection
  final carsForSelection = await loadCarsForSelection();
  sl.registerSingleton(carsForSelection, instanceName: 'carsForSelection');
}