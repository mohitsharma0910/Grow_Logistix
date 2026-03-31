import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';
import '../../../products/domain/entities/product.dart';

abstract class POSEvent extends Equatable {
  const POSEvent();

  @override
  List<Object?> get props => [];
}

class ScanBarcode extends POSEvent {
  final String barcode;
  const ScanBarcode(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class AddProductToOrder extends POSEvent {
  final Product product;
  const AddProductToOrder(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateItemQuantity extends POSEvent {
  final Product product;
  final int quantity;
  const UpdateItemQuantity(this.product, this.quantity);

  @override
  List<Object?> get props => [product, quantity];
}

class Checkout extends POSEvent {}

class ResetPOS extends POSEvent {}
