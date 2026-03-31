import 'package:isar/isar.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final Isar isar;

  ProductRepositoryImpl(this.isar);

  @override
  Future<List<Product>> getAllProducts() async {
    final models = await isar.productModels.where().findAll();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final model = await isar.productModels.where().barcodeEqualTo(barcode).findFirst();
    return model?.toEntity();
  }

  @override
  Future<void> addProduct(Product product) async {
    await isar.writeTxn(() async {
      await isar.productModels.put(ProductModel.fromEntity(product));
    });
  }

  @override
  Future<void> updateProduct(Product product) async {
    await isar.writeTxn(() async {
      await isar.productModels.put(ProductModel.fromEntity(product));
    });
  }

  @override
  Future<void> deleteProduct(int id) async {
    await isar.writeTxn(() async {
      await isar.productModels.delete(id);
    });
  }
}
