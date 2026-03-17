import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:frontend/pages/favoritepage.dart';
import 'package:frontend/pages/homepage.dart';
import 'package:frontend/pages/categorypage.dart';
import 'package:frontend/pages/profilepage.dart';

class ButtomNav extends StatefulWidget {
  final User user; // ✅ receive real logged-in user
  const ButtomNav({super.key, required this.user});

  @override
  State<ButtomNav> createState() => _ButtomNavState();
}

class _ButtomNavState extends State<ButtomNav> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const CategoryPage(),
      const FavoritePage(),
      ProfilePage(user: widget.user), // ✅ pass real user
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Colors.white,
        color: Colors.black,
        animationDuration: const Duration(milliseconds: 500),
        onTap: (int index) => setState(() => _currentIndex = index),
        items: const [
          Icon(Icons.home_outlined,        color: Colors.white),
          Icon(Icons.library_books_outlined, color: Colors.white),
          Icon(Icons.favorite,             color: Colors.white),
          Icon(Icons.person_outline,       color: Colors.white),
        ],
      ),
      body: _pages[_currentIndex],
    );
  }
}