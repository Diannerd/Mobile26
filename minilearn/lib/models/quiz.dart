import 'dart:convert';

class Quiz {
  final String id;
  final String lessonId;
  final String title;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final raw = json['questions'];
    List<dynamic> qList;

    if (raw is String) {
      qList = jsonDecode(raw) as List<dynamic>;
    } else if (raw is List) {
      qList = raw;
    } else {
      qList = [];
    }

    return Quiz(
      id: json['id'].toString(),
      lessonId: json['lessonId'].toString(),
      title: (json['title'] ?? '').toString(),
      questions: qList.map((e) => Question.fromJson(e)).toList(),
    );
  }
}

class Question {
  final String q;
  final List<String> options;
  final int answer;

  Question({required this.q, required this.options, required this.answer});

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        q: (json['q'] ?? '').toString(),
        options: (json['options'] as List).map((e) => e.toString()).toList(),
        answer: (json['answer'] as num).toInt(),
      );
}
