import 'package:equatable/equatable.dart';
import '../../products/domain/entities/product.dart';

class OrderItem extends Equatable {
  final Product product;
  final int quantity;
  final double price;

  const OrderItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  double get total => price * quantity;

  OrderItem copyWith({
    Product? product,
    int? quantity,
    double? price,
  }) {
    return OrderItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  @override
  List<Object?> get props => [product, quantity, price];
}

class OrderEntity extends Equatable {
  final int? id;
  final List<OrderItem> items;
  final DateTime dateTime;
  final double totalAmount;

  const OrderEntity({
    this.id,
    required this.items,
    required this.dateTime,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [id, items, dateTime, totalAmount];
}
