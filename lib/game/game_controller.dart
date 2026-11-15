import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/prefs.dart';
import '../data/models.dart';
import '../data/user_repository.dart';
import '../settings/app_settings.dart';
import 'engine/ast.dart';
import 'engine/difficulty.dart';
import 'engine/parser.dart';
import 'engine/tokens.dart';

const maxLives = 3;

/// One-shot events the UI reacts to (sounds, animations, snackbars).
sealed class GameEvent {
  GameEvent() : serial = _serial++;
  static int _serial = 0;
  final int serial;
}

class HitEvent extends GameEvent {
  HitEvent(this.points, this.latex);
  final int points;
  final String latex;
}

class MissEvent extends GameEvent {
  MissEvent(this.error);
  final MathError error;
}

class BittenEvent extends GameEvent {
  BittenEvent(this.plate, this.level);
  final String plate;
  final Difficulty level;
}

class SkipEvent extends GameEvent {}

class InvalidKeyEvent extends GameEvent {}

class SaveFailedEvent extends GameEvent {
  SaveFailedEvent(this.message);
  final String message;
}

@immutable
class GameState {
  const GameState({
    required this.level,
    required this.plate,
    required this.tokens,
    required this.cursor,
    required this.plateSerial,
    this.score = 0,
    this.lives = maxLives,
    this.streak = 0,
    this.solvedThisRun = 0,
    this.usedHint = false,
    this.error,
    this.gameOver = false,
    this.allSolved = false,
    this.event,
    this.initialProgress = 0,
  });

  final Difficulty level;

  /// The four digits, e.g. "0427".
  final String plate;
  final List<Token> tokens;

  /// Insertion point: 0 = before the first token.
  final int cursor;

  /// Changes every time a new zombie appears.
  final int plateSerial;
  final int score;
  final int lives;
  final int streak;
  final int solvedThisRun;
  final bool usedHint;

  /// Last error, highlighted on the plate until the player edits it.
  final MathError? error;
  final bool gameOver;
  final bool allSolved;
  final GameEvent? event;

  /// Zombie progress restored from a saved game (0..1).
  final double initialProgress;

  String get latex => plateToLatex(tokens);

  String get display => tokensToDisplay(tokens);

  GameState copyWith({
    String? plate,
    List<Token>? tokens,
    int? cursor,
    int? plateSerial,
    int? score,
    int? lives,
    int? streak,
    int? solvedThisRun,
    bool? usedHint,
    MathError? error,
    bool clearError = false,
    bool? gameOver,
    bool? allSolved,
    GameEvent? event,
    double? initialProgress,
  }) => GameState(
    level: level,
    plate: plate ?? this.plate,
    tokens: tokens ?? this.tokens,
    cursor: cursor ?? this.cursor,
    plateSerial: plateSerial ?? this.plateSerial,
    score: score ?? this.score,
    lives: lives ?? this.lives,
    streak: streak ?? this.streak,
    solvedThisRun: solvedThisRun ?? this.solvedThisRun,
    usedHint: usedHint ?? this.usedHint,
    error: clearError ? null : (error ?? this.error),
    gameOver: gameOver ?? this.gameOver,
    allSolved: allSolved ?? this.allSolved,
    event: event ?? this.event,
    initialProgress: initialProgress ?? this.initialProgress,
  );
}

/// Game logic for one level. Created by [GameController.start] once the set
/// of solved plates has been loaded from Firestore.
class GameController extends Notifier<GameState?> {
  final _random = math.Random();
  int _nextId = 1000;
  Set<String> _solved = {};
  final Set<String> _skipped = {};
  double _progress = 0;
  String? _uid;

  @override
  GameState? build() => null;

  // ---------------------------------------------------------------- setup

  /// Starts (or resumes, if a game was saved) a game at [level].
  void start(Difficulty level, Set<String> solved, String uid) {
    _solved = {...solved};
    _uid = uid;
    final restored = _restore(level);
    if (restored != null && !_solved.contains(restored.plate)) {
      state = restored;
      _progress = restored.initialProgress;
      return;
    }
    state = _fresh(level);
  }

  GameState _fresh(Difficulty level, {int serial = 0}) {
    final plate = _pickPlate(exclude: null);
    return GameState(
      level: level,
      plate: plate ?? '0000',
      tokens: plate == null ? const [] : _initialTokens(plate),
      cursor: 0,
      plateSerial: serial,
      allSolved: plate == null,
    );
  }

  String? _pickPlate({String? exclude}) {
    if (_solved.length >= 10000) return null;
    final blocked = {..._solved, ..._skipped, ?exclude};
    if (blocked.length >= 10000) {
      // Every unsolved plate was skipped: let skipped ones come back.
      _skipped.clear();
      blocked
        ..clear()
        ..addAll({..._solved, ?exclude});
    }
    while (true) {
      final candidate = _random.nextInt(10000).toString().padLeft(4, '0');
      if (!blocked.contains(candidate)) return candidate;
    }
  }

  /// The four digits with the "=" already loaded in the middle: the equals
  /// sign is always needed, so the player starts with it in place (and can
  /// move it anywhere).
  List<Token> _initialTokens(String plate) {
    final digits = [
      for (final c in plate.split('')) DigitToken(_id(), int.parse(c)),
    ];
    return [
      digits[0],
      digits[1],
      OpToken(_id(), Op.equals),
      digits[2],
      digits[3],
    ];
  }

  int _id() => _nextId++;

  // ------------------------------------------------------------- editing

  GameState get _s => state!;

  void _edit(List<Token> tokens, int cursor) {
    state = _s.copyWith(tokens: tokens, cursor: cursor, clearError: true);
    _save();
  }

  void setCursor(int cursor) {
    if (state == null) return;
    state = _s.copyWith(cursor: cursor.clamp(0, _s.tokens.length));
  }

  void moveCursor(int delta) => setCursor(_s.cursor + delta);

  /// Inserts the operator of [button] at the cursor.
  void press(OpButton button) {
    if (state == null || _s.gameOver) return;
    if (!_s.level.buttons.contains(button)) {
      state = _s.copyWith(event: InvalidKeyEvent());
      return;
    }
    final op = button.ops.length == 1
        ? button.ops.first
        : _smartBracket(button);
    insert(op);
  }

  /// Opening or closing bracket for the single-button pairs (|x|, ⌊x⌋, ⌈x⌉).
  Op _smartBracket(OpButton button) {
    final open = button.ops.first;
    final close = button.ops.last;
    final before = _s.tokens.take(_s.cursor).toList();
    var depth = 0;
    for (final t in before) {
      if (t is OpToken && t.op == open) depth++;
      if (t is OpToken && t.op == close) depth--;
    }
    final prev = before.isEmpty ? null : before.last;
    return depth > 0 && endsOperand(prev) ? close : open;
  }

  void insert(Op op) {
    if (state == null || _s.gameOver) return;
    if (!_s.level.allows(op)) {
      state = _s.copyWith(event: InvalidKeyEvent());
      return;
    }
    final tokens = [..._s.tokens];
    var cursor = _s.cursor;
    if (op == Op.equals) {
      // Only one "=": loading it again moves it.
      final existing = tokens.indexWhere(
        (t) => t is OpToken && t.op == Op.equals,
      );
      if (existing >= 0) {
        tokens.removeAt(existing);
        if (existing < cursor) cursor--;
      }
    }
    tokens.insert(cursor, OpToken(_id(), op));
    _edit(tokens, cursor + 1);
  }

  /// Keyboard input ("typing of the dead"). Returns false if ignored.
  bool type(String ch) {
    if (state == null || _s.gameOver) return false;
    final digit = int.tryParse(ch);
    if (digit != null) return _typeDigit(digit);
    final Op? op = switch (ch) {
      '+' => Op.plus,
      '-' => Op.minus,
      '/' => Op.divide,
      '(' => Op.lparen,
      ')' => Op.rparen,
      '!' => Op.factorial,
      '=' => Op.equals,
      '^' => Op.power,
      's' || 'S' || 'r' || 'R' => Op.sqrt,
      'c' || 'C' => Op.cbrt,
      '[' => Op.floorOpen,
      ']' => Op.floorClose,
      '{' => Op.ceilOpen,
      '}' => Op.ceilClose,
      _ => null,
    };
    if (ch == '*' || ch == 'x' || ch == 'X') {
      final prev = _s.cursor > 0 ? _s.tokens[_s.cursor - 1] : null;
      if (ch == '*' && prev is OpToken && prev.op == Op.times) {
        // "**" typed: upgrade the multiplication to a power.
        if (!_s.level.allows(Op.power)) {
          state = _s.copyWith(event: InvalidKeyEvent());
          return true;
        }
        final tokens = [..._s.tokens];
        tokens[_s.cursor - 1] = OpToken(_id(), Op.power);
        _edit(tokens, _s.cursor);
        return true;
      }
      insert(Op.times);
      return true;
    }
    if (ch == '|') {
      press(OpButton.abs);
      return true;
    }
    if (op == null) return false;
    insert(op);
    return true;
  }

  /// Typing the next digit of the plate just moves the cursor past it.
  bool _typeDigit(int digit) {
    for (var i = _s.cursor; i < _s.tokens.length; i++) {
      final t = _s.tokens[i];
      if (t is DigitToken) {
        if (t.value == digit) {
          setCursor(i + 1);
          return true;
        }
        break;
      }
    }
    state = _s.copyWith(event: InvalidKeyEvent());
    return true;
  }

  void backspace() {
    if (state == null || _s.cursor == 0) return;
    final prev = _s.tokens[_s.cursor - 1];
    if (prev is DigitToken) {
      moveCursor(-1);
      return;
    }
    final tokens = [..._s.tokens]..removeAt(_s.cursor - 1);
    _edit(tokens, _s.cursor - 1);
  }

  void deleteForward() {
    if (state == null || _s.cursor >= _s.tokens.length) return;
    final next = _s.tokens[_s.cursor];
    if (next is DigitToken) {
      moveCursor(1);
      return;
    }
    final tokens = [..._s.tokens]..removeAt(_s.cursor);
    _edit(tokens, _s.cursor);
  }

  /// Removes the operator with [id] (tapped on the plate).
  void removeToken(int id) {
    if (state == null) return;
    final index = _s.tokens.indexWhere((t) => t.id == id);
    if (index < 0 || _s.tokens[index] is DigitToken) return;
    final tokens = [..._s.tokens]..removeAt(index);
    final cursor = _s.cursor > index ? _s.cursor - 1 : _s.cursor;
    _edit(tokens, cursor);
  }

  /// Sends every operator back to the belt (digits stay).
  void clear() {
    if (state == null) return;
    final digits = _s.tokens.whereType<DigitToken>().toList();
    _edit(digits, 0);
  }

  // ------------------------------------------------------------- actions

  /// Checks the plate. On success the zombie is shot and a new one appears.
  CheckResult fire() {
    final s = _s;
    final result = checkPlate(s.tokens, s.level);
    if (!result.isCorrect) {
      state = s.copyWith(
        error: result.error,
        streak: 0,
        event: MissEvent(result.error!),
      );
      _save();
      return result;
    }
    final points = _points(s);
    final record = SolveRecord(
      level: s.level,
      plate: s.plate,
      expression: s.display,
      latex: result.equation!.toLatex(),
      points: points,
      usedHint: s.usedHint,
    );
    _solved.add(s.plate);
    final streak = s.streak + 1;
    _persistSolve(record, streak);
    final next = _pickPlate(exclude: s.plate);
    state = s.copyWith(
      plate: next ?? s.plate,
      tokens: next == null ? const [] : _initialTokens(next),
      cursor: 0,
      plateSerial: s.plateSerial + 1,
      score: s.score + points,
      streak: streak,
      solvedThisRun: s.solvedThisRun + 1,
      usedHint: false,
      clearError: true,
      allSolved: next == null,
      event: HitEvent(points, record.latex),
      initialProgress: 0,
    );
    _progress = 0;
    _save();
    return result;
  }

  int _points(GameState s) {
    final speed = ref.read(settingsProvider).zombieSpeed;
    final timeBonus = speed == ZombieSpeed.off ? 0.0 : 0.5 * (1 - _progress);
    final streakBonus = 1 + 0.1 * math.min(s.streak, 10);
    final hintFactor = s.usedHint ? 0.25 : 1.0;
    return math.max(
      1,
      (s.level.basePoints * (1 + timeBonus) * streakBonus * hintFactor).round(),
    );
  }

  Future<void> _persistSolve(SolveRecord record, int streak) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await ref
          .read(userRepositoryProvider)
          .recordSolve(uid, record, streak: streak);
      ref.read(dataVersionProvider.notifier).bump();
    } catch (e) {
      if (state != null) {
        state = _s.copyWith(event: SaveFailedEvent('$e'));
      }
    }
  }

  void useHint() {
    if (state == null) return;
    state = _s.copyWith(usedHint: true);
    _save();
  }

  /// The player gives up on this plate: a new zombie appears (no penalty
  /// besides losing the streak).
  void skip() {
    if (state == null || _s.gameOver) return;
    _skipped.add(_s.plate);
    _nextPlate(event: SkipEvent(), streak: 0);
  }

  /// The zombie reached the player.
  void zombieArrived() {
    if (state == null || _s.gameOver) return;
    final s = _s;
    final lives = s.lives - 1;
    final event = BittenEvent(s.plate, s.level);
    if (lives <= 0) {
      state = s.copyWith(lives: 0, gameOver: true, streak: 0, event: event);
      _clearSave();
      final uid = _uid;
      if (uid != null) {
        ref
            .read(userRepositoryProvider)
            .recordRun(uid, s.score)
            .catchError(
              (Object e) => state = _s.copyWith(event: SaveFailedEvent('$e')),
            );
      }
      return;
    }
    _skipped.add(s.plate);
    state = s.copyWith(lives: lives);
    _nextPlate(event: event, streak: 0);
  }

  void _nextPlate({required GameEvent event, required int streak}) {
    final s = _s;
    final next = _pickPlate(exclude: s.plate);
    state = s.copyWith(
      plate: next ?? s.plate,
      tokens: next == null ? const [] : _initialTokens(next),
      cursor: 0,
      plateSerial: s.plateSerial + 1,
      streak: streak,
      usedHint: false,
      clearError: true,
      allSolved: next == null,
      event: event,
      initialProgress: 0,
    );
    _progress = 0;
    _save();
  }

  void restart() {
    if (state == null) return;
    state = _fresh(_s.level, serial: _s.plateSerial + 1);
    _progress = 0;
    _save();
  }

  /// Called by the zombie animation so the game can be resumed later.
  void reportProgress(double progress) {
    _progress = progress;
    _save();
  }

  // --------------------------------------------------------- persistence

  void _save() {
    final s = state;
    if (s == null || s.gameOver) return;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(
      PrefKeys.game(_uid ?? '', s.level.name),
      jsonEncode({
        'plate': s.plate,
        'tokens': [
          for (final t in s.tokens)
            switch (t) {
              DigitToken(:final value) => '$value',
              OpToken(:final op) => op.name,
            },
        ],
        'cursor': s.cursor,
        'score': s.score,
        'lives': s.lives,
        'streak': s.streak,
        'solvedThisRun': s.solvedThisRun,
        'usedHint': s.usedHint,
        'progress': _progress,
        'serial': s.plateSerial,
      }),
    );
  }

  void _clearSave() {
    final s = state;
    if (s == null) return;
    ref
        .read(sharedPreferencesProvider)
        .remove(PrefKeys.game(_uid ?? '', s.level.name));
  }

  GameState? _restore(Difficulty level) {
    final raw = ref
        .read(sharedPreferencesProvider)
        .getString(PrefKeys.game(_uid ?? '', level.name));
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final plate = m['plate'] as String;
      final tokens = <Token>[
        for (final raw in (m['tokens'] as List).cast<String>())
          int.tryParse(raw) != null
              ? DigitToken(_id(), int.parse(raw))
              : OpToken(_id(), Op.values.byName(raw)),
      ];
      final digits = tokens.whereType<DigitToken>().map((d) => d.value).join();
      if (digits != plate) return null;
      return GameState(
        level: level,
        plate: plate,
        tokens: tokens,
        cursor: (m['cursor'] as int).clamp(0, tokens.length),
        plateSerial: m['serial'] as int? ?? 0,
        score: m['score'] as int? ?? 0,
        lives: (m['lives'] as int? ?? maxLives).clamp(1, maxLives),
        streak: m['streak'] as int? ?? 0,
        solvedThisRun: m['solvedThisRun'] as int? ?? 0,
        usedHint: m['usedHint'] as bool? ?? false,
        initialProgress: (m['progress'] as num? ?? 0).toDouble().clamp(0, 0.95),
      );
    } catch (_) {
      return null;
    }
  }
}

final gameControllerProvider =
    NotifierProvider.autoDispose<GameController, GameState?>(
      GameController.new,
    );
