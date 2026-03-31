import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../../features/pos/domain/entities/order.dart';
import 'package:intl/intl.dart';

class BluetoothPrinterService {
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getDevices() async {
    return await _printer.getBondedDevices();
  }

  Future<void> connect(BluetoothDevice device) async {
    if (await _printer.isConnected != true) {
      await _printer.connect(device);
    }
  }

  Future<void> disconnect() async {
    await _printer.disconnect();
  }

  Future<void> printReceipt(OrderEntity order) async {
    if (await _printer.isConnected != true) return;

    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formattedDate = formatter.format(order.dateTime);

    _printer.printNewLine();
    _printer.printCustom("RETAIL SHOP", 3, 1);
    _printer.printCustom("Address: 123 Main St", 1, 1);
    _printer.printCustom("Phone: 1234567890", 1, 1);
    _printer.printNewLine();
    _printer.printCustom("Receipt #: ${order.id ?? 'N/A'}", 1, 0);
    _printer.printCustom("Date: $formattedDate", 1, 0);
    _printer.printNewLine();
    _printer.printCustom("--------------------------------", 1, 1);
    _printer.printCustom("Item       Qty    Price   Total", 1, 1);
    _printer.printCustom("--------------------------------", 1, 1);

    for (var item in order.items) {
      String name = item.product.name;
      if (name.length > 10) name = name.substring(0, 10);
      _printer.printCustom(
          "${name.padRight(10)} ${item.quantity.toString().padRight(5)} ${item.price.toStringAsFixed(2).padRight(7)} ${item.total.toStringAsFixed(2)}",
          1,
          0);
    }

    _printer.printCustom("--------------------------------", 1, 1);
    _printer.printCustom("TOTAL: ${order.totalAmount.toStringAsFixed(2)}", 2, 2);
    _printer.printNewLine();
    _printer.printCustom("Thank you for shopping!", 1, 1);
    _printer.printNewLine();
    _printer.printNewLine();
    _printer.printNewLine();
    _printer.paperCut();
  }
}
