// Placeholder. Generate the real file with:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure --platforms=web,android
//
// which overwrites this file. While the values below start with "REPLACE",
// the app shows a "Firebase is not configured" screen instead of crashing.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCvGURNiWk8OA96q0MdKl2BHZl_9WDka58',
    appId: '1:781418960314:web:e781ea69fae074b50af983',
    messagingSenderId: '781418960314',
    projectId: 'mathing-of-the-dead',
    authDomain: 'mathing-of-the-dead.firebaseapp.com',
    storageBucket: 'mathing-of-the-dead.firebasestorage.app',
    measurementId: 'G-0EQ21EJ9F6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAYeq1Y0ZlMmSKFmH-m4M2G-4Xn3_OZ8TQ',
    appId: '1:781418960314:android:917bd66c40815a990af983',
    messagingSenderId: '781418960314',
    projectId: 'mathing-of-the-dead',
    storageBucket: 'mathing-of-the-dead.firebasestorage.app',
  );
}
