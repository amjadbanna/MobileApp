import 'package:flutter/material.dart';
import 'package:projectapplication/controllers/cart_service.dart';
import 'package:projectapplication/controllers/wishlist_service.dart';
import 'package:projectapplication/models/product_model.dart';

class ProductDetailsController extends ChangeNotifier {
  final ProductModel product;

  ProductDetailsController({required this.product}) {
    // Check wishlist so the heart icon shows correctly when the screen opens
    _isFavorite = WishlistService.instance.isInWishlist(product.id);
  }

  // Size and quantity fields
  String? _selectedSize;
  int _quantity = 1;

  String? get selectedSize => _selectedSize;
  int get quantity => _quantity;

  void selectSize(String size) {
    _selectedSize = size;
    notifyListeners();
  }

  void increaseQuantity() {
    _quantity++;
    notifyListeners();
  }

  void decreaseQuantity() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }

  bool validateSelection() => _selectedSize != null;

  // Wishlist fields
  bool _isFavorite = false;

  bool get isFavorite => _isFavorite;

  void toggleFavorite() {
    WishlistService.instance.toggleWishlist(product);
    _isFavorite = WishlistService.instance.isInWishlist(product.id);
    notifyListeners();
  }

  // Cart methods

  // Returns true and adds to cart. Returns false if no size was selected.
  bool addToCart() {
    if (_selectedSize == null) return false;
    CartService.instance.addToCart(product, _selectedSize!, _quantity);
    return true;
  }
}
