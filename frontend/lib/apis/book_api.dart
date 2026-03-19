import 'dart:convert';
import 'package:frontend/models/book.dart';
import 'package:frontend/services/api_service.dart';
import 'package:http/http.dart' as http;

class BookApi {
  // ── singleton ─────────────────────────────────────────────────────────────
  BookApi._();
  static final BookApi instance = BookApi._();

  // ── GET /book/all ─────────────────────────────────────────────────────────
  Future<List<Book>> fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/book/all'),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        final List json = jsonDecode(response.body);
        return json.map((b) => Book.fromJson(b)).toList();
      }
      throw Exception('Failed to load books: ${response.statusCode}');
    } catch (e) {
      throw Exception('fetchBooks error: $e');
    }
  }

String getCoverUrl(String bookId)    => '${ApiService.baseUrl}/book/$bookId/cover';
String getDownloadUrl(String bookId) => '${ApiService.baseUrl}/book/$bookId/download';
String getPdfUrl(String bookId)      => '${ApiService.baseUrl}/book/$bookId/pdf'; // ← ADD
Map<String, String> get imageHeaders => ApiService.headers;
}