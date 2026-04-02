import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../shared/navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class Product {
  final int id;
  final String title;
  final double price;
  final String category;
  final String image;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      image: json['image'],
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  bool isLoading = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          products = data.map((item) => Product.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Product> getProductsByCategory(String category) {
    return products
        .where((product) => product.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  void onNavTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'View All',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductCard(Product product) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                ),
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.favorite_border,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildHorizontalProductList(List<Product> productList) {
    return SizedBox(
      height: 255,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: productList.length,
        itemBuilder: (context, index) {
          return buildProductCard(productList[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menProducts = getProductsByCategory("men's clothing");
    final womenProducts = getProductsByCategory("women's clothing");
    final newArrivals = products.take(5).toList();
    final featuredOutfits = products.reversed.take(5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'URBNOVA',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f',
                            ),
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
                                Colors.black.withOpacity(0.45),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.bottomLeft,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Spring Collection',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Modern Urban Essentials',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    buildSectionTitle('New Arrivals'),
                    buildHorizontalProductList(newArrivals),

                    buildSectionTitle('Men'),
                    buildHorizontalProductList(menProducts),

                    buildSectionTitle('Women'),
                    buildHorizontalProductList(womenProducts),

                    buildSectionTitle('Featured Outfits'),
                    buildHorizontalProductList(featuredOutfits),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}