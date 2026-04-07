import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allProducts = [];
  List<dynamic> _filteredProducts = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String _searchQuery = '';

  final List<String> _categories = [
    'All', 'New Arrivals', 'Men', 'Women', 'Streetwear', 'Accessories',
  ];

  final Map<String, String?> _categoryApiMap = {
    'All': null,
    'New Arrivals': null,
    'Men': "men's clothing",
    'Women': "women's clothing",
    'Streetwear': "men's clothing",
    'Accessories': 'jewelery',
  };

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _allProducts = data;
          _filteredProducts = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      List<dynamic> result = List.from(_allProducts);
      final apiCategory = _categoryApiMap[_selectedCategory];
      if (_selectedCategory != 'All' && _selectedCategory != 'New Arrivals') {
        result = result.where((p) => p['category'].toString().toLowerCase()
            .contains(apiCategory?.toLowerCase() ?? '')).toList();
      }
      if (_selectedCategory == 'New Arrivals') {
        result = result.reversed.take(6).toList();
      }
      if (_searchQuery.isNotEmpty) {
        result = result.where((p) => p['title'].toString().toLowerCase()
            .contains(_searchQuery.toLowerCase())).toList();
      }
      _filteredProducts = result;
    });
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _applyFilters();
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
            _buildSearchBar(),
            _buildCategoryFilters(),
            const SizedBox(height: 8),
            _buildSectionTitle(),
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text('Search',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700,
            color: Colors.black, letterSpacing: -0.5)),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(12)),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Search for products...',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 22),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    color: Colors.grey.shade500,
                    onPressed: () { _searchController.clear(); _onSearchChanged(''); })
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => _onCategorySelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(cat,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle() {
    String title = _searchQuery.isNotEmpty
        ? 'Results for "$_searchQuery"'
        : _selectedCategory == 'All' ? 'Trending' : _selectedCategory;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20,
              fontWeight: FontWeight.w700, color: Colors.black)),
          if (!_isLoading)
            Text('${_filteredProducts.length} items',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No products found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400)),
            const SizedBox(height: 8),
            Text('Try a different search or category',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.68,
        crossAxisSpacing: 14, mainAxisSpacing: 14,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) =>
          _ProductCard(product: _filteredProducts[index]),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final dynamic product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isWishlisted = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.product['title'].toString();
    final price = widget.product['price'];
    final image = widget.product['image'].toString();
    final displayTitle = title.length > 30 ? '${title.substring(0, 30)}...' : title;

    return Container(
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12)),
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
                    child: Image.network(image, fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black)),
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _isWishlisted = !_isWishlisted),
                    child: Container(
                      width: 34, height: 34,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        _isWishlisted ? Icons.favorite : Icons.favorite_border,
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
          Text(displayTitle,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: Colors.black87, height: 1.3),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('\$$price',
              style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700, color: Colors.black)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
