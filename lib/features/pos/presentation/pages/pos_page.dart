import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';
import '../bloc/pos_state.dart';
import 'package:grow/injection_container.dart';
import 'package:grow/core/utils/bluetooth_printer_service.dart';
import 'package:grow/features/pos/domain/entities/order.dart';
import 'package:grow/features/products/domain/entities/product.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  final MobileScannerController scannerController = MobileScannerController();
  BluetoothDevice? selectedDevice;
  final BluetoothPrinterService printerService = sl<BluetoothPrinterService>();
  late final POSBloc _posBloc;
  String? lastScannedBarcode;
  DateTime? lastScanTime;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    _posBloc = sl<POSBloc>();
    _getBluetoothDevices();
  }

  @override
  void dispose() {
    scannerController.dispose();
    _posBloc.close();
    super.dispose();
  }

  Future<void> _getBluetoothDevices() async {
    final devices = await printerService.getDevices();
    if (devices.isNotEmpty) {
      setState(() => selectedDevice = devices.first);
    }
  }

  void _onBarcodeDetected(String code) {
    if (_sheetOpen) { return; }
    final now = DateTime.now();
    if (code == lastScannedBarcode &&
        lastScanTime != null &&
        now.difference(lastScanTime!).inMilliseconds < 2000) return;
    lastScannedBarcode = code;
    lastScanTime = now;
    _posBloc.add(ScanBarcode(code));
  }

  void _showProductSheet(BuildContext context, Product product) {
    _sheetOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductDetailSheet(
        product: product,
        onAddToCart: () {
          Navigator.pop(context);
          _posBloc.add(AddProductToOrder(product));
        },
        onCancel: () {
          Navigator.pop(context);
          _posBloc.add(DismissScannedProduct());
        },
      ),
    ).whenComplete(() {
      _sheetOpen = false;
      lastScannedBarcode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _posBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('POS & Billing',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.keyboard_alt_outlined),
              tooltip: 'Manual Entry',
              onPressed: _showManualEntryDialog,
            ),
            IconButton(
              icon: const Icon(Icons.bluetooth),
              tooltip: 'Select Printer',
              onPressed: _showPrinterSelection,
            ),
          ],
        ),
        body: BlocConsumer<POSBloc, POSState>(
          listener: (context, state) {
            if (state.status == POSStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Row(children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.errorMessage ?? 'Error')),
                ]),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ));
            } else if (state.status == POSStatus.productFound &&
                state.scannedProduct != null) {
              _showProductSheet(context, state.scannedProduct!);
            } else if (state.status == POSStatus.checkoutSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Row(children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Checkout successful!'),
                ]),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ));
              _printReceipt(context, state);
              _posBloc.add(ResetPOS());
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // ── Scanner section ──────────────────────────────────
                _ScannerSection(
                  controller: scannerController,
                  isLoading: state.status == POSStatus.loading,
                  onDetect: _onBarcodeDetected,
                ),

                // ── Cart section ─────────────────────────────────────
                Expanded(
                  child: state.currentItems.isEmpty
                      ? _EmptyCart()
                      : _CartSection(
                          state: state,
                          posBloc: _posBloc,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Barcode Entry'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter barcode number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.qr_code),
          ),
          keyboardType: TextInputType.text,
          autofocus: true,
          onSubmitted: (v) {
            if (v.isNotEmpty) {
              _posBloc.add(ScanBarcode(v));
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('FIND PRODUCT'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green,
                foregroundColor: Colors.white),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _posBloc.add(ScanBarcode(controller.text));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showPrinterSelection() async {
    final devices = await printerService.getDevices();
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Bluetooth Printer'),
        content: SizedBox(
          width: double.maxFinite,
          child: devices.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No paired Bluetooth devices found.'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return ListTile(
                      leading: const Icon(Icons.print),
                      title: Text(device.name ?? 'Unknown Device'),
                      onTap: () async {
                        await printerService.connect(device);
                        setState(() => selectedDevice = device);
                        if (mounted) Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _printReceipt(BuildContext context, POSState state) async {
    if (selectedDevice == null) return;
    final order = OrderEntity(
      items: state.currentItems,
      dateTime: DateTime.now(),
      totalAmount: state.totalAmount,
    );
    try {
      await printerService.printReceipt(order);
    } catch (_) {}
  }
}

// ── Scanner widget ─────────────────────────────────────────────────────────────

class _ScannerSection extends StatelessWidget {
  final MobileScannerController controller;
  final bool isLoading;
  final void Function(String) onDetect;

  const _ScannerSection({
    required this.controller,
    required this.isLoading,
    required this.onDetect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final code = barcode.rawValue;
                if (code != null) onDetect(code);
              }
            },
          ),
          // Scan frame overlay
          Container(
            width: 220,
            height: 130,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent, width: 2.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.greenAccent))
                : null,
          ),
          // Controls row
          Positioned(
            bottom: 8,
            child: Row(
              children: [
                _ScannerButton(
                  icon: Icons.flash_on,
                  onTap: () => controller.toggleTorch(),
                ),
                const SizedBox(width: 24),
                _ScannerButton(
                  icon: Icons.flip_camera_ios,
                  onTap: () => controller.switchCamera(),
                ),
              ],
            ),
          ),
          // Label
          const Positioned(
            top: 10,
            child: Text(
              'Point camera at barcode or QR code',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

}

class _ScannerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ScannerButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}

// ── Empty cart placeholder ────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Scan a barcode to see product & price',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          const SizedBox(height: 6),
          Text('or use the keyboard icon for manual entry',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Cart section ─────────────────────────────────────────────────────────────

class _CartSection extends StatelessWidget {
  final POSState state;
  final POSBloc posBloc;
  const _CartSection({required this.state, required this.posBloc});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Item count header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.green.shade50,
          child: Row(
            children: [
              const Icon(Icons.shopping_cart_outlined,
                  size: 18, color: Colors.green),
              const SizedBox(width: 6),
              Text('${state.currentItems.length} item(s) in cart',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.green)),
            ],
          ),
        ),
        // Items list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            itemCount: state.currentItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final item = state.currentItems[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      // Quantity badge
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name & unit price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('₹${item.price.toStringAsFixed(2)} each',
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      // Total for this line
                      Text('₹${item.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green)),
                      const SizedBox(width: 4),
                      // Qty controls
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QtyButton(
                            icon: Icons.remove,
                            color: Colors.red.shade400,
                            onTap: () => posBloc.add(UpdateItemQuantity(
                                item.product, item.quantity - 1)),
                          ),
                          const SizedBox(width: 4),
                          _QtyButton(
                            icon: Icons.add,
                            color: Colors.green,
                            onTap: () => posBloc.add(UpdateItemQuantity(
                                item.product, item.quantity + 1)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Checkout bar
        _CheckoutBar(state: state, posBloc: posBloc),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QtyButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final POSState state;
  final POSBloc posBloc;
  const _CheckoutBar({required this.state, required this.posBloc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text(
                '₹${state.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: state.status == POSStatus.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('PROCEED TO CHECKOUT',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: state.status == POSStatus.loading
                  ? null
                  : () => posBloc.add(Checkout()),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product detail bottom sheet ───────────────────────────────────────────────

class _ProductDetailSheet extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onCancel;

  const _ProductDetailSheet({
    required this.product,
    required this.onAddToCart,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: Colors.green, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Barcode: ${product.barcode}',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Price — prominent display
          Center(
            child: Column(
              children: [
                Text('PRICE', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(
                  '₹${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Details grid
          Row(
            children: [
              Expanded(
                  child: _DetailChip(
                      icon: Icons.inventory,
                      label: 'Stock',
                      value: '${product.stock} units')),
              if (product.category != null && product.category!.isNotEmpty)
                Expanded(
                    child: _DetailChip(
                        icon: Icons.category,
                        label: 'Category',
                        value: product.category!)),
            ],
          ),

          if (product.description != null && product.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(product.description!,
                  style:
                      TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            ),
          ],

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('CANCEL',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('ADD TO CART',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: onAddToCart,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.green),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.5)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
