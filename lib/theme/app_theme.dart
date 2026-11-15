import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../settings/app_settings.dart';

/// Builds the light or dark theme from the user's settings.
ThemeData buildTheme(AppSettings settings, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: settings.seedColor,
    brightness: brightness,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  final textTheme = GoogleFonts.getTextTheme(
    settings.fontFamily,
    base.textTheme,
  );
  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
      titleTextStyle: (textTheme.titleLarge ?? const TextStyle()).copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}

/// Starts downloading the fonts the app needs and waits (briefly) for them,
/// so the first frames are not laid out with a fallback font.
Future<void> preloadFonts(String family) async {
  try {
    GoogleFonts.getTextTheme(family);
    GoogleFonts.oswald();
    GoogleFonts.creepster();
    await GoogleFonts.pendingFonts().timeout(const Duration(seconds: 4));
  } catch (_) {
    // Offline or slow network: continue with the fallback font.
  }
}

/// Font used for the licence plate digits.
TextStyle plateTextStyle({double size = 40, Color? color}) =>
    GoogleFonts.oswald(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1,
    );

/// Display font for titles ("Mathing of the Dead").
TextStyle horrorTitleStyle({double size = 40, Color? color}) =>
    GoogleFonts.creepster(fontSize: size, color: color, letterSpacing: 1.5);
