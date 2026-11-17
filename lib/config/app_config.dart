/// Project-wide constants that are not user facing translations.
abstract final class AppConfig {
  /// Group members, shown on the login page.
  static const groupMembers = <String>[
    'Anderson Cristiano Sassaki Gonçalves',
    'Pedro Henrique Benetton Comisso',
  ];

  /// OAuth "Web client ID" of the Firebase project (Firebase console →
  /// Authentication → Sign-in method → Google → Web SDK configuration).
  static const _googleClientId =
      '781418960314-a79e132ussq2po0eh5e79jinhasg9r1n.apps.googleusercontent.com';

  /// Can be overridden at build time with
  /// `--dart-define=GOOGLE_CLIENT_ID=...` (an empty value is ignored).
  static const _googleClientIdFromEnv = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
  );

  static String get googleClientId =>
      _googleClientIdFromEnv.isEmpty ? _googleClientId : _googleClientIdFromEnv;
}
