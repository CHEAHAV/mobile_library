import 'dart:convert';
import 'package:frontend/models/book.dart';
import 'package:frontend/services/api_service.dart';
import 'package:http/http.dart' as http;

class BookApi {
  // response all book from api
  Future<List<Book>> fetchBooks() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/book/all'),
      headers: ApiService.headers,
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((b) => Book.fromJson(b)).toList();
    }
    throw Exception('Failed to load books: ${response.statusCode}');
  }

  // respone cover image
  String getCoverUrl(int bookId)    => '${ApiService.baseUrl}/book/$bookId/cover';
  // respone pdf when open to read
  String getDownloadUrl(int bookId) => '${ApiService.baseUrl}/book/$bookId/download';
}