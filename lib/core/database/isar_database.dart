import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/products/data/models/product_model.dart';
import '../../features/pos/data/models/order_model.dart';

class IsarDatabase {
  late Isar _isar;

  Isar get isar => _isar;

  Future<void> init() async {
    // Reuse already-open instance on hot-restart
    final existing = Isar.getInstance();
    if (existing != null) {
      _isar = existing;
      return;
    }

    final dir = await getApplicationDocumentsDirectory();

    try {
      _isar = await Isar.open(
        [ProductModelSchema, OrderModelSchema],
        directory: dir.path,
        inspector: false,
      );
      debugPrint('Isar opened at: ${dir.path}');
    } catch (e) {
      // Schema mismatch (e.g. after build_runner regenerated IDs) —
      // wipe the stale database file and open fresh.
      debugPrint('Isar open failed ($e) — wiping stale DB and retrying.');
      await _deleteIsarFiles(dir.path);
      _isar = await Isar.open(
        [ProductModelSchema, OrderModelSchema],
        directory: dir.path,
        inspector: false,
      );
      debugPrint('Isar reopened fresh at: ${dir.path}');
    }
  }

  Future<void> _deleteIsarFiles(String dirPath) async {
    final dir = Directory(dirPath);
    final files = dir.listSync();
    for (final f in files) {
      if (f.path.endsWith('.isar') || f.path.endsWith('.isar.lock')) {
        try {
          await File(f.path).delete();
          debugPrint('Deleted: ${f.path}');
        } catch (_) {}
      }
    }
  }
}
