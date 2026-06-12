import 'package:get_it/get_it.dart';
import '../../database/app_database.dart';

final sl = GetIt.instance;

void setupLocator() {
  // Register AppDatabase as a singleton
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
}
