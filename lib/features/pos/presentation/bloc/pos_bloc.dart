import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../domain/repositories/pos_repository.dart';
import '../../domain/entities/order.dart';
import 'pos_event.dart';
import 'pos_state.dart';

class POSBloc extends Bloc<POSEvent, POSState> {
  final ProductRepository productRepository;
  final POSRepository posRepository;

  POSBloc({
    required this.productRepository,
    required this.posRepository,
  }) : super(const POSState()) {
    on<ScanBarcode>(_onScanBarcode);
    on<AddProductToOrder>(_onAddProductToOrder);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<Checkout>(_onCheckout);
    on<ResetPOS>(_onResetPOS);
  }

  Future<void> _onScanBarcode(ScanBarcode event, Emitter<POSState> emit) async {
    emit(state.copyWith(status: POSStatus.loading));
    try {
      final product = await productRepository.getProductByBarcode(event.barcode);
      if (product != null) {
        add(AddProductToOrder(product));
      } else {
        emit(state.copyWith(
          status: POSStatus.failure,
          errorMessage: 'Product not found for barcode: ${event.barcode}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(status: POSStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onAddProductToOrder(AddProductToOrder event, Emitter<POSState> emit) {
    final existingIndex = state.currentItems.indexWhere((item) => item.product.barcode == event.product.barcode);
    List<OrderItem> newItems;
    if (existingIndex != -1) {
      final existingItem = state.currentItems[existingIndex];
      newItems = List.from(state.currentItems);
      newItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
    } else {
      newItems = List.from(state.currentItems)..add(OrderItem(product: event.product, quantity: 1, price: event.product.price));
    }
    emit(state.copyWith(
      status: POSStatus.success,
      currentItems: newItems,
      totalAmount: _calculateTotal(newItems),
    ));
  }

  void _onUpdateItemQuantity(UpdateItemQuantity event, Emitter<POSState> emit) {
    final existingIndex = state.currentItems.indexWhere((item) => item.product.barcode == event.product.barcode);
    if (existingIndex != -1) {
      List<OrderItem> newItems = List.from(state.currentItems);
      if (event.quantity <= 0) {
        newItems.removeAt(existingIndex);
      } else {
        newItems[existingIndex] = newItems[existingIndex].copyWith(quantity: event.quantity);
      }
      emit(state.copyWith(
        status: POSStatus.success,
        currentItems: newItems,
        totalAmount: _calculateTotal(newItems),
      ));
    }
  }

  Future<void> _onCheckout(Checkout event, Emitter<POSState> emit) async {
    if (state.currentItems.isEmpty) return;
    emit(state.copyWith(status: POSStatus.loading));
    try {
      final order = OrderEntity(
        items: state.currentItems,
        dateTime: DateTime.now(),
        totalAmount: state.totalAmount,
      );
      await posRepository.saveOrder(order);
      emit(state.copyWith(status: POSStatus.checkoutSuccess));
    } catch (e) {
      emit(state.copyWith(status: POSStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onResetPOS(ResetPOS event, Emitter<POSState> emit) {
    emit(const POSState());
  }

  double _calculateTotal(List<OrderItem> items) {
    return items.fold(0, (sum, item) => sum + item.total);
  }
}
