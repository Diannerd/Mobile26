import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../models/lesson.dart';
import '../../providers/auth_notifier.dart';
import '../../services/api_service.dart';
import '../../services/firestore_service.dart';

class QuizPage extends StatefulWidget {
  final String quizId; // ini adalah id item /contents yang type=quiz
  const QuizPage({super.key, required this.quizId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<Lesson> _future;
  final Map<int, int> _answers = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // quiz diambil dari /contents/:id
    _future = context.read<ApiService>().getContentById(widget.quizId);
  }

  List<_QuizQuestion> _parseQuestions(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded.map<_QuizQuestion>((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return _QuizQuestion.fromJson(map);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthNotifier>().user!.uid;
    final fs = context.read<FirestoreService>();

    final extra = GoRouterState.of(context).extra;
    final lessonId =
        (extra is Map && extra['lessonId'] != null) ? extra['lessonId'].toString() : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: FutureBuilder<Lesson>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final quizContent = snap.data!;
          final questions = _parseQuestions(quizContent.questions);

          if (questions.isEmpty) {
            return const Center(
              child: Text('Quiz belum punya pertanyaan.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                quizContent.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              ...List.generate(questions.length, (i) {
                final q = questions[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i + 1}. ${q.q}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(q.options.length, (j) {
                          return RadioListTile<int>(
                            value: j,
                            groupValue: _answers[i],
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _answers[i] = v);
                            },
                            title: Text(q.options[j]),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () async {
                          setState(() => _submitting = true);

                          int score = 0;
                          for (int i = 0; i < questions.length; i++) {
                            if (_answers[i] == questions[i].answer) score++;
                          }

                          await fs.saveQuizResult(
                            uid: uid,
                            quizId: quizContent.id, // id item quiz di contents
                            lessonId: lessonId,
                            score: score,
                            total: questions.length,
                          );

                          if (!mounted) return;
                          setState(() => _submitting = false);

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Hasil Quiz'),
                              content: Text('Skor kamu: $score / ${questions.length}'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                  child: Text(_submitting ? 'Mengirim...' : 'Submit'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Model internal untuk pertanyaan quiz (parse dari JSON string)
class _QuizQuestion {
  final String q;
  final List<String> options;
  final int answer;

  _QuizQuestion({
    required this.q,
    required this.options,
    required this.answer,
  });

  factory _QuizQuestion.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
    return _QuizQuestion(
      q: (json['q'] ?? '').toString(),
      options: opts,
      answer: (json['answer'] as num?)?.toInt() ?? 0,
    );
  }
}
