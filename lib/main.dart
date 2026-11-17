import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'core/prefs.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await preloadFonts(prefs.getString(PrefKeys.fontFamily) ?? 'Roboto');

  Object? firebaseError;
  var configured = false;
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    configured = !options.apiKey.startsWith('REPLACE');
    if (configured) {
      await Firebase.initializeApp(options: options);
      // On the web the session is restored asynchronously: wait for it so
      // the app does not flash the login page for signed-in players.
      await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      FirebaseUIAuth.configureProviders([
        EmailAuthProvider(),
        GoogleProvider(clientId: AppConfig.googleClientId),
      ]);
    }
  } catch (e) {
    firebaseError = e;
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: configured && firebaseError == null
          ? const MathingApp()
          : FirebaseSetupApp(error: firebaseError),
    ),
  );
}
