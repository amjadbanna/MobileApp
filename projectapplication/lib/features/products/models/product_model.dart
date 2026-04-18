class ProductModel {
  final int id;
  final String title;
  final double price;
  final String category;
  final String image;
  final String description;
  final List<String> sizes;
  final List<String> colors;
  final bool isFavorite;
  final String gender;
  final String? style;
  final double? rating;
  final int? reviewCount;

  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.image,
    required this.description,
    required this.sizes,
    required this.colors,
    this.isFavorite = false,
    required this.gender,
    this.style,
    this.rating,
    this.reviewCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      gender: json['gender'] as String,
      category: json['category'] as String,
      style: json['style'] as String?,
      image: json['image'] as String,
      description: json['description'] as String? ?? '',
      sizes: (json['sizes'] as List<dynamic>? ?? [])
          .map((size) => size.toString())
          .toList(),
      colors: (json['colors'] as List<dynamic>? ?? [])
          .map((color) => color.toString())
          .toList(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
    );
  }
}