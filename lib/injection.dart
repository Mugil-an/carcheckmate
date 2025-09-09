import 'package:get_it/get_it.dart';
import 'data/services/firebase_auth_service.dart';
import 'data/repositories/auth_repository.dart';
import 'logic/auth/auth_bloc.dart';

final sl = GetIt.instance;

void init() {
  // Services
  sl.registerLazySingleton(() => FirebaseAuthService());

  // Repository
  sl.registerLazySingleton(() => AuthRepository(sl()));

  // Bloc
  sl.registerFactory(() => AuthBloc(sl()));
}
