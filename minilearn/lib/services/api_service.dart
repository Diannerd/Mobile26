import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/course.dart';
import '../models/lesson.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: kApiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }

  Future<List<Course>> getCourses() async {
    final res = await _dio.get('/courses');
    final data = (res.data as List).cast<dynamic>();
    return data
        .map((e) => Course.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Course> getCourse(String id) async {
    final res = await _dio.get('/courses/$id');
    return Course.fromJson(Map<String, dynamic>.from(res.data));
  }

  // Karena lesson & quiz digabung jadi "contents"
  Future<List<Lesson>> getLessonsByCourse(String courseId) async {
    final res = await _dio.get('/contents', queryParameters: {
      'courseId': courseId,
      'type': 'Lesson',
    });
    final data = (res.data as List).cast<dynamic>();
    return data
        .map((e) => Lesson.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // Ambil 1 item contents by id (bisa lesson atau quiz)
  Future<Lesson> getContentById(String id) async {
    final res = await _dio.get('/contents/$id');
    return Lesson.fromJson(Map<String, dynamic>.from(res.data));
  }

  // Biar kompatibel sama kode lama (LessonPage lama pakai getLesson)
  // Sekarang diarahkan ke contents
  Future<Lesson> getLesson(String lessonId) async {
    return getContentById(lessonId);
  }

  // Ambil quiz untuk course tertentu (type=quiz)
  Future<Lesson?> getQuizByCourse(String courseId) async {
    final res = await _dio.get('/contents', queryParameters: {
      'courseId': courseId,
      'type': 'quiz',
    });
    final data = (res.data as List).cast<dynamic>();
    if (data.isEmpty) return null;
    return Lesson.fromJson(Map<String, dynamic>.from(data.first));
  }
}
