// Development-only entry point: runs the app with an in-memory fake of
// Firebase Auth and Firestore so the UI can be previewed without a Firebase
// project.  flutter run -d chrome -t tool/preview_main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathing_of_the_dead/app.dart';
import 'package:mathing_of_the_dead/core/prefs.dart';
import 'package:mathing_of_the_dead/data/models.dart';
import 'package:mathing_of_the_dead/data/user_repository.dart';
import 'package:mathing_of_the_dead/game/engine/difficulty.dart';
import 'package:mathing_of_the_dead/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeUser implements User {
  @override
  String get uid => 'preview-user';
  @override
  String? get email => 'survivor@example.com';
  @override
  String? get displayName => 'Survivor';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuth implements FirebaseAuth {
  final _user = _FakeUser();
  @override
  User? get currentUser => _user;
  @override
  Stream<User?> authStateChanges() => Stream.value(_user);
  @override
  Stream<User?> userChanges() => Stream.value(_user);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRepo implements UserRepository {
  final _records = <SolveRecord>[
    SolveRecord(
      level: Difficulty.easy,
      plate: '8131',
      expression: '√(8 + 1) = 3**1',
      latex: r'\sqrt{8 + 1} = 3^{1}',
      points: 14,
      usedHint: false,
      solvedAt: DateTime(2026, 11, 12, 21, 30),
    ),
    SolveRecord(
      level: Difficulty.hard,
      plate: '5261',
      expression: '5 - 2 = 6 / 1',
      latex: r'5 - 2 = \frac{6}{1}',
      points: 61,
      usedHint: true,
      solvedAt: DateTime(2026, 11, 13, 9, 5),
    ),
  ];
  var _score = 75;
  var _nickname = 'Survivor';

  Future<T> _delay<T>(T v) =>
      Future.delayed(const Duration(milliseconds: 600), () => v);

  @override
  Future<PlayerProfile> loadProfile(User user) => _delay(
    PlayerProfile(
      uid: user.uid,
      nickname: _nickname,
      score: _score,
      solved: _records.length,
      bestStreak: 3,
      solvedByLevel: {
        for (final d in Difficulty.values)
          d.name: _records.where((r) => r.level == d).length,
      },
    ),
  );

  @override
  Future<Set<String>> solvedPlates(String uid, Difficulty level) => _delay({
    for (final r in _records)
      if (r.level == level) r.plate,
  });

  @override
  Future<void> recordSolve(
    String uid,
    SolveRecord record, {
    required int streak,
  }) async {
    _records.insert(0, record);
    _score += record.points;
  }

  @override
  Future<void> recordRun(String uid, int runScore) async {}

  @override
  Future<List<SolveRecord>> history(String uid, {int limit = 300}) =>
      _delay(List.of(_records));

  @override
  Future<List<RankingEntry>> ranking({int limit = 50}) => _delay([
    const RankingEntry(uid: 'a', nickname: 'Ana', score: 940, solved: 31),
    const RankingEntry(uid: 'b', nickname: 'Bruno', score: 610, solved: 22),
    const RankingEntry(uid: 'c', nickname: 'Carla', score: 300, solved: 12),
    RankingEntry(
      uid: 'preview-user',
      nickname: _nickname,
      score: _score,
      solved: _records.length,
    ),
    const RankingEntry(uid: 'd', nickname: 'Diego', score: 20, solved: 1),
  ]);

  @override
  Future<void> updateNickname(String uid, String nickname) async {
    _nickname = nickname;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await preloadFonts(prefs.getString(PrefKeys.fontFamily) ?? 'Roboto');
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        firebaseAuthProvider.overrideWithValue(_FakeAuth()),
        userRepositoryProvider.overrideWithValue(_FakeRepo()),
      ],
      child: const MathingApp(),
    ),
  );
}
