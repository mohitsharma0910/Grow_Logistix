import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';
import '../bloc/pos_state.dart';
import '../../../injection_container.dart';
import '../../../core/utils/bluetooth_printer_service.dart';
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

  @override
  void initState() {
    super.initState();
    _getBluetoothDevices();
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
    return BlocProvider(
      create: (context) => sl<POSBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('POS & Billing'),
          actions: [
            IconButton(
              icon: const Icon(Icons.bluetooth),
              onPressed: _showPrinterSelection,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: MobileScanner(
                controller: scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      context.read<POSBloc>().add(ScanBarcode(barcode.rawValue!));
                      // Optional: Vibrate or sound on success
                    }
                  }
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: BlocConsumer<POSBloc, POSState>(
                listener: (context, state) {
                  if (state.status == POSStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage ?? 'Error')),
                    );
                  } else if (state.status == POSStatus.checkoutSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checkout successful!')),
                    );
                    _printReceipt(context, state);
                    context.read<POSBloc>().add(ResetPOS());
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.currentItems.length,
                          itemBuilder: (context, index) {
                            final item = state.currentItems[index];
                            return ListTile(
                              title: Text(item.product.name),
                              subtitle: Text('Qty: ${item.quantity} x \$${item.price.toStringAsFixed(2)}'),
                              trailing: Text('\$${item.total.toStringAsFixed(2)}'),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: \$${state.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                              onPressed: state.currentItems.isEmpty
                                  ? null
                                  : () => context.read<POSBloc>().add(Checkout()),
                              child: const Text('Checkout'),
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
}
