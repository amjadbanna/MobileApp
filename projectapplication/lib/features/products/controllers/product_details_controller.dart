import 'package:flutter/material.dart';

class ProductDetailsController extends ChangeNotifier {
  String? _selectedSize;
  int _quantity = 1;
  bool _isFavorite = false;

  String? get selectedSize => _selectedSize;
  int get quantity => _quantity;
  bool get isFavorite => _isFavorite;

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

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  bool validateSelection() {
    return _selectedSize != null;
  }

  void initializeFavorite(bool value) {
    _isFavorite = value;
  }
}