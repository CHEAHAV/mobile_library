import 'package:frontend/models/book.dart';

class Category {
  final String categoryName;
  final List<Book> books;

  Category({
    required this.categoryName,
    this.books = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryName: json['category_name'] as String? ?? '',
      books: (json['books'] as List<dynamic>? ?? [])
          .map((b) => Book.fromJson(b))
          .toList(),
    );
  }
}