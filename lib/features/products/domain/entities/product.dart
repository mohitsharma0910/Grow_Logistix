import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int? id;
  final String name;
  final String barcode;
  final double price;
  final int stock;
  final String? description;
  final String? category;

  const Product({
    this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stock,
    this.description,
    this.category,
  });

  Product copyWith({
    int? id,
    String? name,
    String? barcode,
    double? price,
    int? stock,
    String? description,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [id, name, barcode, price, stock, description, category];
}
