import 'dart:convert';
import 'package:frontend/models/book.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/book/all'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((book) => Book.fromJson(book)).toList();
    } else {
      throw Exception('Failed to load books: ${response.statusCode}');
    }
  }

  String getDownloadUrl(int bookId) {
    return '$baseUrl/book/$bookId/download';
  }
}