import 'package:flutter/material.dart';
import 'package:grow/injection_container.dart' as di;
import 'package:grow/features/pos/presentation/pages/pos_page.dart';
import 'package:grow/features/products/domain/entities/product.dart';
import 'package:grow/features/products/domain/repositories/product_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  // Seed data for testing if no products exist
  final productRepo = di.sl<ProductRepository>();
  final products = await productRepo.getAllProducts();
  if (products.isEmpty) {
    await productRepo.addProduct(const Product(
      name: 'Test Product 1',
      barcode: '123456',
      price: 10,
      stock: 100,
    ));
    await productRepo.addProduct(const Product(
      name: 'Test Product 2',
      barcode: '789012',
      price: 20,
      stock: 50,
    ));
    print('Seed data added.');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retail POS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const POSPage(),
    );
  }
}
