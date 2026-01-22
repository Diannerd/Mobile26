import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  Future<String?> getDownloadUrl(String? path) async {
    if (path == null || path.trim().isEmpty) return null;
    return FirebaseStorage.instance.ref(path).getDownloadURL();
  }
}
