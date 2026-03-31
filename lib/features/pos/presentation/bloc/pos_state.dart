import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';

enum POSStatus { initial, loading, success, failure, checkoutSuccess }

class POSState extends Equatable {
  final POSStatus status;
  final List<OrderItem> currentItems;
  final double totalAmount;
  final String? errorMessage;

  const POSState({
    this.status = POSStatus.initial,
    this.currentItems = const [],
    this.totalAmount = 0.0,
    this.errorMessage,
  });

  POSState copyWith({
    POSStatus? status,
    List<OrderItem>? currentItems,
    double? totalAmount,
    String? errorMessage,
  }) {
    return POSState(
      status: status ?? this.status,
      currentItems: currentItems ?? this.currentItems,
      totalAmount: totalAmount ?? this.totalAmount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, currentItems, totalAmount, errorMessage];
}
