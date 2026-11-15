// Development-only: shows the real login page using placeholder Firebase
// options (nothing is sent until the user tries to sign in).
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathing_of_the_dead/app.dart';
import 'package:mathing_of_the_dead/core/prefs.dart';
import 'package:mathing_of_the_dead/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await preloadFonts('Roboto');
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'preview',
      appId: '1:1:web:1',
      messagingSenderId: '1',
      projectId: 'preview',
    ),
  );
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(clientId: 'preview.apps.googleusercontent.com'),
  ]);
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MathingApp(),
    ),
  );
}
