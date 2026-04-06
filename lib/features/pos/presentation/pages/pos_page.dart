import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';
import '../bloc/pos_state.dart';
import 'package:grow/injection_container.dart';
import 'package:grow/core/utils/bluetooth_printer_service.dart';
import 'package:grow/features/pos/domain/entities/order.dart';
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
      setState(() {
        selectedDevice = devices.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _posBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('POS & Billing'),
          actions: [
            IconButton(
              icon: const Icon(Icons.keyboard),
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
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MobileScanner(
                    controller: scannerController,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      final now = DateTime.now();
                      for (final barcode in barcodes) {
                        final code = barcode.rawValue;
                        if (code != null) {
                          // Debounce: prevent scanning same barcode within 1.5 seconds
                          if (code == lastScannedBarcode && 
                              lastScanTime != null && 
                              now.difference(lastScanTime!).inMilliseconds < 1500) {
                            continue;
                          }
                          lastScannedBarcode = code;
                          lastScanTime = now;
                          _posBloc.add(ScanBarcode(code));
                        }
                      }
                    },
                  ),
                  Container(
                    width: 250,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          color: Colors.white,
                          icon: const Icon(Icons.flash_on),
                          iconSize: 32.0,
                          onPressed: () => scannerController.toggleTorch(),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          color: Colors.white,
                          icon: const Icon(Icons.flip_camera_ios),
                          iconSize: 32.0,
                          onPressed: () => scannerController.switchCamera(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: BlocConsumer<POSBloc, POSState>(
                listener: (context, state) {
                  if (state.status == POSStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage ?? 'Error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state.status == POSStatus.checkoutSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checkout successful!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _printReceipt(context, state);
                    _posBloc.add(ResetPOS());
                  }
                },
                builder: (context, state) {
                  if (state.currentItems.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Scan a product barcode to start', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: state.currentItems.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = state.currentItems[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(item.quantity.toString()),
                              ),
                              title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Price: \$${item.price.toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('\$${item.total.toStringAsFixed(2)}', 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                    onPressed: () {
                                      _posBloc.add(UpdateItemQuantity(item.product, item.quantity - 1));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                    onPressed: () {
                                      _posBloc.add(UpdateItemQuantity(item.product, item.quantity + 1));
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(
                                  '\$${state.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: state.status == POSStatus.loading 
                                  ? null 
                                  : () => _posBloc.add(Checkout()),
                                child: state.status == POSStatus.loading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('PROCEED TO CHECKOUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrinterSelection() async {
    final devices = await printerService.getDevices();
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Printer'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device.name ?? 'Unknown Device'),
                  onTap: () async {
                    await printerService.connect(device);
                    setState(() {
                      selectedDevice = device;
                    });
                    if (mounted) Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ),
      );
    }
  }

  Future<void> _printReceipt(BuildContext context, POSState state) async {
    if (selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No printer selected')),
      );
      return;
    }

    final order = OrderEntity(
      items: state.currentItems,
      dateTime: DateTime.now(),
      totalAmount: state.totalAmount,
    );

    try {
      await printerService.printReceipt(order);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt printed!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Printing failed: $e')),
        );
      }
    }
  }

  void _showManualEntryDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Barcode Entry'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter barcode',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _posBloc.add(ScanBarcode(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('ADD PRODUCT'),
          ),
        ],
      ),
    );
  }
}
