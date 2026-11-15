import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences instance, loaded once in `main` and injected through
/// a provider override.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

/// Keys used in SharedPreferences.
abstract final class PrefKeys {
  static const lastLocation = 'last_location';
  static const themeMode = 'theme_mode';
  static const seedColor = 'seed_color';
  static const fontFamily = 'font_family';
  static const textScale = 'text_scale';
  static const sound = 'sound_enabled';
  static const zombieSpeed = 'zombie_speed';
  static const locale = 'locale';

  /// Saved game for a level (plate, tokens, run stats).
  static String game(String uid, String level) => 'game_${uid}_$level';
}
