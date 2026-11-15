import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathing_of_the_dead/core/prefs.dart';
import 'package:mathing_of_the_dead/data/models.dart';
import 'package:mathing_of_the_dead/data/user_repository.dart';
import 'package:mathing_of_the_dead/game/engine/difficulty.dart';
import 'package:mathing_of_the_dead/game/engine/tokens.dart';
import 'package:mathing_of_the_dead/game/game_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo implements UserRepository {
  final saved = <SolveRecord>[];
  int runs = 0;

  @override
  Future<void> recordSolve(
    String uid,
    SolveRecord record, {
    required int streak,
  }) async {
    saved.add(record);
  }

  @override
  Future<void> recordRun(String uid, int runScore) async => runs++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoAuth implements FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

String plain(GameState s) => s.tokens.map((t) => t.plain).join();

void main() {
  late ProviderContainer container;
  late _FakeRepo repo;
  late SharedPreferences prefs;

  GameController c() => container.read(gameControllerProvider.notifier);
  GameState s() => container.read(gameControllerProvider)!;

  /// Starts a game and forces the plate to [plate].
  void startWith(String plate, Difficulty level) {
    final saved =
        '{"plate":"$plate","tokens":[${plate.split('').map((d) => '"$d"').join(',')}],'
        '"cursor":0,"score":0,"lives":3,"streak":0,"solvedThisRun":0,'
        '"usedHint":false,"progress":0,"serial":0}';
    prefs.setString(PrefKeys.game('u1', level.name), saved);
    c().start(level, {}, 'u1');
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = _FakeRepo();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        userRepositoryProvider.overrideWithValue(repo),
        firebaseAuthProvider.overrideWithValue(_NoAuth()),
      ],
    );
    container.listen(gameControllerProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  test('new plate starts with "=" in the middle and four digits', () {
    c().start(Difficulty.easy, {}, 'u1');
    expect(s().tokens.whereType<DigitToken>(), hasLength(4));
    expect(s().tokens[2], isA<OpToken>());
    expect((s().tokens[2] as OpToken).op, Op.equals);
  });

  test('typing builds and solves √(8+1)=3**1', () async {
    startWith('8131', Difficulty.intermediate);
    for (final ch in 's(8+1)=3**1'.split('')) {
      c().type(ch);
    }
    expect(plain(s()), 's(8+1)=3**1');
    final result = c().fire();
    expect(result.isCorrect, isTrue);
    expect(s().score, greaterThan(0));
    expect(s().streak, 1);
    expect(s().plate, isNot('8131'));
    await Future<void>.delayed(Duration.zero);
    expect(repo.saved.single.plate, '8131');
    expect(repo.saved.single.latex, r'\sqrt{8 + 1} = 3^{1}');
  });

  test('only one "=": loading it again moves it', () {
    startWith('1234', Difficulty.hard);
    c().type('=');
    c().setCursor(4); // between 3 and 4
    c().type('=');
    expect(plain(s()), '123=4');
  });

  test('smart abs inserts opening then closing bar', () {
    startWith('2534', Difficulty.hard);
    c().press(OpButton.abs); // |2
    c().type('2');
    c().type('-');
    c().type('5');
    c().press(OpButton.abs); // closes
    c().type('=');
    expect(plain(s()), '|2-5|=34');
    final ops = s().tokens.whereType<OpToken>().map((t) => t.op).toList();
    expect(ops.first, Op.absOpen);
    expect(ops[2], Op.absClose);
  });

  test('operators of other levels are rejected', () {
    startWith('9311', Difficulty.hard);
    c().type('s');
    expect(s().event, isA<InvalidKeyEvent>());
    expect(plain(s()), '9311');
  });

  test('backspace removes operators but never digits', () {
    startWith('1234', Difficulty.easy);
    c().setCursor(3); // after "="
    c().backspace();
    expect(plain(s()), '1234');
    c().backspace();
    expect(plain(s()), '1234');
    expect(s().cursor, 1);
  });

  test('wrong answer keeps the plate and reports the error', () {
    startWith('1234', Difficulty.hard);
    final r = c().fire();
    expect(r.isCorrect, isFalse);
    expect(s().error, isNotNull);
    expect(s().plate, '1234');
    expect(s().event, isA<MissEvent>());
  });

  test('skip shows another plate; three bites end the run', () async {
    startWith('1234', Difficulty.easy);
    c().skip();
    expect(s().plate, isNot('1234'));
    expect(s().event, isA<SkipEvent>());
    c().zombieArrived();
    c().zombieArrived();
    expect(s().lives, 1);
    c().zombieArrived();
    expect(s().gameOver, isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(repo.runs, 1);
  });

  test('solved plates are never offered again', () {
    final solved = {
      for (var i = 0; i < 10000; i++)
        if (i != 42) i.toString().padLeft(4, '0'),
    };
    c().start(Difficulty.hard, solved, 'u1');
    expect(s().plate, '0042');
  });

  test('game is saved per user and restored', () {
    startWith('8131', Difficulty.easy);
    c().type('s');
    final other = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        userRepositoryProvider.overrideWithValue(repo),
        firebaseAuthProvider.overrideWithValue(_NoAuth()),
      ],
    );
    addTearDown(other.dispose);
    other.listen(gameControllerProvider, (_, _) {});
    other
        .read(gameControllerProvider.notifier)
        .start(Difficulty.easy, {}, 'u1');
    expect(plain(other.read(gameControllerProvider)!), 's8131');
    other
        .read(gameControllerProvider.notifier)
        .start(Difficulty.easy, {}, 'u2');
    expect(other.read(gameControllerProvider)!.plate, isNot('8131'));
  });
}
