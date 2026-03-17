import 'package:flutter/material.dart';
import 'package:frontend/models/book.dart';
import 'package:frontend/apis/book_api.dart';
import 'package:frontend/screens/book_detail_screen.dart';
import 'package:frontend/services/favorite_service.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  // ── Palette ────────────────────────────────────────────────────────────────
  static const _navy      = Color(0xFF1A1F5E);
  static const _royalBlue = Color(0xFF2B4EFF);
  static const _bgGrey    = Color(0xFFF5F5F5);
  static const _cardWhite = Color(0xFFFFFFFF);
  static const _textMuted = Color(0xFF888888);
  static const _heartRed  = Color(0xFFE53935);

  final _fav = FavoriteService.instance;

  @override
  void initState() {
    super.initState();
    // Rebuild whenever favorites change
    _fav.addListener(_onFavChanged);
  }

  @override
  void dispose() {
    _fav.removeListener(_onFavChanged);
    super.dispose();
  }

  void _onFavChanged() => setState(() {});

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final books = _fav.favorites;

    return Scaffold(
      backgroundColor: _bgGrey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(books.length),
            Expanded(
              child: books.isEmpty
                  ? _buildEmpty()
                  : _buildGrid(books),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wishlist',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'YOUR SAVED BOOKS',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              // Count badge
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _royalBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count book${count == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: _royalBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _heartRed.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 48,
              color: _heartRed,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No saved books yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the ♥ on any book to save it here',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid ───────────────────────────────────────────────────────────────────
  Widget _buildGrid(List<Book> books) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.58,
      ),
      itemCount: books.length,
      itemBuilder: (_, i) => _FavoriteBookCard(book: books[i]),
    );
  }
}

// ── Favorite book card ────────────────────────────────────────────────────────
class _FavoriteBookCard extends StatelessWidget {
  final Book book;
  const _FavoriteBookCard({required this.book});

  static const _heartRed  = Color(0xFFE53935);
  static const _cardWhite = Color(0xFFFFFFFF);
  static const _textMuted = Color(0xFF888888);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover + remove button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  child: Image.network(
                    BookApi.instance.getCoverUrl(book.id),
                    headers: BookApi.instance.imageHeaders,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: Colors.teal.shade50,
                      child: const Center(
                          child: Icon(Icons.book,
                              size: 48, color: Colors.teal)),
                    ),
                  ),
                ),
                // Remove from favorites
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => FavoriteService.instance.remove(book),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.favorite,
                          color: _heartRed, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.authorName ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: _textMuted),
                  ),
                  if (book.rating != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 12, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          book.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}