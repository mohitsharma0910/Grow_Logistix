import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/products/data/models/product_model.dart';
import '../../features/pos/data/models/order_model.dart';

class IsarDatabase {
  late Isar _isar;

  Isar get isar => _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [ProductModelSchema, OrderModelSchema],
      directory: dir.path,
    );
  }
}
