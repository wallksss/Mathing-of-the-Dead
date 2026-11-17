// Bridge for packages that still use package:flutter/material (notably
// firebase_ui_auth). Their widgets read the legacy Theme, which is a
// different InheritedWidget from material_ui's, so without this they fall
// back to the default light theme.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy;
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../settings/app_settings.dart';

/// Legacy-material theme mirroring [buildTheme] (seed, brightness, font).
legacy.ThemeData buildLegacyTheme(AppSettings settings, Brightness brightness) {
  final scheme = legacy.ColorScheme.fromSeed(
    seedColor: settings.seedColor,
    brightness: brightness,
  );
  return legacy.ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    fontFamily: GoogleFonts.getFont(settings.fontFamily).fontFamily,
    scaffoldBackgroundColor: scheme.surface,
  );
}

/// Gives app widgets placed inside legacy screens (e.g. the builders of
/// firebase_ui's SignInScreen) the material_ui [Material] ancestor that
/// InkWell, buttons and chips need; the legacy Scaffold only provides the
/// legacy one.
class AppMaterialSurface extends StatelessWidget {
  const AppMaterialSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Material(type: MaterialType.transparency, child: child);
}

/// Exposes the legacy theme to [child], following the active material_ui
/// theme's brightness.
class LegacyThemeBridge extends StatelessWidget {
  const LegacyThemeBridge({
    super.key,
    required this.settings,
    required this.child,
  });

  final AppSettings settings;
  final Widget child;

  @override
  Widget build(BuildContext context) => legacy.Theme(
    data: buildLegacyTheme(settings, Theme.of(context).brightness),
    child: child,
  );
}
