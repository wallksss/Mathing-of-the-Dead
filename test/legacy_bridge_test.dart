// Regression: after migrating to material_ui, widgets from packages that still
// use package:flutter/material (firebase_ui_auth) crashed for lack of the
// legacy MaterialLocalizations and rendered with the default light theme.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_localizations/flutter_localizations.dart'
    as legacy_l10n
    show GlobalMaterialLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mathing_of_the_dead/settings/app_settings.dart';
import 'package:mathing_of_the_dead/theme/legacy_theme.dart';

void main() {
  testWidgets('legacy widgets get localizations and the app brightness', (
    tester,
  ) async {
    const settings = AppSettings();
    late legacy.ThemeData seen;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          legacy_l10n.GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        builder: (context, child) =>
            LegacyThemeBridge(settings: settings, child: child!),
        home: legacy.Material(
          child: legacy.Builder(
            builder: (context) {
              seen = legacy.Theme.of(context);
              return const legacy.TextField();
            },
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(seen.brightness, Brightness.dark);
  });

  testWidgets('app ink widgets work inside legacy screens (firebase_ui)', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          legacy_l10n.GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: legacy.Scaffold(
          body: AppMaterialSurface(
            child: InkWell(onTap: () => taps++, child: const Text('pt')),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('pt'));
    expect(taps, 1);
  });
}
