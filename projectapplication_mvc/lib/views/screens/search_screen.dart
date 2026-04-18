import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projectapplication/controllers/database_helper.dart';
import 'package:projectapplication/models/product_model.dart';
import 'package:projectapplication/views/screens/product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  String _selectedCategory = 'All';
  String _selectedGender = 'All';
  String _selectedStyle = 'All';
  String _selectedPrice = 'All';
  bool _isLoading = true;
  bool _usingFallback = false;

  // Exact categories from products.json
  final List<String> _categories = [
    'All', 'Tops', 'Pants', 'Jackets', 'Coats',
    'Dresses', 'Outerwear', 'Footwear', 'Accessories',
  ];

  // Exact genders from products.json
  final List<String> _genders = ['All', 'Men', 'Women', 'Unisex'];

  // Exact styles from products.json
  final List<String> _styles = [
    'All', 'Streetwear', 'Casual', 'Formal', 'Modern', 'Basics', 'Techwear', 'Active', 'Classic',
  ];

  final List<String> _priceFilters = [
    'All', 'Under \$50', '\$50–\$100', 'Over \$100',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Load strategy:
  //   1. Try SQLite first (fast, offline)
  //   2. If SQLite fails → fall back to reading products.json directly
  //   3. UI always shows something — never blank
  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    // Step 1: Try SQLite
    try {
      final products = await _dbHelper.getAllProducts();
      if (products.isNotEmpty) {
        setState(() {
          _allProducts = products;
          _filteredProducts = products;
          _isLoading = false;
          _usingFallback = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('SQLite failed: $e — falling back to JSON');
    }

    // Step 2: Fallback to local JSON file
    await _loadFromJson();
  }

  Future<void> _loadFromJson() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/products.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> productsJson = jsonData['products'];
      final products = productsJson
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _isLoading = false;
        _usingFallback = true;
      });
    } catch (e) {
      debugPrint('JSON fallback also failed: $e');
      setState(() => _isLoading = false);
    }
  }

  // If using SQLite → query DB with WHERE clauses
  // If using fallback → filter the JSON list in Dart
  // Price is always filtered in Dart after category/gender/style
  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);

    try {
      List<ProductModel> result;

      if (!_usingFallback) {
        // Use SQLite with combined WHERE query
        result = await _dbHelper.getProductsByFilters(
          category: _selectedCategory,
          gender: _selectedGender,
          style: _selectedStyle,
        );
      } else {
        // Fallback: filter the in-memory JSON list
        result = List.from(_allProducts);

        if (_selectedCategory != 'All') {
          result = result
              .where((p) =>
                  p.category.toLowerCase() ==
                  _selectedCategory.toLowerCase())
              .toList();
        }
        if (_selectedGender != 'All') {
          result = result
              .where((p) =>
                  p.gender.toLowerCase() ==
                  _selectedGender.toLowerCase())
              .toList();
        }
        if (_selectedStyle != 'All') {
          result = result
              .where((p) =>
                  (p.style ?? '').toLowerCase() ==
                  _selectedStyle.toLowerCase())
              .toList();
        }
      }

      // Price filter always applied in Dart
      switch (_selectedPrice) {
        case 'Under \$50':
          result = result.where((p) => p.price < 50).toList();
          break;
        case '\$50–\$100':
          result =
              result.where((p) => p.price >= 50 && p.price <= 100).toList();
          break;
        case 'Over \$100':
          result = result.where((p) => p.price > 100).toList();
          break;
      }

      setState(() {
        _filteredProducts = result;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Filter error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onCategorySelected(String val) {
    setState(() => _selectedCategory = val);
    _applyFilters();
  }

  void _onGenderSelected(String val) {
    setState(() => _selectedGender = val);
    _applyFilters();
  }

  void _onStyleSelected(String val) {
    setState(() => _selectedStyle = val);
    _applyFilters();
  }

  void _onPriceSelected(String val) {
    setState(() => _selectedPrice = val);
    _applyFilters();
  }

  String _getSectionTitle() {
    if (_selectedCategory != 'All') return _selectedCategory;
    if (_selectedGender != 'All') return _selectedGender;
    if (_selectedStyle != 'All') return _selectedStyle;
    return 'Trending';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            // Show fallback banner if using JSON instead of SQLite
            if (_usingFallback)
              Container(
                width: double.infinity,
                color: const Color(0xFFFFF3CD),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 6),
                child: const Text(
                  'Offline mode — showing local data',
                  style: TextStyle(fontSize: 12, color: Color(0xFF856404)),
                ),
              ),
            _buildFilterLabel('Category'),
            _buildFilterRow(_categories, _selectedCategory, _onCategorySelected),
            const SizedBox(height: 8),
            _buildFilterLabel('Gender'),
            _buildFilterRow(_genders, _selectedGender, _onGenderSelected),
            const SizedBox(height: 8),
            _buildFilterLabel('Style'),
            _buildFilterRow(_styles, _selectedStyle, _onStyleSelected),
            const SizedBox(height: 8),
            _buildFilterLabel('Price Range'),
            _buildFilterRow(_priceFilters, _selectedPrice, _onPriceSelected),
            _buildSectionTitle(),
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(
        'Search',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildFilterLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFilterRow(
    List<String> options,
    String selected,
    void Function(String) onSelected,
  ) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = selected == option;
          return GestureDetector(
            onTap: () => onSelected(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getSectionTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.3,
            ),
          ),
          if (!_isLoading)
            Text(
              '${_filteredProducts.length} items',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list_off,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different filter',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return _ProductCard(product: _filteredProducts[index]);
      },
    );
  }
}

class _ProductCard extends StatefulWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isWishlisted = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.product.title;
    final price = widget.product.price;
    final image = widget.product.image;
    final displayTitle =
        title.length > 28 ? '${title.substring(0, 28)}...' : title;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: widget.product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: const Color(0xFFF5F5F5),
                      width: double.infinity,
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFFF5F5F5),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF5F5F5),
                          child: const Center(
                            child: Icon(Icons.image_outlined,
                                color: Colors.grey, size: 40),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _isWishlisted = !_isWishlisted),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isWishlisted
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: _isWishlisted ? Colors.red : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              displayTitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
