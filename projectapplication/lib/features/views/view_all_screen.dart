import 'package:flutter/material.dart';
import '../../core/services/product_catalog_service.dart';
import '../../core/services/wishlist_service.dart';
import '../../features/products/models/product_model.dart';
import '../../features/products/views/product_details_screen.dart';
import '../../shared/navigation_bar.dart';

class ViewAllScreen extends StatefulWidget {
  final String title;
  final String? gender;
  final String? style;
  final String? category;

  const ViewAllScreen({
    super.key,
    required this.title,
    this.gender,
    this.style,
    this.category,
  });

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  final ProductCatalogService _catalogService = ProductCatalogService.instance;

  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final all = await _catalogService.loadProducts();
      if (!mounted) return;
      setState(() {
        _products = _applyFilter(all);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _products = [];
        _isLoading = false;
      });
    }
  }

  List<ProductModel> _applyFilter(List<ProductModel> all) {
    var result = List<ProductModel>.from(all);

    if (widget.gender != null) {
      result = result
          .where((p) => p.gender.toLowerCase() == widget.gender!.toLowerCase())
          .toList();
    }
    if (widget.style != null) {
      result = result
          .where((p) =>
              (p.style ?? '').toLowerCase() == widget.style!.toLowerCase())
          .toList();
    }
    if (widget.category != null) {
      result = result
          .where((p) =>
              p.category.toLowerCase() == widget.category!.toLowerCase())
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (_) => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_products.length} item${_products.length == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ),
        ),
        Expanded(
          child: _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
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
                    ],
                  ),
                )
              : GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) =>
                      _ProductCard(product: _products[index]),
                ),
        ),
      ],
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
          borderRadius: BorderRadius.circular(12),
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
                        top: Radius.circular(12)),
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
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
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
