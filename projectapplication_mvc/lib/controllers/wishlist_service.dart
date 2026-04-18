import 'package:flutter/material.dart';
import 'package:projectapplication/models/product_model.dart';

// Global singleton for wishlist state. Screens call addListener() to rebuild on changes.
class WishlistService extends ChangeNotifier {
  // Singleton instance
  static final WishlistService instance = WishlistService._internal();
  WishlistService._internal();

  // Internal list of wishlisted products
  final List<ProductModel> _items = [];

  // Returns a read-only copy of the wishlist
  List<ProductModel> get items => List.unmodifiable(_items);

  // Check if a product is already in the wishlist
  bool isInWishlist(int productId) =>
      _items.any((p) => p.id == productId);

  // Add if not in wishlist, remove if it is — used by the heart buttons
  void toggleWishlist(ProductModel product) {
    if (isInWishlist(product.id)) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }

  void removeFromWishlist(int productId) {
    _items.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void clearWishlist() {
    _items.clear();
    notifyListeners();
  }
}
