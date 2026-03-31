import 'package:isar/isar.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@collection
class ProductModel {
  Id id = Isar.autoIncrement;
  late String name;
  @Index(unique: true)
  late String barcode;
  late double price;
  late int stock;
  String? description;
  String? category;

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      stock: stock,
      description: description,
      category: category,
    );
  }

  static ProductModel fromEntity(Product product) {
    final model = ProductModel();
    if (product.id != null) {
      model.id = product.id!;
    }
    model.name = product.name;
    model.barcode = product.barcode;
    model.price = product.price;
    model.stock = product.stock;
    model.description = product.description;
    model.category = product.category;
    return model;
  }
}
