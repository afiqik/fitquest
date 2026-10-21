// File generated and configured for FitQuest Firebase project
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// [DefaultFirebaseOptions] configures Firebase for FitQuest (project id: fitquest-97517)
/// with Realtime Database at https://fitquest-97517-default-rtdb.asia-southeast1.firebasedatabase.app
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDOwVzg0uEDl8KaUTc6_-1R99-Ajg77_j4',
    appId: '1:359702741609:web:b73824c8b4015f0ef4d8f8',
    messagingSenderId: '359702741609',
    projectId: 'fitquest-97517',
    authDomain: 'fitquest-97517.firebaseapp.com',
    databaseURL: 'https://fitquest-97517-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'fitquest-97517.firebasestorage.app',
    measurementId: 'G-56QQ2VZ432',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmCmJgyJpldBaxHNXELjnSfnBrO5XVf-s',
    appId: '1:359702741609:android:47a9f0f2f60eaf57f4d8f8',
    messagingSenderId: '359702741609',
    projectId: 'fitquest-97517',
    databaseURL: 'https://fitquest-97517-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'fitquest-97517.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBmCmJgyJpldBaxHNXELjnSfnBrO5XVf-s',
    appId: '1:359702741609:ios:fitquest97517ios',
    messagingSenderId: '359702741609',
    projectId: 'fitquest-97517',
    databaseURL: 'https://fitquest-97517-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'fitquest-97517.firebasestorage.app',
    iosBundleId: 'com.fitquest.app',
  );
}
