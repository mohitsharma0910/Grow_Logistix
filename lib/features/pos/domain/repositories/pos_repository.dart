import '../entities/order.dart';

abstract class POSRepository {
  Future<void> saveOrder(OrderEntity order);
  Future<List<OrderEntity>> getAllOrders();
}
