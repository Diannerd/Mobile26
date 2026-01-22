class Lesson {
  final String id;
  final String courseId;
  final String type; // "lesson" atau "quiz"
  final String title;
  final String content;
  final String? mediaUrl;
  final String? questions; // untuk quiz (string JSON)

  Lesson({
    required this.id,
    required this.courseId,
    required this.type,
    required this.title,
    required this.content,
    this.mediaUrl,
    this.questions,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'].toString(),
        courseId: json['courseId'].toString(),
        type: (json['type'] ?? 'lesson').toString(),
        title: (json['title'] ?? '').toString(),
        content: (json['content'] ?? '').toString(),
        mediaUrl: (json['mediaUrl'] as String?)?.trim().isEmpty == true
            ? null
            : json['mediaUrl'] as String?,
        questions: (json['questions'] as String?)?.trim().isEmpty == true
            ? null
            : json['questions'] as String?,
      );

  String? get mediaPath => null;
}
