import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:projectapplication/models/product_model.dart';

class LocalProductService {
  Future<List<ProductModel>> loadProducts() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/products.json');

    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> productsJson = jsonData['products'] as List<dynamic>;

    return productsJson
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
