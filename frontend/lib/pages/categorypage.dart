import 'package:flutter/material.dart';
import 'package:frontend/apis/category_api.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/pages/category_books_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<Category>> _futureCategories;
  final _searchCtrl = TextEditingController();
  List<Category> _all = [];
  List<Category> _filtered = [];

  static const _navy = Color(0xFF1A1F5E);
  static const _bgGrey = Color(0xFFFDF6E3);
  static const _cardBg = Color(0xFFFFFAF0);
  static const _muted = Color(0xFF888888);

  // badge colours cycle through these
  static const _badgeColors = [
    Color(0xFF1A1F5E),
    Color(0xFF1B5E3B),
    Color(0xFF2B4EFF),
    Color(0xFF455A64),
    Color(0xFF1565C0),
    Color(0xFF4A148C),
    Color(0xFF880E4F),
    Color(0xFF4E342E),
  ];

  // short descriptions per category — fallback if API has none
  static const _descriptions = [
    'Explore classic and modern storytelling',
    'Real stories, facts, and information',
    'The wonders of the natural world',
    'Ancient civilizations to modern eras',
    'Lives of influential figures',
    'Deep thoughts and existential questions',
    'Imagination without limits',
    'The world of money and markets',
  ];

  @override
  void initState() {
    super.initState();
    _futureCategories = CategoryApi.instance.fetchCategoryWithBook();
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all
                .where((c) => c.categoryName.toLowerCase().contains(q))
                .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGrey,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _searchBar(),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Category>>(
                future: _futureCategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (_all.isEmpty && snapshot.hasData) {
                    _all = snapshot.data!;
                    _filtered = _all;
                  }
                  if (_filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No categories found.',
                        style: TextStyle(color: _muted),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _categoryTile(_filtered[i], i),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _topBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: Row(
      children: [
        const Expanded(
          child: Center(
            child: Text(
              'All Categories',
              style: TextStyle(
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
  );

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _searchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      height: 46,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search categories...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    ),
  );

  // ── Category tile ─────────────────────────────────────────────────────────
  Widget _categoryTile(Category category, int index) {
    final badgeColor = _badgeColors[index % _badgeColors.length];
    final desc = index < _descriptions.length
        ? _descriptions[index]
        : '${category.books.length} books available';
    final number = (index + 1).toString().padLeft(
      2,
      '0',
    ); // highlight example — wire up state if needed

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryBooksPage(category: category),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Badge ───────────────────────────────────────────────
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // ── Text ────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.categoryName,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _muted, size: 20),
          ],
        ),
      ),
    );
  }
}
