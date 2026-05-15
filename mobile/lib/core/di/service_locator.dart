import 'package:get_it/get_it.dart';

import '../api/dio_client.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_repository.dart';
import '../auth/token_storage.dart';

final GetIt sl = GetIt.instance;

/// Wire-up minimal des dépendances globales.
/// Les blocs/cubits de feature seront instanciés à la demande dans les pages.
void setupServiceLocator() {
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<DioClient>(
    () => DioClient.create(tokenStorage: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(client: sl(), storage: sl()),
  );
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(repository: sl())..add(const AuthBootstrapRequested()),
  );
}
