import 'package:flutter/material.dart';
import 'package:frontend/apis/book_api.dart';
import 'package:frontend/components/favorite_button.dart';
import 'package:frontend/models/book.dart';
import 'package:frontend/screens/pdf_viewer_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Palette ────────────────────────────────────────────────────────────────
  static const _deepNavy = Color(0xFF0D0F2B);
  static const _midNavy = Color(0xFF1A1F5E);
  static const _royalBlue = Color(0xFF2B4EFF);
  static const _cream = Color(0xFFFAF8F3);
  static const _warmGold = Color(0xFFD4A853);
  static const _textDark = Color(0xFF1C1C2E);
  static const _textMuted = Color(0xFF8A8A9A);
  static const _divider = Color(0xFFEAE8E3);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    // Trigger after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _animCtrl.forward());
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          // ── Scrollable body ───────────────────────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Full-bleed hero ─────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 420,
                pinned: true,
                backgroundColor: _deepNavy,
                leading: _circleBtn(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                actions: [
                  _circleBtn(
                    child: FavoriteButton(
                      book: book,
                      size: 20,
                      showBackground: false,
                    ),
                  ),
                  _circleBtn(icon: Icons.share_outlined, onTap: () {}),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHero(book),
                  collapseMode: CollapseMode.parallax,
                ),
              ),

              // ── Content card ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _buildContent(book),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // ── Floating Read Now button ──────────────────────────────────────
          Positioned(bottom: 0, left: 0, right: 0, child: _buildReadBar(book)),
        ],
      ),
    );
  }

  // ── Hero ───────────────────────────────────────────────────────────────────
  Widget _buildHero(Book book) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred background tint
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_deepNavy, _midNavy],
            ),
          ),
        ),

        // Decorative circles
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // ignore: deprecated_member_use
              color: _royalBlue.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // ignore: deprecated_member_use
              color: _warmGold.withOpacity(0.06),
            ),
          ),
        ),

        // Book cover centered
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Hero(
                tag: 'book-cover-${book.id}',
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: _royalBlue.withOpacity(0.2),
                        blurRadius: 48,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      BookApi.instance.getCoverUrl(book.id),
                      headers: BookApi
                          .instance
                          .imageHeaders, // ✅ works on Flutter Web
                      width: 165,
                      height: 235,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 165,
                          height: 235,
                          color: _midNavy,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white38,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 165,
                        height: 235,
                        decoration: BoxDecoration(
                          color: _midNavy,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.menu_book_outlined,
                          size: 56,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom fade overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  // ignore: deprecated_member_use
                  _cream.withOpacity(0.15),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Content ────────────────────────────────────────────────────────────────
  Widget _buildContent(Book book) {
    return Container(
      decoration: const BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Title & author ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _royalBlue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      book.authorName ?? 'Unknown Author',
                      style: const TextStyle(
                        fontSize: 15,
                        color: _royalBlue,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Stats row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _statBlock(
                    icon: Icons.star_rounded,
                    iconColor: _warmGold,
                    value: book.rating?.toStringAsFixed(1) ?? 'N/A',
                    label: 'Rating',
                  ),
                  _vertDivider(),
                  _statBlock(
                    icon: Icons.menu_book_rounded,
                    iconColor: _royalBlue,
                    value: '${book.page ?? 0}',
                    label: 'Pages',
                  ),
                  _vertDivider(),
                  _statBlock(
                    icon: Icons.translate_rounded,
                    iconColor: const Color(0xFF2E9B6F),
                    value: book.language ?? 'N/A',
                    label: 'Language',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── Category tag ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _tag(Icons.bookmark_outline, 'Fiction'),
                if (book.language != null)
                  _tag(Icons.language_outlined, book.language!),
                _tag(Icons.auto_stories_outlined, 'E-Book'),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── About section ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'About this Book',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(
                        color: _warmGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  book.description ?? 'No description available for this book.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textMuted,
                    height: 1.8,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Divider ────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: _divider, height: 1),
          ),
          const SizedBox(height: 20),

          // ── Book details table ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Book Details',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 12),
                _detailRow('Title', book.title),
                _detailRow('Author', book.authorName ?? '—'),
                _detailRow('Language', book.language ?? '—'),
                _detailRow('Pages', '${book.page ?? '—'}'),
                _detailRow(
                  'Rating',
                  book.rating != null
                      ? '${book.rating!.toStringAsFixed(1)} / 5.0'
                      : '—',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Bottom Read Bar ────────────────────────────────────────────────────────
  Widget _buildReadBar(Book book) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: _cream,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bookmark quick-save
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _divider),
            ),
            child: FavoriteButton(book: book, size: 22, showBackground: false),
          ),
          const SizedBox(width: 14),

          // Read Now
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: ()  {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewerScreen(
                            book: book,
                            downloadUrl: BookApi.instance.getPdfUrl(book.id),
                          ),
                        ),
                      );
                    },
                icon: const Icon(Icons.play_circle_filled_rounded, size: 22),
                label: const Text(
                  'Read Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _royalBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _circleBtn({IconData? icon, Widget? child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(6),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          // ignore: deprecated_member_use
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: child ?? Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _statBlock({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: _textMuted,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vertDivider() => Container(width: 1, height: 48, color: _divider);

  Widget _tag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: _royalBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        border: Border.all(color: _royalBlue.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _royalBlue),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: _royalBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 13,
                color: _textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: _textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
