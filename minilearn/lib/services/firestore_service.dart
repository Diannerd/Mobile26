import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

Future<void> saveUserProfile({required String uid, required Map<String, dynamic> data}) {
    return _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }
Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }
  Future<void> createUserIfMissing({required String uid, required String email}) async {
    final ref = _db.collection('users').doc(uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> announcementsStream() {
    return _db.collection('announcements').orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> userProgressStream(String uid) {
    return _db.collection('users').doc(uid).collection('progress').snapshots();
  }

  Future<Map<String, dynamic>?> getProgress(String uid, String courseId) async {
    final doc = await _db.collection('users').doc(uid).collection('progress').doc(courseId).get();
    return doc.data();
  }

  Future<void> markLessonCompleted({
    required String uid,
    required String courseId,
    required String lessonId,
    required int totalLessons,
  }) async {
    final ref = _db.collection('users').doc(uid).collection('progress').doc(courseId);
    final snap = await ref.get();
    final data = snap.data() ?? {};
    final completed = List<String>.from((data['completedLessonIds'] ?? []) as List);

    if (!completed.contains(lessonId)) {
      completed.add(lessonId);
    }

    final percent = totalLessons == 0 ? 0.0 : (completed.length / totalLessons);

    await ref.set({
      'courseId': courseId,
      'completedLessonIds': completed,
      'percent': percent,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveQuizResult({
    required String uid,
    required String quizId,
    required String lessonId,
    required int score,
    required int total,
  }) async {
    final ref = _db.collection('users').doc(uid).collection('quizResults').doc(quizId);
    await ref.set({
      'quizId': quizId,
      'lessonId': lessonId,
      'score': score,
      'total': total,
      'percent': total == 0 ? 0.0 : score / total,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
