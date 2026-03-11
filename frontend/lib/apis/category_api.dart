import 'dart:convert';
import 'package:frontend/models/category.dart';
import 'package:frontend/services/api_service.dart';
import 'package:http/http.dart' as http;

class CategoryApi {
  // response category with book from api
  Future<List<Category>> fetchCategoryWithBook() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/category/with-books'),
      headers: ApiService.headers,
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((c) => Category.fromJson(c)).toList();
    }
    throw Exception('Failed to load categories: ${response.statusCode}');
  }

  // response all category from api
  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/category/all'),
      headers: ApiService.headers,
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((c) => Category.fromJson(c)).toList();
    }
    throw Exception('Failed to load categories: ${response.statusCode}');
  }
}