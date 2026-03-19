import 'package:flutter/material.dart';
import 'package:frontend/apis/user_api.dart';
import 'package:frontend/models/book.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/screens/onboard.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _royalBlue = Color(0xFF2B4EFF);
  static const _bgGrey = Color(0xFFFDF6E3);
  static const _cardWhite = Color(0xFFFFFAF0);
  static const _textMuted = Color(0xFF888888);
  static const _urgentRed = Color(0xFFE53935);

  final _borrowed = const [
    BorrowedBook(
      title: 'The Great Gatsby',
      dueDate: 'DUE IN 2 DAYS',
      isUrgent: true,
      coverColor: Color(0xFFE8D5B0),
    ),
    BorrowedBook(
      title: 'Kafka on the Shore',
      dueDate: 'DUE IN 12 DAYS',
      isUrgent: false,
      coverColor: Color(0xFFF5EDE0),
    ),
    BorrowedBook(
      title: 'Brief History',
      dueDate: 'DUE IN 18 DAYS',
      isUrgent: false,
      coverColor: Color(0xFF2D5A4E),
    ),
  ];

  static const _onread = 14;
  static const _archived = 43;
  static const _reservations = 3;

  String get _genderLabel {
    switch (widget.user.gender.toLowerCase()) {
      case 'male':
        return '👨  Male';
      case 'female':
        return '👩  Female';
      default:
        return '🧑  ${widget.user.gender}';
    }
  }

  // ✅ use UserApi — correct endpoint /user/{id}/user
  String get _photoUrl =>
      UserApi.instance.getUserPhotoUrl(widget.user.id.toString());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _avatar(),
                    const SizedBox(height: 12),
                    _nameSection(),
                    const SizedBox(height: 20),
                    _tabBar(),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _tabController.index == 0
                          ? _statsRow()
                          : _membershipCard(),
                    ),
                    const SizedBox(height: 24),
                    _borrowedSection(),
                    const SizedBox(height: 16),
                    _menuTile(
                      icon: Icons.history_outlined,
                      iconBg: const Color(0xFFE8F0FE),
                      iconColor: _royalBlue,
                      title: 'Reading History',
                      subtitle: 'Review your past $_archived reads',
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    _menuTile(
                      icon: Icons.card_membership_outlined,
                      iconBg: const Color(0xFFE3F2FD),
                      iconColor: Colors.blue.shade700,
                      title: 'Gold Membership',
                      subtitle: 'Renews Oct 2024',
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    _menuTile(
                      icon: Icons.logout_outlined,
                      iconBg: const Color(0xFFFFEBEE),
                      iconColor: _urgentRed,
                      title: 'Log Out',
                      subtitle: 'Sign out of your account',
                      onTap: _confirmLogout,
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, size: 22),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Archive Profile',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined, size: 22),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );

  // ✅ ClipOval + Image.network so headers are sent correctly
  Widget _avatar() {
    final hasPhoto = widget.user.photoName.isNotEmpty;
    return Stack(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF5E6D8),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: hasPhoto
                ? Image.network(
                    _photoUrl,
                    headers: UserApi.instance.imageHeaders, // ✅ ngrok header
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.person,
                      size: 52,
                      color: Color(0xFFB07850),
                    ),
                  )
                : const Icon(Icons.person, size: 52, color: Color(0xFFB07850)),
          ),
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: _royalBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 15),
          ),
        ),
      ],
    );
  }

  Widget _nameSection() => Column(
    children: [
      Text(
        widget.user.username,
        style: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Curator of Stories',
        style: TextStyle(
          fontSize: 13,
          color: _textMuted,
          fontStyle: FontStyle.italic,
        ),
      ),
    ],
  );

  Widget _tabBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE8D5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: _royalBlue,
          borderRadius: BorderRadius.circular(22),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'Library Card'),
          Tab(text: 'Membership'),
        ],
      ),
    ),
  );

  Widget _statsRow() => Padding(
    key: const ValueKey('stats'),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        _statCard(_onread.toString(), 'ON READ'),
        const SizedBox(width: 10),
        _statCard(_archived.toString(), 'ARCHIVED'),
        const SizedBox(width: 10),
        _statCard(_reservations.toString(), 'FAVOURITES'),
      ],
    ),
  );

  Widget _statCard(String value, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _royalBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: _textMuted,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _membershipCard() => Padding(
    key: const ValueKey('membership'),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F5E), Color(0xFF2B4EFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: _royalBlue.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GOLD MEMBER',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.user.username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.user.email,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            children: [
              _chip(Icons.phone_outlined, widget.user.phone),
              _chip(Icons.wc_outlined, _genderLabel),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Member ID',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              Text(
                '#${widget.user.id.toString().padLeft(6, '0')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _chip(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Colors.white60, size: 13),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ],
  );

  Widget _borrowedSection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Currently Reading',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'VIEW ALL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _royalBlue,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _borrowed.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _bookCard(_borrowed[i]),
          ),
        ),
      ],
    ),
  );

  Widget _bookCard(BorrowedBook book) => SizedBox(
    width: 110,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: book.coverColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.menu_book_outlined,
              color: book.coverColor == const Color(0xFF2D5A4E)
                  ? Colors.white54
                  : Colors.black12,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          book.dueDate,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: book.isUrgent ? _urgentRed : _textMuted,
            letterSpacing: 0.3,
          ),
        ),
      ],
    ),
  );

  Widget _menuTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cardWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _textMuted, size: 20),
          ],
        ),
      ),
    ),
  );

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const OnBoard()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _urgentRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
