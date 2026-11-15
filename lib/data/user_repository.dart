import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/engine/difficulty.dart';
import 'models.dart';

/// All reads and writes to Cloud Firestore.
///
/// ```
/// users/{uid}                       PlayerProfile
/// users/{uid}/solved/{level}_{0042} SolveRecord
/// ```
class UserRepository {
  UserRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _solved(String uid) =>
      _user(uid).collection('solved');

  /// Loads (and creates on first access) the profile of [user].
  Future<PlayerProfile> loadProfile(User user) async {
    final ref = _user(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      final nickname = _defaultNickname(user);
      await ref.set({
        'nickname': nickname,
        'score': 0,
        'solved': 0,
        'bestStreak': 0,
        'bestRun': 0,
        'solvedByLevel': <String, int>{},
        'createdAt': FieldValue.serverTimestamp(),
      });
      return PlayerProfile(uid: user.uid, nickname: nickname);
    }
    return PlayerProfile.fromDoc(user.uid, snap.data());
  }

  /// First name from the Google account; empty for e-mail accounts (the UI
  /// then shows a translated "anonymous survivor").
  String _defaultNickname(User user) =>
      user.displayName?.trim().split(' ').first ?? '';

  /// Plates (e.g. "0427") already solved by the player at [level].
  Future<Set<String>> solvedPlates(String uid, Difficulty level) async {
    final query = await _solved(uid)
        .where('level', isEqualTo: level.name)
        .get();
    return {for (final d in query.docs) d.data()['plate'] as String};
  }

  /// Stores a solved plate and updates the player's totals atomically.
  Future<void> recordSolve(
    String uid,
    SolveRecord record, {
    required int streak,
  }) async {
    final batch = _db.batch();
    batch.set(_solved(uid).doc(record.docId), record.toMap());
    batch.set(_user(uid), {
      'score': FieldValue.increment(record.points),
      'solved': FieldValue.increment(1),
      'solvedByLevel': {record.level.name: FieldValue.increment(1)},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
    if (streak > 0) await _raise(uid, 'bestStreak', streak);
  }

  /// Saves the run score if it is the player's best.
  Future<void> recordRun(String uid, int runScore) =>
      _raise(uid, 'bestRun', runScore);

  Future<void> _raise(String uid, String field, int value) =>
      _db.runTransaction((tx) async {
        final snap = await tx.get(_user(uid));
        final current = (snap.data()?[field] as num?)?.toInt() ?? 0;
        if (value > current) {
          tx.set(_user(uid), {field: value}, SetOptions(merge: true));
        }
      });

  /// Most recent solved plates (newest first).
  Future<List<SolveRecord>> history(String uid, {int limit = 300}) async {
    final query = await _solved(uid)
        .orderBy('solvedAt', descending: true)
        .limit(limit)
        .get();
    return [for (final d in query.docs) SolveRecord.fromDoc(d.data())];
  }

  /// Top players by total score.
  Future<List<RankingEntry>> ranking({int limit = 50}) async {
    final query = await _db
        .collection('users')
        .orderBy('score', descending: true)
        .limit(limit)
        .get();
    return [
      for (final d in query.docs)
        RankingEntry(
          uid: d.id,
          nickname: (d.data()['nickname'] as String?) ?? '',
          score: (d.data()['score'] as num?)?.toInt() ?? 0,
          solved: (d.data()['solved'] as num?)?.toInt() ?? 0,
        ),
    ];
  }

  Future<void> updateNickname(String uid, String nickname) =>
      _user(uid).set({'nickname': nickname.trim()}, SetOptions(merge: true));
}

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (_) => FirebaseAuth.instance,
);

final userRepositoryProvider = Provider<UserRepository>(
  (_) => UserRepository(FirebaseFirestore.instance),
);

/// The signed-in user (null when signed out).
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).userChanges(),
);

/// Current user, read synchronously.
final currentUserProvider = Provider<User?>(
  (ref) =>
      ref.watch(authStateProvider).value ??
      ref.watch(firebaseAuthProvider).currentUser,
);

/// Bumped after every Firestore write so pages can reload their data.
class DataVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final dataVersionProvider = NotifierProvider<DataVersion, int>(DataVersion.new);
