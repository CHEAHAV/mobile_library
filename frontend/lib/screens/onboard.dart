import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/content_model.dart';

class OnBoard extends StatefulWidget {
  const OnBoard({super.key});

  @override
  State<OnBoard> createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  int currentIndex = 0;

  // Per-page accent colors & bg colors
  static const _pageThemes = [
    _PageTheme(
      bg: Color(0xFFFDF6E3),
      accent: Color(0xFFB8860B),
      cardBg: Color(0xFFFFFAF0),
      shimmer: Color(0xFFF5E6C8),
    ),
    _PageTheme(
      bg: Color(0xFFFAF0DC),
      accent: Color(0xFFCC9900),
      cardBg: Color(0xFFFFFBF0),
      shimmer: Color(0xFFEDD98A),
    ),
    _PageTheme(
      bg: Color(0xFFF5ECD7),
      accent: Color(0xFFA0720A),
      cardBg: Color(0xFFFEFAF2),
      shimmer: Color(0xFFE8D5A3),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => currentIndex = index);
    _fadeCtrl.reset();
    _slideCtrl.reset();
    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  _PageTheme get _theme =>
      _pageThemes[currentIndex % _pageThemes.length];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: _theme.bg,
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip button ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AuthGate()),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: _theme.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _theme.accent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: _theme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Page view ─────────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: contents.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (_, i) {
                    final theme = _pageThemes[i % _pageThemes.length];
                    return _OnBoardPage(
                      content: contents[i],
                      theme: theme,
                      fadeAnim: _fadeAnim,
                      slideAnim: _slideAnim,
                      screenSize: size,
                    );
                  },
                ),
              ),

              // ── Bottom controls ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        contents.length,
                        (i) => _buildDot(i),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Next / Get Started button
                    GestureDetector(
                      onTap: () {
                        if (currentIndex == contents.length - 1) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AuthGate()),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _theme.accent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _theme.accent.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentIndex == contents.length - 1
                                    ? 'Get Started'
                                    : 'Continue',
                                style: const TextStyle(
                                  color: Color(0xFF0A0A0A),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFF0A0A0A),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == currentIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: isActive ? _theme.accent : _theme.accent.withOpacity(0.25),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ── Per-page widget ────────────────────────────────────────────────────────────
class _OnBoardPage extends StatelessWidget {
  final dynamic content;
  final _PageTheme theme;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final Size screenSize;

  const _OnBoardPage({
    required this.content,
    required this.theme,
    required this.fadeAnim,
    required this.slideAnim,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // ── Image frame ───────────────────────────────────────────────
          FadeTransition(
            opacity: fadeAnim,
            child: _ImageFrame(
              imagePath: content.image,
              theme: theme,
              screenSize: screenSize,
            ),
          ),

          const SizedBox(height: 32),

          // ── Text content ──────────────────────────────────────────────
          SlideTransition(
            position: slideAnim,
            child: FadeTransition(
              opacity: fadeAnim,
              child: Column(
                children: [
                  // Eyebrow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 2,
                        color: theme.accent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'THE ARCHIVE',
                        style: TextStyle(
                          color: theme.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 2,
                        color: theme.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    content.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2A00),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    content.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7A6030),
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Decorative image frame ────────────────────────────────────────────────────
class _ImageFrame extends StatelessWidget {
  final String imagePath;
  final _PageTheme theme;
  final Size screenSize;

  const _ImageFrame({
    required this.imagePath,
    required this.theme,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final imgHeight = screenSize.height * 0.38;

    return SizedBox(
      height: imgHeight + 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Glow blob behind image ─────────────────────────────────
          Positioned(
            top: 20,
            child: Container(
              width: screenSize.width * 0.65,
              height: imgHeight * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.accent.withOpacity(0.18),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // ── Decorative corner brackets ─────────────────────────────
          Positioned(
            top: 0,
            left: 10,
            child: _Corner(color: theme.accent, flip: false),
          ),
          Positioned(
            top: 0,
            right: 10,
            child: _Corner(
                color: theme.accent,
                flip: false,
                mirrorH: true),
          ),
          Positioned(
            bottom: 0,
            left: 10,
            child: _Corner(
                color: theme.accent,
                flip: true),
          ),
          Positioned(
            bottom: 0,
            right: 10,
            child: _Corner(
                color: theme.accent,
                flip: true,
                mirrorH: true),
          ),

          // ── Main image card ────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: theme.cardBg,
              border: Border.all(
                color: theme.accent.withOpacity(0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.accent.withOpacity(0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Image.asset(
                imagePath,
                height: imgHeight,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: imgHeight,
                  color: theme.shimmer,
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 64,
                    color: theme.accent.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),

          // ── Subtle gradient overlay on image bottom ────────────────
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            height: imgHeight * 0.35,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(23)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    theme.cardBg.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Corner bracket decoration ─────────────────────────────────────────────────
class _Corner extends StatelessWidget {
  final Color color;
  final bool flip;
  final bool mirrorH;

  const _Corner({
    required this.color,
    this.flip = false,
    this.mirrorH = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: mirrorH ? -1 : 1,
      scaleY: flip ? -1 : 1,
      child: SizedBox(
        width: 22,
        height: 22,
        child: CustomPaint(
          painter: _CornerPainter(color: color),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset.zero, Offset(size.width * 0.6, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height * 0.6), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}

// ── Theme data class ──────────────────────────────────────────────────────────
class _PageTheme {
  final Color bg;
  final Color accent;
  final Color cardBg;
  final Color shimmer;

  const _PageTheme({
    required this.bg,
    required this.accent,
    required this.cardBg,
    required this.shimmer,
  });
}