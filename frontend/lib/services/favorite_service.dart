import 'package:flutter/material.dart';
import 'package:frontend/models/book.dart';

/// Global favorite state — wrap your app with ChangeNotifierProvider
/// or use the singleton directly via FavoriteService.instance
class FavoriteService extends ChangeNotifier {
  FavoriteService._();
  static final FavoriteService instance = FavoriteService._();

  final List<Book> _favorites = [];

  List<Book> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String bookId) => _favorites.any((b) => b.id == bookId);

  void toggle(Book book) {
    if (isFavorite(book.id)) {
      _favorites.removeWhere((b) => b.id == book.id);
    } else {
      _favorites.add(book);
    }
    notifyListeners();
  }

  void remove(Book book) {
    _favorites.removeWhere((b) => b.id == book.id);
    notifyListeners();
  }
}