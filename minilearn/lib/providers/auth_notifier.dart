import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestore;

  User? user;
  Map<String, dynamic>? profile;

  AuthNotifier(this._authService, this._firestore) {
    _authService.authStateChanges().listen((u) async {
      user = u;

      if (u != null) {
        await _firestore.createUserIfMissing(uid: u.uid, email: u.email ?? '');
        profile = await _firestore.getUserProfile(u.uid);
      } else {
        profile = null;
      }

      notifyListeners();
    });
  }

  bool get loggedIn => user != null;

  String get displayName {
    final fromFs = profile?['displayName']?.toString().trim();
    if (fromFs != null && fromFs.isNotEmpty) return fromFs;

    final fromAuth = user?.displayName?.trim();
    if (fromAuth != null && fromAuth.isNotEmpty) return fromAuth;

    final email = user?.email ?? 'User';
    return email.contains('@') ? email.split('@')[0] : email;
  }

  String? get photoBase64 => profile?['photoBase64']?.toString();
  String? get interest => profile?['interest']?.toString();

  /// Dipakai setelah Edit Profile selesai supaya UI (Home) ikut berubah
  Future<void> refreshUser() async {
    final u = user;
    if (u == null) return;

    await u.reload();
    user = FirebaseAuth.instance.currentUser;
    profile = await _firestore.getUserProfile(u.uid);
    notifyListeners();
  }

  Future<void> logout() => _authService.logout();
}
