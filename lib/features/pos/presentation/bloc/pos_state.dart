import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';
import 'package:grow/features/products/domain/entities/product.dart';

enum POSStatus { initial, loading, success, failure, checkoutSuccess, productFound }

class POSState extends Equatable {
  final POSStatus status;
  final List<OrderItem> currentItems;
  final double totalAmount;
  final String? errorMessage;
  final Product? scannedProduct;

  const POSState({
    this.status = POSStatus.initial,
    this.currentItems = const [],
    this.totalAmount = 0.0,
    this.errorMessage,
    this.scannedProduct,
  });

  POSState copyWith({
    POSStatus? status,
    List<OrderItem>? currentItems,
    double? totalAmount,
    String? errorMessage,
    Product? scannedProduct,
    bool clearScannedProduct = false,
  }) {
    return POSState(
      status: status ?? this.status,
      currentItems: currentItems ?? this.currentItems,
      totalAmount: totalAmount ?? this.totalAmount,
      errorMessage: errorMessage ?? this.errorMessage,
      scannedProduct: clearScannedProduct ? null : (scannedProduct ?? this.scannedProduct),
    );
  }

  @override
  List<Object?> get props => [status, currentItems, totalAmount, errorMessage, scannedProduct];
}
