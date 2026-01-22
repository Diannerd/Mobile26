import 'package:flutter/material.dart';
import 'package:minilearn/screens/courses/english_pro_reader.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';


class CourseDetailPage extends StatefulWidget {
  final String id;

  const CourseDetailPage({super.key, required this.id});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  // Kita butuh 2 future: satu untuk info course, satu untuk list lessons
  late Future<Course> _futureCourse;
  late Future<List<Lesson>> _futureLessons;

  @override
  void initState() {
    super.initState();
    final api = context.read<ApiService>();
    // ✅ Panggil method yang benar: getCourse (bukan getCourseById)
    _futureCourse = api.getCourse(widget.id);
    _futureLessons = api.getLessonsByCourse(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black26, 
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: Container(
        // Background Gradient
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
        child: FutureBuilder<Course>(
          future: _futureCourse,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("Course not found", style: TextStyle(color: Colors.white)));
            }

            final course = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(top: 100, bottom: 20),
              child: Column(
                children: [
                  // --- HEADER SECTION (Course Info) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                            child: Image.network(
                              course.thumbnailUrl,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_,__,___) => const SizedBox(height: 180, child: Icon(Icons.image, color: Colors.white)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.cyanAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    course.level.toUpperCase(),
                                    style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 10),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  course.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  course.description,
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- LIST LESSONS SECTION ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Lessons",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // FutureBuilder untuk Lessons
                  FutureBuilder<List<Lesson>>(
                    future: _futureLessons,
                    builder: (context, lessonSnap) {
                      if (lessonSnap.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Colors.white54),
                        ));
                      }
                      
                      final lessons = lessonSnap.data ?? [];

                      if (lessons.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("No lessons available yet.", style: TextStyle(color: Colors.white54)),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shrinkWrap: true, // Penting agar tidak scroll conflict
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: lessons.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final lesson = lessons[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow_rounded, color: Colors.cyanAccent),
                              ),
                              title: Text(
                                lesson.title,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              trailing: Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
                              // Navigasi ke halaman belajar (nanti kita buat/sesuaikan)
                              onTap: () {
                                if (course.title == "English Pro") {
     // Navigasi ke halaman statis English Pro
     Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => EnglishProContentPage()),
     );
  }
                                // Contoh route: /courses/1/lessons/101
                                // Sesuaikan dengan route kamu nanti
                                // context.go('/courses/${widget.id}/lessons/${lesson.id}');
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}