import 'package:flutter/material.dart';
import 'package:frontend/apis/book_api.dart';
import 'package:frontend/apis/category_api.dart';
import 'package:frontend/components/favorite_button.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/book.dart';
import 'package:frontend/screens/book_detail_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Category>> futureCategories;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureCategories = CategoryApi.instance.fetchCategoryWithBook();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: FutureBuilder<List<Category>>(
          future: futureCategories,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final categories = snapshot.data!
                .where((c) => c.books.isNotEmpty)
                .toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header row ──────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Discover',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'BROWSE LIBRARY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _iconBtn(Icons.notifications_outlined),
                                const SizedBox(width: 4),
                                _iconBtn(Icons.shopping_bag_outlined),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // ── Search bar ──────────────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Titles, authors, or genres...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.grey[400]),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // ── Category sections ─────────────────────────────────────
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _CategorySection(category: categories[index]),
                    childCount: categories.length,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, size: 20),
          onPressed: () {},
        ),
      );
}

// ── Category section ──────────────────────────────────────────────────────────
class _CategorySection extends StatelessWidget {
  final Category category;
  const _CategorySection({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.categoryName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See More',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal book list
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: category.books.length,
            itemBuilder: (_, i) => _BookCard(book: category.books[i]),
          ),
        ),
      ],
    );
  }
}

// ── Book card ─────────────────────────────────────────────────────────────────
class _BookCard extends StatelessWidget {
  final Book book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
      ),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 14),
        child: Column(                          // ✅ Column.children is a List
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover image + favourite button ────────────────────────────
            Stack(                             // ✅ Stack is one item in the list
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    BookApi.instance.getCoverUrl(book.id),
                    headers: BookApi.instance.imageHeaders,
                    width: 130,
                    height: 170,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      // ✅ three distinct param names — no duplicate wildcards
                      width: 130,
                      height: 170,
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.book,
                        size: 48,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ),
                // Heart button overlay
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(book: book),
                ),
              ],
            ),

            // ── Title & author ─────────────────────────────────────────────
            const SizedBox(height: 8),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              book.authorName ?? 'Unknown',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}