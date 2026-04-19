import 'package:flutter/foundation.dart';
import '../../features/products/models/product_model.dart';
import 'database_helper.dart';
import 'local_product_service.dart';

class ProductCatalogService {
  ProductCatalogService._internal();

  static final ProductCatalogService instance = ProductCatalogService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final LocalProductService _localProductService = LocalProductService();

  Future<void> warmUp() async {
    if (kIsWeb) {
      debugPrint('ProductCatalogService: web detected, skipping SQLite warm-up.');
      return;
    }

    try {
      await _databaseHelper.database;
      debugPrint('ProductCatalogService: SQLite warm-up completed.');
    } catch (error) {
      debugPrint('ProductCatalogService: SQLite warm-up failed: $error');
    }
  }

  Future<List<ProductModel>> loadProducts() async {
    if (kIsWeb) {
      return _loadJsonFallback('web platform');
    }

    try {
      final products = await _databaseHelper.getAllProducts();
      if (products.isNotEmpty) {
        debugPrint('ProductCatalogService: loaded products from SQLite.');
        return products;
      }

      debugPrint(
        'ProductCatalogService: SQLite returned no products, using JSON fallback.',
      );
    } catch (error) {
      debugPrint('ProductCatalogService: initial SQLite load failed: $error');

      try {
        await _databaseHelper.rebuildDatabase();
        final rebuiltProducts = await _databaseHelper.getAllProducts();
        if (rebuiltProducts.isNotEmpty) {
          debugPrint(
            'ProductCatalogService: loaded products from SQLite after rebuild.',
          );
          return rebuiltProducts;
        }

        debugPrint(
          'ProductCatalogService: SQLite rebuild succeeded but no products were returned.',
        );
      } catch (rebuildError) {
        debugPrint(
          'ProductCatalogService: SQLite rebuild/retry failed: $rebuildError',
        );
      }
    }

    return _loadJsonFallback('database unavailable');
  }

  Future<List<ProductModel>> _loadJsonFallback(String reason) async {
    final products = await _localProductService.loadProducts();
    debugPrint(
      'ProductCatalogService: loaded products from JSON fallback ($reason).',
    );
    return products;
  }
}
