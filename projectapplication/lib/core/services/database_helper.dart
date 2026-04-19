import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/products/models/product_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  static Future<Database>? _initFuture;

  DatabaseHelper._internal();

  Future<Database> get database {
    if (_database != null) return Future.value(_database!);
    _initFuture ??= _initDatabase().then((db) {
      _database = db;
      return db;
    }).catchError((e) {
      _initFuture = null;
      throw e;
    });
    return _initFuture!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'urbnova.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createTable,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'urbnova.db');
    try {
      await _database?.close();
    } catch (_) {}
    _database = null;
    _initFuture = null;
    await deleteDatabase(path);
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        gender TEXT NOT NULL,
        category TEXT NOT NULL,
        style TEXT,
        image TEXT NOT NULL,
        description TEXT,
        sizes TEXT,
        colors TEXT,
        isFavorite INTEGER DEFAULT 0,
        rating REAL,
        reviewCount INTEGER
      )
    ''');
    await _seedDatabase(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS products');
    await _createTable(db, newVersion);
  }

  Future<void> _seedDatabase(Database db) async {
    final String jsonString =
        await rootBundle.loadString('assets/data/products.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> products = jsonData['products'];

    final batch = db.batch();
    for (final product in products) {
      batch.insert('products', {
        'id': product['id'],
        'title': product['title'],
        'price': product['price'],
        'gender': product['gender'],
        'category': product['category'],
        'style': product['style'],
        'image': product['image'],
        'description': product['description'] ?? '',
        'sizes': json.encode(product['sizes'] ?? []),
        'colors': json.encode(product['colors'] ?? []),
        'isFavorite': (product['isFavorite'] == true) ? 1 : 0,
        'rating': product['rating'],
        'reviewCount': product['reviewCount'],
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final db = await database;
      List<Map<String, dynamic>> maps = await db.query('products');
      if (maps.isEmpty) {
        await _seedDatabase(db);
        maps = await db.query('products');
      }
      return maps.map(_mapToProduct).toList();
    } catch (_) {
      await _resetDatabase();
      final db = await database;
      final maps = await db.query('products');
      return maps.map(_mapToProduct).toList();
    }
  }

  Future<List<ProductModel>> getProductsByFilters({
    String? category,
    String? gender,
    String? style,
  }) async {
    final db = await database;

    final List<String> conditions = [];
    final List<dynamic> args = [];

    if (category != null && category != 'All') {
      conditions.add('LOWER(category) = ?');
      args.add(category.toLowerCase());
    }
    if (gender != null && gender != 'All') {
      conditions.add('LOWER(gender) = ?');
      args.add(gender.toLowerCase());
    }
    if (style != null && style != 'All') {
      conditions.add('LOWER(style) = ?');
      args.add(style.toLowerCase());
    }

    final where = conditions.isEmpty ? null : conditions.join(' AND ');
    final maps = await db.query(
      'products',
      where: where,
      whereArgs: args.isEmpty ? null : args,
    );
    return maps.map(_mapToProduct).toList();
  }

  ProductModel _mapToProduct(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int,
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      gender: map['gender'] as String,
      category: map['category'] as String,
      style: map['style'] as String?,
      image: map['image'] as String,
      description: map['description'] as String? ?? '',
      sizes: (json.decode(map['sizes'] as String? ?? '[]') as List<dynamic>)
          .map((s) => s.toString())
          .toList(),
      colors: (json.decode(map['colors'] as String? ?? '[]') as List<dynamic>)
          .map((c) => c.toString())
          .toList(),
      isFavorite: map['isFavorite'] == 1,
      rating: (map['rating'] as num?)?.toDouble(),
      reviewCount: map['reviewCount'] as int?,
    );
  }
}
