import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/generated/app_localizations.dart';
import 'routing/router.dart';
import 'settings/app_settings.dart';
import 'theme/app_theme.dart';
import 'widgets/common.dart';

const _localizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  FirebaseUILocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Applies the font size chosen in the settings to the whole app.
Widget _scaled(BuildContext context, Widget? child, double scale) {
  final media = MediaQuery.of(context);
  return MediaQuery(
    data: media.copyWith(textScaler: TextScaler.linear(scale)),
    child: child ?? const SizedBox.shrink(),
  );
}

class MathingApp extends ConsumerWidget {
  const MathingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildTheme(settings, Brightness.light),
      darkTheme: buildTheme(settings, Brightness.dark),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: _localizationsDelegates,
      routerConfig: router,
      builder: (context, child) => _scaled(context, child, settings.textScale),
    );
  }
}

/// Shown when Firebase has not been configured (or failed to start).
class FirebaseSetupApp extends ConsumerWidget {
  const FirebaseSetupApp({super.key, this.error});

  final Object? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildTheme(settings, Brightness.light),
      darkTheme: buildTheme(settings, Brightness.dark),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: _localizationsDelegates,
      builder: (context, child) => _scaled(context, child, settings.textScale),
      home: Builder(
        builder: (context) {
          final l = AppLocalizations.of(context);
          return Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.firebaseMissingTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error == null
                            ? l.firebaseMissingBody
                            : l.firebaseErrorBody('$error'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const LanguagePicker(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
