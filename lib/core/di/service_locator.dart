// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/risk_calculator_service.dart';
import '../../core/services/http_client.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/datasources/firebase_checklist_datasource.dart';
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


final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Services first
  sl.registerLazySingleton(() => FirebaseAuthService());
  sl.registerLazySingleton(() => RiskCalculatorService());
  sl.registerLazySingleton(() => HttpClient());

  // Firebase instance
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Data sources
  sl.registerLazySingleton<FirebaseChecklistDataSource>(() => FirebaseChecklistDataSourceImpl(sl()));
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

  // Note: Cars are now loaded dynamically from Firebase via ChecklistRepository
}