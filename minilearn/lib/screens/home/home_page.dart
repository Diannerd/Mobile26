import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_notifier.dart';
import '../../services/api_service.dart';
import '../../models/course.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<Course> _allCourses = [];
  List<Course> _filtered = [];
  bool _loadingCourses = true;

  // ✅ SOURCE THUMBNAIL MENU (ASSET)
  // Kamu bilang file ada di: minilearn\lib\assets\images\...
  // Di Flutter, pakai slash "/" dan path relatif project:
  static const String kThumbCourses = 'assets/images/thumb_courses.jpg';
  static const String kThumbAnnouncement = 'assets/images/thumb_announcement.png';
  static const String kThumbAbout = 'assets/images/thumb_info.png';
  static const String kThumbFaq = 'assets/images/thumb_faq.jpg';

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _searchCtrl.addListener(_onSearchChanged);
  }

  Future<void> _loadCourses() async {
    final api = context.read<ApiService>();
    try {
      final courses = await api.getCourses();
      if (!mounted) return;
      setState(() {
        _allCourses = courses;
        _filtered = courses;
        _loadingCourses = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCourses = false);
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      final q = _searchCtrl.text.trim().toLowerCase();
      setState(() {
        _filtered = q.isEmpty
            ? _allCourses
            : _allCourses.where((c) => c.title.toLowerCase().contains(q)).toList();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final name = auth.displayName;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context, name),
          Expanded(
            child: _loadingCourses
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final q = _searchCtrl.text.trim();
    final searching = q.isNotEmpty;

    if (searching) {
      if (_filtered.isEmpty) {
        return const Center(child: Text('Course tidak ditemukan.'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filtered.length,
        itemBuilder: (context, i) {
          final c = _filtered[i];
          return Card(
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  c.thumbnailUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(c.title),
              subtitle: Text(c.description, maxLines: 2, overflow: TextOverflow.ellipsis),
              onTap: () => context.go('/courses/${c.id}'),
            ),
          );
        },
      );
    }

    // ✅ grid menu (pakai thumbnail asset)
    return GridView.count(
      padding: const EdgeInsets.all(18),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.15,
      children: [
        _buildMenuCard(
          context,
          title: 'Courses',
          imageUrl: kThumbCourses,
          onTap: () => context.go('/courses'),
        ),
        _buildMenuCard(
          context,
          title: 'Announcements',
          imageUrl: kThumbAnnouncement,
          onTap: () => context.go('/announcements'),
        ),
        _buildMenuCard(
          context,
          title: 'About',
          imageUrl: kThumbAbout,
          onTap: () => context.go('/about'),
        ),
        _buildMenuCard(
          context,
          title: 'FAQ',
          imageUrl: kThumbFaq,
          onTap: () => context.go('/info'),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 18, right: 18, bottom: 18),
      decoration: const BoxDecoration(
        color: Color(0xFF2149DD),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AvatarMenu(name: name),
              IconButton(
                onPressed: () => context.go('/notifications'),
                icon: const Icon(Icons.notifications_active_outlined, color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _searchCtrl.clear()),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _AvatarMenu({required String name}) {
    return GestureDetector(
      onTap: () => context.go('/profile'),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Color(0xFF2149DD),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    const radius = 22.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE6E6FF),
                    child: const Center(
                      child: Icon(Icons.image_not_supported, color: Color(0xFF2149DD), size: 34),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(20),
                        Colors.black.withAlpha(120),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(230),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF2149DD)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(blurRadius: 6, color: Colors.black45, offset: Offset(0, 2)),
                          ],
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
}
