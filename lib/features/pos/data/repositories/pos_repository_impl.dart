import 'package:isar/isar.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/pos_repository.dart';
import '../models/order_model.dart';

class POSRepositoryImpl implements POSRepository {
  final Isar isar;

  POSRepositoryImpl(this.isar);

  @override
  Future<void> saveOrder(OrderEntity order) async {
    await isar.writeTxn(() async {
      await isar.orderModels.put(OrderModel.fromEntity(order));
    });
  }

  @override
  Future<List<OrderEntity>> getAllOrders() async {
    final models = await isar.orderModels.where().findAll();
    return models.map((e) => e.toEntity()).toList();
  }
}
