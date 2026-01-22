import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../models/lesson.dart';
import '../../providers/auth_notifier.dart';
import '../../services/api_service.dart';
import '../../services/firestore_service.dart';

class LessonPage extends StatefulWidget {
  final String lessonId;
  const LessonPage({super.key, required this.lessonId});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late Future<Lesson> _future;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // karena lesson dan quiz digabung ke /contents
    _future = context.read<ApiService>().getContentById(widget.lessonId);
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthNotifier>().user!.uid;
    final fs = context.read<FirestoreService>();
    final api = context.read<ApiService>();

    final extra = GoRouterState.of(context).extra;
    final courseId = (extra is Map && extra['courseId'] != null)
        ? extra['courseId'].toString()
        : null;
    final totalLessons = (extra is Map && extra['totalLessons'] != null)
        ? int.parse(extra['totalLessons'].toString())
        : 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: FutureBuilder<Lesson>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lesson = snap.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                lesson.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              // ✅ Media pakai URL publik (tanpa Firebase Storage)
              if (lesson.mediaUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    lesson.mediaUrl!,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Text(lesson.content),
              const SizedBox(height: 16),

              if (courseId != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving
                        ? null
                        : () async {
                            setState(() => _saving = true);

                            await fs.markLessonCompleted(
                              uid: uid,
                              courseId: courseId,
                              lessonId: lesson.id,
                              totalLessons: totalLessons,
                            );

                            if (!mounted) return; // ✅ fix context across async
                            setState(() => _saving = false);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Progress tersimpan ✅')),
                            );
                          },
                    icon: const Icon(Icons.check),
                    label: Text(
                      _saving ? 'Menyimpan...' : 'Tandai selesai & simpan progress',
                    ),
                  ),
                ),

              // ✅ Tombol quiz: ambil quiz dari /contents?courseId=...&type=quiz
              if (courseId != null) ...[
                const SizedBox(height: 12),
                FutureBuilder<Lesson?>(
                  future: api.getQuizByCourse(courseId),
                  builder: (context, qsnap) {
                    if (!qsnap.hasData) return const SizedBox.shrink();
                    final quizContent = qsnap.data;
                    if (quizContent == null) return const SizedBox.shrink();

                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // quizId sekarang pakai id item quiz di contents
                          context.go(
                            '/quiz/${quizContent.id}',
                            extra: {'lessonId': lesson.id},
                          );
                        },
                        icon: const Icon(Icons.quiz),
                        label: const Text('Mulai Quiz'),
                      ),
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
