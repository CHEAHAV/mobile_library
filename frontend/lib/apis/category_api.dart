import 'dart:convert';
import 'package:frontend/models/category.dart';
import 'package:frontend/services/api_service.dart';
import 'package:http/http.dart' as http;

class CategoryApi {
  // ── singleton ─────────────────────────────────────────────────────────────
  CategoryApi._();
  static final CategoryApi instance = CategoryApi._();

  // ── GET /category/with-books ──────────────────────────────────────────────
  Future<List<Category>> fetchCategoryWithBook() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/category/with-books'),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        final List json = jsonDecode(response.body);
        return json.map((c) => Category.fromJson(c)).toList();
      }
      throw Exception('Failed to load categories: ${response.statusCode}');
    } catch (e) {
      throw Exception('fetchCategoryWithBook error: $e');
    }
  }

  // ── GET /category/all ─────────────────────────────────────────────────────
  Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/category/all'),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        final List json = jsonDecode(response.body);
        return json.map((c) => Category.fromJson(c)).toList();
      }
      throw Exception('Failed to load categories: ${response.statusCode}');
    } catch (e) {
      throw Exception('fetchCategories error: $e');
    }
  }
}