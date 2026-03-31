import 'package:isar/isar.dart';
import '../../domain/entities/order.dart';
import '../../../products/domain/entities/product.dart';

part 'order_model.g.dart';

@collection
class OrderModel {
  Id id = Isar.autoIncrement;
  late List<OrderItemModel> items;
  late DateTime dateTime;
  late double totalAmount;

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      items: items.map((e) => e.toEntity()).toList(),
      dateTime: dateTime,
      totalAmount: totalAmount,
    );
  }

  static OrderModel fromEntity(OrderEntity order) {
    final model = OrderModel();
    if (order.id != null) {
      model.id = order.id!;
    }
    model.items = order.items.map((e) => OrderItemModel.fromEntity(e)).toList();
    model.dateTime = order.dateTime;
    model.totalAmount = order.totalAmount;
    return model;
  }
}

@embedded
class OrderItemModel {
  late String productName;
  late String productBarcode;
  late int quantity;
  late double price;

  OrderItem toEntity() {
    return OrderItem(
      product: Product(
        name: productName,
        barcode: productBarcode,
        price: price,
        stock: 0, // Stock is not relevant for order history
      ),
      quantity: quantity,
      price: price,
    );
  }

  static OrderItemModel fromEntity(OrderItem item) {
    final model = OrderItemModel();
    model.productName = item.product.name;
    model.productBarcode = item.product.barcode;
    model.quantity = item.quantity;
    model.price = item.price;
    return model;
  }
}
