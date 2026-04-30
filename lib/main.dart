import 'package:flutter/material.dart';
import 'package:grow/injection_container.dart' as di;
import 'package:grow/features/auth/presentation/login_page.dart';
import 'package:grow/features/products/domain/entities/product.dart';
import 'package:grow/features/products/domain/repositories/product_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppInitializer());
}

Future<void> _seedInitialData() async {
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
  }
}

// ── Splash / init wrapper ─────────────────────────────────────────────────────

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    await di.init();
    await _seedInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grow Logistix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorScreen(error: snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return const LoginPage();
          }
          return const _SplashScreen();
        },
      ),
    );
  }
}

// ── Splash screen ─────────────────────────────────────────────────────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping, size: 80, color: Colors.green),
            SizedBox(height: 24),
            Text(
              'GROW LOGISTIX',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text('Starting up…',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ── Error screen (shows the real init error) ──────────────────────────────────

class _ErrorScreen extends StatelessWidget {
  final String error;
  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    // Also dump to console so it's visible in Android Studio logs
    debugPrint('=== INIT ERROR ===\n$error\n=================');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 12),
              const Text(
                'Initialization Failed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share the error below with your developer:',
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      error,
                      style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 12,
                          fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Try: Settings → Apps → grow → Clear Data,\nthen restart the app.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
