import 'package:flutter/material.dart';
import 'package:frontend/models/book.dart';
import 'package:frontend/services/favorite_service.dart';

class FavoriteButton extends StatefulWidget {
  final Book book;
  final double size;
  final bool showBackground;

  const FavoriteButton({
    super.key,
    required this.book,
    this.size = 20,
    this.showBackground = true,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  final _fav = FavoriteService.instance;

  @override
  void initState() {
    super.initState();
    _fav.addListener(_rebuild);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.8,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _fav.removeListener(_rebuild);
    _controller.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _onTap() async {
    // Bounce animation
    await _controller.reverse();
    _fav.toggle(widget.book);
    await _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isFav = _fav.isFavorite(widget.book.id);

    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: widget.showBackground
            ? Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? const Color(0xFFE53935) : Colors.grey,
                  size: widget.size,
                ),
              )
            : Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? const Color(0xFFE53935) : Colors.white70,
                size: widget.size,
              ),
      ),
    );
  }
}
