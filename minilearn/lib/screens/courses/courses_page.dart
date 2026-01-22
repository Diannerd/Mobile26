import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/courses_notifier.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CoursesNotifier>().fetch());
  }

  // Helper warna level (disesuaikan agar terang di background gelap)
  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF69F0AE); // Green accent
      case 'intermediate':
        return const Color(0xFFFFD740); // Amber accent
      case 'advanced':
        return const Color(0xFFFF5252); // Red accent
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CoursesNotifier>();

    return Scaffold(
      extendBodyBehindAppBar: true, // Agar background gradient sampai ke status bar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent, // AppBar transparan
        centerTitle: true,
        title: const Text(
          'Explore Courses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
            shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        // ✅ 1. Background Gradient Modern (Deep Blue)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A2980), // Deep Blue
              Color(0xFF26D0CE), // Light Teal/Blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: vm.loading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : vm.error != null
                          ? Center(
                              child: Text(
                                'Error: ${vm.error}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                          : Center(
                              // ✅ 2. Memastikan list berada di tengah (untuk tablet/web)
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 600),
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                  itemCount: vm.courses.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                                  itemBuilder: (context, i) {
                                    final c = vm.courses[i];
                                    final levelColor = _getLevelColor(c.level);

                                    return GestureDetector(
                                      onTap: () => context.go('/courses/${c.id}'),
                                      child: Container(
                                        // ✅ 3. Glassmorphism Card Style
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1), // Transparan
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2), // Border tipis kaca
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              // Thumbnail Section
                                              Hero(
                                                tag: 'courseThumb_${c.id}',
                                                child: ClipRRect(
                                                  borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(20),
                                                    bottomLeft: Radius.circular(20),
                                                  ),
                                                  child: SizedBox(
                                                    width: 100,
                                                    child: Image.network(
                                                      c.thumbnailUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          color: Colors.white.withOpacity(0.1),
                                                          child: const Icon(Icons.image_not_supported,
                                                              color: Colors.white54),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Info Section
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(14.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      // Level Badge (Glassy)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: levelColor.withOpacity(0.2),
                                                          borderRadius: BorderRadius.circular(8),
                                                          border: Border.all(
                                                              color: levelColor.withOpacity(0.5),
                                                              width: 0.5),
                                                        ),
                                                        child: Text(
                                                          c.level.toUpperCase(),
                                                          style: TextStyle(
                                                            color: levelColor,
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            letterSpacing: 0.5,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      // Title
                                                      Text(
                                                        c.title,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          color: Colors.white, // Teks Putih
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                          height: 1.2,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      // Action Text
                                                      Row(
                                                        children: [
                                                          Icon(Icons.play_circle_fill,
                                                              size: 16, color: Colors.cyanAccent[100]),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            'Start Learning',
                                                            style: TextStyle(
                                                              color: Colors.cyanAccent[100],
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Arrow Icon
                                              Padding(
                                                padding: const EdgeInsets.only(right: 12.0),
                                                child: Center(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white.withOpacity(0.1),
                                                    ),
                                                    padding: const EdgeInsets.all(4),
                                                    child: const Icon(Icons.chevron_right,
                                                        color: Colors.white70, size: 20),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}