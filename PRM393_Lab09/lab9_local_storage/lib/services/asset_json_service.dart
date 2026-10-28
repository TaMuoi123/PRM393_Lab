import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';

class AssetJsonService {
  final String assetPath;

  const AssetJsonService({this.assetPath = 'assets/data/products.json'});

  /// Reads JSON string from Flutter assets and parses it into a List of Products
  Future<List<Product>> loadProducts() async {
    try {
      // Step 3: Use async loading (rootBundle.loadString) to read file content
      final jsonString = await rootBundle.loadString(assetPath);

      // Step 4: Convert loaded string into a Dart List using JSON decode
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      return jsonList
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load assets from $assetPath: $e');
    }
  }

  /// Loads raw JSON string directly for display or inspection
  Future<String> loadRawString() async {
    return await rootBundle.loadString(assetPath);
  }
}
