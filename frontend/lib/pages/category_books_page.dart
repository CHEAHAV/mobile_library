import 'package:flutter/material.dart';
import 'package:frontend/apis/book_api.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/book.dart';
import 'package:frontend/screens/book_detail_screen.dart';

class CategoryBooksPage extends StatelessWidget {
  final Category category;
  const CategoryBooksPage({super.key, required this.category});

  static const _navy = Color(0xFF1A1F5E);
  static const _bgGrey = Color(0xFFFDF6E3);
  static const _muted = Color(0xFF888888);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGrey,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 22),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        category.categoryName,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _navy,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ── Book count ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${category.books.length} books available',
                  style: const TextStyle(fontSize: 13, color: _muted),
                ),
              ),
            ),

            // ── Grid of books ──────────────────────────────────────────
            Expanded(
              child: category.books.isEmpty
                  ? const Center(
                      child: Text(
                        'No books in this category.',
                        style: TextStyle(color: _muted),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.52,
                          ),
                      itemCount: category.books.length,
                      itemBuilder: (_, i) => _BookCard(book: category.books[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Book card ──────────────────────────────────────────────────────────────
class _BookCard extends StatelessWidget {
  final Book book;
  const _BookCard({required this.book});

  static const _muted = Color(0xFF888888);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cover ──────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              BookApi.instance.getCoverUrl(book.id),
              headers: BookApi.instance.imageHeaders, // ✅ ngrok header
              width: double.infinity,
              height: 130,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.book, size: 40, color: Colors.teal),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            book.authorName ?? 'Unknown',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: _muted),
          ),
        ],
      ),
    );
  }
}
