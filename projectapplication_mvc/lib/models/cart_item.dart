import 'package:projectapplication/models/product_model.dart';

class CartItem {
  final ProductModel product;
  final String selectedSize;
  int quantity;

  CartItem({
    required this.product,
    required this.selectedSize,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  String get key => '${product.id}_$selectedSize';
}
