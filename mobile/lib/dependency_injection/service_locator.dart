import 'package:get_it/get_it.dart';

import '../core/services/ble/ble_manager.dart';
import '../core/utils/logger.dart';

final GetIt di = GetIt.instance;

Future<void> configureDependencies() async {
  di.registerLazySingleton<AppLogger>(AppLogger.new);
  di.registerLazySingleton<BleManager>(() => BleManager(di<AppLogger>()));

  // TODO: Register API clients, secure storage, auth providers, etc.
}
