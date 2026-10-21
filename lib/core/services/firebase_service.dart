import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      debugPrint('FitQuest: Firebase initialized successfully (fitquest-97517).');
    } catch (e) {
      debugPrint('FitQuest: Firebase initialization notice: $e');
      _isInitialized = false;
    }
  }
}
