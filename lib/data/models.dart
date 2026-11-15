import 'package:cloud_firestore/cloud_firestore.dart';

import '../game/engine/difficulty.dart';

/// Player profile stored at `users/{uid}`.
class PlayerProfile {
  const PlayerProfile({
    required this.uid,
    required this.nickname,
    this.score = 0,
    this.solved = 0,
    this.bestStreak = 0,
    this.bestRun = 0,
    this.solvedByLevel = const {},
  });

  factory PlayerProfile.fromDoc(String uid, Map<String, dynamic>? data) {
    final d = data ?? const {};
    final byLevel =
        (d['solvedByLevel'] as Map?)?.map(
          (k, v) => MapEntry(k as String, (v as num).toInt()),
        ) ??
        const <String, int>{};
    return PlayerProfile(
      uid: uid,
      nickname: (d['nickname'] as String?) ?? '',
      score: (d['score'] as num?)?.toInt() ?? 0,
      solved: (d['solved'] as num?)?.toInt() ?? 0,
      bestStreak: (d['bestStreak'] as num?)?.toInt() ?? 0,
      bestRun: (d['bestRun'] as num?)?.toInt() ?? 0,
      solvedByLevel: byLevel,
    );
  }

  final String uid;
  final String nickname;
  final int score;
  final int solved;
  final int bestStreak;
  final int bestRun;
  final Map<String, int> solvedByLevel;

  int solvedAt(Difficulty level) => solvedByLevel[level.name] ?? 0;
}

/// A plate the player solved, stored at `users/{uid}/solved/{level}_{plate}`.
class SolveRecord {
  const SolveRecord({
    required this.level,
    required this.plate,
    required this.expression,
    required this.latex,
    required this.points,
    required this.usedHint,
    this.solvedAt,
  });

  factory SolveRecord.fromDoc(Map<String, dynamic> d) => SolveRecord(
    level: Difficulty.fromName(d['level'] as String?),
    plate: d['plate'] as String? ?? '????',
    expression: d['expression'] as String? ?? '',
    latex: d['latex'] as String? ?? '',
    points: (d['points'] as num?)?.toInt() ?? 0,
    usedHint: d['usedHint'] as bool? ?? false,
    solvedAt: (d['solvedAt'] as Timestamp?)?.toDate(),
  );

  final Difficulty level;
  final String plate;

  /// Expression as the player built it, e.g. `√(8 + 1) = 3**1`.
  final String expression;
  final String latex;
  final int points;
  final bool usedHint;
  final DateTime? solvedAt;

  String get docId => '${level.name}_$plate';

  Map<String, dynamic> toMap() => {
    'level': level.name,
    'plate': plate,
    'expression': expression,
    'latex': latex,
    'points': points,
    'usedHint': usedHint,
    'solvedAt': FieldValue.serverTimestamp(),
  };
}

/// One line of the ranking.
class RankingEntry {
  const RankingEntry({
    required this.uid,
    required this.nickname,
    required this.score,
    required this.solved,
  });

  final String uid;
  final String nickname;
  final int score;
  final int solved;
}
