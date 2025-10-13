// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';

import '../../core/services/risk_calculator_service.dart';
import '../../core/services/http_client.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/datasources/local_checklist_datasource.dart';
import '../../data/datasources/vehicle_remote_data_source.dart';
import '../../data/repositories/checklist_repository_impl.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../domain/repositories/checklist_repository.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/usecases/get_vehicle_details.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/checklist/checklist_bloc.dart';
import '../../logic/vehicle_verification/vehicle_verification_bloc.dart';
import '../utils/json_parser.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Services first
  sl.registerLazySingleton(() => FirebaseAuthService());
  sl.registerLazySingleton(() => RiskCalculatorService());
  sl.registerLazySingleton(() => HttpClient());

  // Data sources
  sl.registerLazySingleton<LocalChecklistDataSource>(() => LocalChecklistDataSourceImpl());
  sl.registerLazySingleton<VehicleRemoteDataSource>(() => VehicleRemoteDataSourceImpl(httpClient: sl()));

  // Repositories (they depend on services / datasources)
  sl.registerLazySingleton(() => AuthRepository(sl()));
  sl.registerLazySingleton<ChecklistRepository>(() => ChecklistRepositoryImpl(sl()));
  sl.registerLazySingleton<VehicleRepository>(() => VehicleRepositoryImpl(remoteDataSource: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetVehicleDetailsUseCase(sl()));

  // Blocs (factories for fresh instances)
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => ChecklistBloc(repository: sl(), riskService: sl()));
  sl.registerFactory(() => VehicleVerificationBloc(getVehicleDetailsUseCase: sl()));

  // Load and register cars for selection
  final carsForSelection = await loadCarsForSelection();
  sl.registerSingleton(carsForSelection, instanceName: 'carsForSelection');
}