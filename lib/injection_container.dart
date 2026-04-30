import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'core/database/isar_database.dart';
import 'core/utils/bluetooth_printer_service.dart';
import 'features/pos/data/repositories/pos_repository_impl.dart';
import 'features/pos/domain/repositories/pos_repository.dart';
import 'features/pos/presentation/bloc/pos_bloc.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/domain/repositories/product_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Allow re-registration on hot-restart without throwing
  sl.allowReassignment = true;

  // Database
  final isarDatabase = IsarDatabase();
  await isarDatabase.init();
  sl.registerSingleton<Isar>(isarDatabase.isar);

  // Services
  sl.registerLazySingleton<BluetoothPrinterService>(
      () => BluetoothPrinterService());

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl()));
  sl.registerLazySingleton<POSRepository>(() => POSRepositoryImpl(sl()));

  // Blocs (factory so each page gets a fresh instance)
  sl.registerFactory(() => POSBloc(
        productRepository: sl(),
        posRepository: sl(),
      ));
}
