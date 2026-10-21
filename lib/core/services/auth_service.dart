import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  FirebaseAuth? _authInstance;
  FirebaseAuth? get _auth {
    try {
      return _authInstance ??= FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static const String webClientId =
      '359702741609-sj0oevlr1pankcl65otrjjait172l0mp.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: webClientId,
    scopes: ['email', 'profile'],
  );

  Stream<User?> get authStateChanges => _auth?.authStateChanges() ?? const Stream.empty();

  User? get currentUser => _auth?.currentUser;

  bool get isSignedIn => _auth?.currentUser != null;

  bool get isAnonymous => _auth?.currentUser?.isAnonymous ?? false;

  String get currentUid => _auth?.currentUser?.uid ?? 'guest_fitquest_uid';

  String get displayName =>
      _auth?.currentUser?.displayName ??
      (_auth?.currentUser?.isAnonymous == true ? 'FitQuest Guest' : 'Aiman');

  String get email =>
      _auth?.currentUser?.email ??
      (_auth?.currentUser?.isAnonymous == true ? 'guest@fitquest.app' : 'aiman@fitquest.app');

  String? get photoUrl => _auth?.currentUser?.photoURL;

  /// Sign In with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth?.signInWithCredential(credential);
    } catch (e) {
      debugPrint('FitQuest Auth Error (Google): $e');
      rethrow;
    }
  }

  /// Sign In with Email and Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth?.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      debugPrint('FitQuest Auth Error (Email Sign In): $e');
      rethrow;
    }
  }

  /// Register with Email and Password
  Future<UserCredential?> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final credential = await _auth?.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential?.user?.updateDisplayName(displayName.trim());
      }
      return credential;
    } catch (e) {
      debugPrint('FitQuest Auth Error (Register): $e');
      rethrow;
    }
  }

  /// Anonymous / Guest Sign-in
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth?.signInAnonymously();
    } catch (e) {
      debugPrint('FitQuest Auth Error (Anonymous): $e');
      rethrow;
    }
  }

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth?.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      debugPrint('FitQuest Auth Error (Password Reset): $e');
      rethrow;
    }
  }

  /// Update User Profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (displayName != null) {
        await _auth?.currentUser?.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await _auth?.currentUser?.updatePhotoURL(photoURL);
      }
    } catch (e) {
      debugPrint('FitQuest Auth Error (Update Profile): $e');
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await _auth?.signOut();
    } catch (_) {}
  }
}
