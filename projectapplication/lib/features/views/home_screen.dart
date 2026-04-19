import 'dart:async';
import 'package:flutter/material.dart';
import 'package:projectapplication/core/services/product_catalog_service.dart';
import 'package:projectapplication/core/services/wishlist_service.dart';
import 'package:projectapplication/features/products/models/product_model.dart';
import 'package:projectapplication/features/products/views/product_details_screen.dart';
import 'package:projectapplication/features/views/view_all_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductCatalogService _catalogService = ProductCatalogService.instance;
  final WishlistService _wishlist = WishlistService.instance;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  List<ProductModel> _products = [];
  bool _isLoading = true;
  int _currentBanner = 0;

  static const int _sectionLimit = 6;

  static const List<Map<String, String>> _banners = [
    {
      'image':
          'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?q=80&w=1200&auto=format&fit=crop',
      'title': 'Spring Collection',
      'subtitle': 'Modern Urban Essentials',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=1200&auto=format&fit=crop',
      'title': 'New Arrivals',
      'subtitle': 'Fresh styles for the season',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?q=80&w=1200&auto=format&fit=crop',
      'title': 'Street Style',
      'subtitle': 'Urban looks & techwear',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _wishlist.addListener(_refresh);
    _startBannerAutoScroll();
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (!_bannerController.hasClients) return;
      final next = (_currentBanner + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _wishlist.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _catalogService.loadProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<ProductModel> _getByGender(String gender) => _products
      .where((p) => p.gender.toLowerCase() == gender.toLowerCase())
      .take(_sectionLimit)
      .toList();

  List<ProductModel> _getByStyle(String style) => _products
      .where((p) => (p.style ?? '').toLowerCase() == style.toLowerCase())
      .take(_sectionLimit)
      .toList();

  void _goToViewAll({required String title, String? gender, String? style, String? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewAllScreen(
          title: title,
          gender: gender,
          style: style,
          category: category,
        ),
      ),
    );
  }

  // ─── Widgets ─────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        'URBNOVA',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 4,
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (i) => setState(() => _currentBanner = i),
            itemCount: _banners.length,
            itemBuilder: (context, i) {
              final b = _banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(b['image']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(18),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b['subtitle']!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _goToViewAll(title: 'All Products'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Shop Now',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentBanner == i ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentBanner == i
                    ? Colors.black
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final isFav = _wishlist.isInWishlist(product.id);
    final isNew = product.id <= 5;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product)),
      ),
      child: Container(
        width: 168,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Container(
                    height: 172,
                    width: double.infinity,
                    color: const Color(0xFFF2F2F2),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stack) => const Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.grey, size: 40),
                      ),
                    ),
                  ),
                ),
                // Wishlist button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _wishlist.toggleWishlist(product),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 17,
                        color: isFav ? Colors.red : Colors.black54,
                      ),
                    ),
                  ),
                ),
                // "NEW" badge
                if (isNew)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 3),
              child: Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
            if (product.rating != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(11, 0, 11, 3),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded,
                        size: 13, color: Colors.amber.shade600),
                    const SizedBox(width: 3),
                    Text(
                      product.rating!.toStringAsFixed(1),
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    if (product.reviewCount != null) ...[
                      Text(
                        ' (${product.reviewCount})',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade400),
                      ),
                    ],
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 2, 11, 12),
              child: Text(
                '\$${product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalProductList(List<ProductModel> productList) {
    if (productList.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text('No products available',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return SizedBox(
      height: 290,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: productList.length,
        itemBuilder: (context, index) =>
            _buildProductCard(productList[index]),
      ),
    );
  }

  Widget _buildAllSections() {
    final newArrivals = _products.take(_sectionLimit).toList();
    final menProducts = _getByGender('men');
    final womenProducts = _getByGender('women');
    final streetwear = _getByStyle('streetwear');
    final featured = _products.reversed.take(_sectionLimit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'New Arrivals',
          onViewAll: () => _goToViewAll(title: 'New Arrivals'),
        ),
        _buildHorizontalProductList(newArrivals),
        _buildSectionTitle(
          'Men',
          onViewAll: () => _goToViewAll(title: 'Men', gender: 'Men'),
        ),
        _buildHorizontalProductList(menProducts),
        _buildSectionTitle(
          'Women',
          onViewAll: () => _goToViewAll(title: 'Women', gender: 'Women'),
        ),
        _buildHorizontalProductList(womenProducts),
        _buildSectionTitle(
          'Streetwear',
          onViewAll: () => _goToViewAll(title: 'Streetwear', style: 'Streetwear'),
        ),
        _buildHorizontalProductList(streetwear),
        _buildSectionTitle(
          'Featured',
          onViewAll: () => _goToViewAll(title: 'Featured'),
        ),
        _buildHorizontalProductList(featured),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildHeroBanner(),
          const SizedBox(height: 4),
          _buildAllSections(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Unable to load products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your local JSON file and pubspec asset configuration.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                _loadProducts();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text('Retry',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.black))
            : _products.isNotEmpty
                ? _buildBody()
                : _buildErrorState(),
      ),
    );
  }
}
