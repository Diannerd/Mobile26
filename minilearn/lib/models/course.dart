class Course {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String level;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.level,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    if (id.isEmpty) {
      throw Exception('Course JSON tidak punya id: $json');
    }

    return Course(
      id: id,
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      thumbnailUrl: (json['thumbnailUrl'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
    );
  }
}
