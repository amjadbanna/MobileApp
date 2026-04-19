import 'package:flutter/material.dart';
import '../../core/services/product_catalog_service.dart';
import '../../core/services/wishlist_service.dart';
import '../../features/products/models/product_model.dart';
import '../../features/products/views/product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductCatalogService _catalogService = ProductCatalogService.instance;

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = true;

  String _selectedCategory = 'All';
  String _selectedGender = 'All';
  String _selectedStyle = 'All';
  String _selectedPrice = 'All';

  static const _categories = [
    'All', 'Tops', 'Pants', 'Jackets', 'Coats',
    'Dresses', 'Outerwear', 'Footwear', 'Accessories',
  ];
  static const _genders = ['All', 'Men', 'Women', 'Unisex'];
  static const _styles = [
    'All', 'Streetwear', 'Casual', 'Formal', 'Modern',
    'Basics', 'Techwear', 'Active', 'Classic',
  ];
  static const _prices = [
    'All', 'Under \$50', '\$50–\$100', 'Over \$100',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _catalogService.loadProducts();
      if (!mounted) return;
      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _allProducts = [];
        _filteredProducts = [];
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    var result = List<ProductModel>.from(_allProducts);

    if (_selectedCategory != 'All') {
      result = result
          .where((p) =>
              p.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }
    if (_selectedGender != 'All') {
      result = result
          .where((p) =>
              p.gender.toLowerCase() == _selectedGender.toLowerCase())
          .toList();
    }
    if (_selectedStyle != 'All') {
      result = result
          .where((p) =>
              (p.style ?? '').toLowerCase() == _selectedStyle.toLowerCase())
          .toList();
    }
    switch (_selectedPrice) {
      case 'Under \$50':
        result = result.where((p) => p.price < 50).toList();
        break;
      case '\$50–\$100':
        result = result.where((p) => p.price >= 50 && p.price <= 100).toList();
        break;
      case 'Over \$100':
        result = result.where((p) => p.price > 100).toList();
        break;
    }

    setState(() => _filteredProducts = result);
  }

  bool get _hasActiveFilters =>
      _selectedCategory != 'All' ||
      _selectedGender != 'All' ||
      _selectedStyle != 'All' ||
      _selectedPrice != 'All';

  int get _activeFilterCount => [
        _selectedCategory,
        _selectedGender,
        _selectedStyle,
        _selectedPrice,
      ].where((v) => v != 'All').length;

  void _clearAll() {
    setState(() {
      _selectedCategory = 'All';
      _selectedGender = 'All';
      _selectedStyle = 'All';
      _selectedPrice = 'All';
    });
    _applyFilters();
  }

  // ─── Bottom Sheet Picker ──────────────────────────────────────────
  void _showPicker({
    required String label,
    required List<String> options,
    required String current,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: options.map((opt) {
                    final isSelected = opt == current;
                    return GestureDetector(
                      onTap: () {
                        onSelected(opt);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.black
                              : const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? Colors.black
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          opt,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
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
            _buildCategoryTabs(),
            _buildFilterBar(),
            const SizedBox(height: 4),
            _buildResultsBar(),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Browse',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          if (_hasActiveFilters)
            GestureDetector(
              onTap: _clearAll,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.close_rounded,
                        color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Clear ($_activeFilterCount)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Category Tabs ───────────────────────────────────────────────
  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = cat);
              _applyFilters();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Filter Bar ──────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _buildFilterPill(
            label: 'Gender',
            value: _selectedGender,
            onTap: () => _showPicker(
              label: 'Gender',
              options: _genders,
              current: _selectedGender,
              onSelected: (v) {
                setState(() => _selectedGender = v);
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 10),
          _buildFilterPill(
            label: 'Style',
            value: _selectedStyle,
            onTap: () => _showPicker(
              label: 'Style',
              options: _styles,
              current: _selectedStyle,
              onSelected: (v) {
                setState(() => _selectedStyle = v);
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 10),
          _buildFilterPill(
            label: 'Price',
            value: _selectedPrice,
            onTap: () => _showPicker(
              label: 'Price Range',
              options: _prices,
              current: _selectedPrice,
              onSelected: (v) {
                setState(() => _selectedPrice = v);
                _applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final isActive = value != 'All';
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.black : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isActive ? value : label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.black54,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isActive ? Colors.white : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Results Bar ─────────────────────────────────────────────────
  Widget _buildResultsBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Text(
        _isLoading
            ? 'Loading…'
            : '${_filteredProducts.length} item${_filteredProducts.length == 1 ? '' : 's'}',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
      ),
    );
  }

  // ─── Product Grid ────────────────────────────────────────────────
  Widget _buildProductGrid() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.black));
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No products match',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _clearAll,
              child: Text(
                'Clear all filters',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) =>
          _ProductCard(product: _filteredProducts[index]),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  final WishlistService _wishlist = WishlistService.instance;

  @override
  void initState() {
    super.initState();
    _wishlist.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _wishlist.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.product.title;
    final price = widget.product.price;
    final image = widget.product.image;
    final displayTitle =
        title.length > 28 ? '${title.substring(0, 28)}...' : title;
    final isFav = _wishlist.isInWishlist(widget.product.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: widget.product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
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
                                  strokeWidth: 2, color: Colors.black),
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
                      onTap: () => _wishlist.toggleWishlist(widget.product),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFav ? Colors.red : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
              child: Text(
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
              child: Text(
                '\$${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
