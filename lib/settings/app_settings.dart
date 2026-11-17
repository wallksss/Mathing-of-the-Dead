import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/prefs.dart';

/// How fast zombies walk. [off] is the "zen" mode: no timer, no lives.
enum ZombieSpeed {
  off(0),
  slow(1.5),
  normal(1),
  fast(0.6);

  const ZombieSpeed(this.durationFactor);

  /// Multiplier applied to the level's base walking time.
  final double durationFactor;
}

/// Ready-made themes (each is a seed color).
enum ThemePreset {
  classic(Color(0xFF6750A4)),
  toxic(Color(0xFF4CAF50)),
  bloodMoon(Color(0xFFB3261E)),
  midnight(Color(0xFF283593)),
  fog(Color(0xFF607D8B)),
  pumpkin(Color(0xFFEF6C00));

  const ThemePreset(this.seed);
  final Color seed;
}

/// Fonts offered in the settings page (all from Google Fonts).
const availableFonts = <String>[
  'Roboto',
  'EB Garamond',
  'Inter',
  'Lato',
  'Merriweather',
  'Nunito',
  'Source Code Pro',
  'Creepster',
];

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.seedColor = const Color(0xFF6750A4),
    this.fontFamily = 'Roboto',
    this.textScale = 1.0,
    this.soundEnabled = false,
    this.zombieSpeed = ZombieSpeed.normal,
    this.localeCode,
  });

  /// The device theme is used until the player picks one.
  final ThemeMode themeMode;
  final Color seedColor;
  final String fontFamily;
  final double textScale;

  /// Sound is OFF by default: starting with sound is a usability mistake.
  final bool soundEnabled;
  final ZombieSpeed zombieSpeed;

  /// `null` means "follow the device language".
  final String? localeCode;

  Locale? get locale => localeCode == null ? null : Locale(localeCode!);

  AppSettings copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
    String? fontFamily,
    double? textScale,
    bool? soundEnabled,
    ZombieSpeed? zombieSpeed,
    String? localeCode,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    seedColor: seedColor ?? this.seedColor,
    fontFamily: fontFamily ?? this.fontFamily,
    textScale: textScale ?? this.textScale,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    zombieSpeed: zombieSpeed ?? this.zombieSpeed,
    localeCode: localeCode ?? this.localeCode,
  );
}

/// Settings persisted in SharedPreferences.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final p = ref.watch(sharedPreferencesProvider);
    const defaults = AppSettings();
    final font = p.getString(PrefKeys.fontFamily);
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == p.getString(PrefKeys.themeMode),
        orElse: () => defaults.themeMode,
      ),
      seedColor: Color(
        p.getInt(PrefKeys.seedColor) ?? defaults.seedColor.toARGB32(),
      ),
      fontFamily: availableFonts.contains(font) ? font! : defaults.fontFamily,
      textScale: (p.getDouble(PrefKeys.textScale) ?? defaults.textScale).clamp(
        0.8,
        1.5,
      ),
      soundEnabled: p.getBool(PrefKeys.sound) ?? defaults.soundEnabled,
      zombieSpeed: ZombieSpeed.values.firstWhere(
        (s) => s.name == p.getString(PrefKeys.zombieSpeed),
        orElse: () => defaults.zombieSpeed,
      ),
      localeCode: p.getString(PrefKeys.locale),
    );
  }

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _prefs.setString(PrefKeys.themeMode, mode.name);
  }

  void setSeedColor(Color color) {
    state = state.copyWith(seedColor: color);
    _prefs.setInt(PrefKeys.seedColor, color.toARGB32());
  }

  void setFontFamily(String font) {
    state = state.copyWith(fontFamily: font);
    _prefs.setString(PrefKeys.fontFamily, font);
  }

  void setTextScale(double scale) {
    state = state.copyWith(textScale: scale);
    _prefs.setDouble(PrefKeys.textScale, scale);
  }

  void setSound(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
    _prefs.setBool(PrefKeys.sound, enabled);
  }

  void toggleSound() => setSound(!state.soundEnabled);

  void setZombieSpeed(ZombieSpeed speed) {
    state = state.copyWith(zombieSpeed: speed);
    _prefs.setString(PrefKeys.zombieSpeed, speed.name);
  }

  void setLocale(String code) {
    state = state.copyWith(localeCode: code);
    _prefs.setString(PrefKeys.locale, code);
  }

  /// Back to factory defaults (keeps the chosen language).
  Future<void> reset() async {
    final p = _prefs;
    for (final key in [
      PrefKeys.themeMode,
      PrefKeys.seedColor,
      PrefKeys.fontFamily,
      PrefKeys.textScale,
      PrefKeys.sound,
      PrefKeys.zombieSpeed,
    ]) {
      await p.remove(key);
    }
    state = AppSettings(localeCode: state.localeCode);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
