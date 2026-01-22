import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../services/api_service.dart';

class CoursesNotifier extends ChangeNotifier {
  final ApiService api;

  CoursesNotifier(this.api);

  bool loading = false;
  String? error;
  List<Course> courses = [];

  Future<void> fetch() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      courses = await api.getCourses();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
