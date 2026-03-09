import 'dart:convert';
import 'dart:io';
import 'package:frontend/models/book.dart';
import 'package:frontend/models/category.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const bool isEmulator = true;

  static String get baseUrl {
    if (Platform.isAndroid) {
      return isEmulator
          ? 'http://10.0.2.2:8000'
          : 'http://192.168.1.13:8000';
    }
    return 'http://localhost:8000';
  }

  // ✅ fetch all books flat list
  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/book/all'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((b) => Book.fromJson(b)).toList();
    }
    throw Exception('Failed to load books: ${response.statusCode}');
  }

  // ✅ fetch books grouped by category
  Future<List<Category>> fetchBooksByCategory() async {
    final response = await http.get(Uri.parse('$baseUrl/book/by-category'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((c) => Category.fromJson(c)).toList();
    }
    throw Exception('Failed to load categories: ${response.statusCode}');
  }

  // ✅ fetch all categories
  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/category/all'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((c) => Category.fromJson(c)).toList();
    }
    throw Exception('Failed to load categories: ${response.statusCode}');
  }

  String getCoverUrl(int bookId)    => '$baseUrl/book/$bookId/cover';
  String getDownloadUrl(int bookId) => '$baseUrl/book/$bookId/download';
}