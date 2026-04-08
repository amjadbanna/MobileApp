import 'package:flutter/material.dart';
import '../../features/products/models/product_model.dart';
import '../models/cart_item.dart';

// Global singleton for cart state. Screens call addListener() to rebuild on changes.
class CartService extends ChangeNotifier {
  // Singleton instance
  static final CartService instance = CartService._internal();
  CartService._internal();

  // Internal list of cart items
  final List<CartItem> _items = [];

  // Returns a read-only copy of the cart items
  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Check if a product is already in the cart
  bool isInCart(int productId) =>
      _items.any((item) => item.product.id == productId);

  // Add item to cart — if same product+size exists, just increase its quantity
  void addToCart(ProductModel product, String selectedSize, int quantity) {
    final index = _items.indexWhere(
      (item) =>
          item.product.id == product.id && item.selectedSize == selectedSize,
    );

    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product,
          selectedSize: selectedSize,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void increaseQuantity(String itemKey) {
    final index = _items.indexWhere((item) => item.key == itemKey);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String itemKey) {
    final index = _items.indexWhere((item) => item.key == itemKey);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(String itemKey) {
    _items.removeWhere((item) => item.key == itemKey);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
