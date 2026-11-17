import 'dart:math' as math;

import 'ast.dart';
import 'difficulty.dart';
import 'parser.dart';
import 'tokens.dart';

/// Searches for an equation that uses the four plate digits (in order).
///
/// The search space is infinite (√√√…), so the solver explores a bounded set
/// of expressions, cheapest first. It may fail to find a solution for very
/// hard plates — exactly the "difficult challenges" of the original game —
/// in which case the player is encouraged to skip the plate.
class Solver {
  Solver(this.digits, this.level, {this.budget = const Duration(seconds: 3)})
    : assert(digits.length >= 2),
      rules = EvalRules.of(level);

  final List<int> digits;
  final Difficulty level;
  final EvalRules rules;
  final Duration budget;

  static const _maxPerRange = 1500;
  static const _maxSingle = 40;

  final _cache = <(int, int), Map<String, Expr>>{};
  final _watch = Stopwatch();

  bool get _timeUp => _watch.elapsed > budget;

  bool _allows(Op op) => level.allows(op);

  /// Returns the cheapest equation found, or `null`.
  Equation? solve() {
    _watch.start();
    Equation? best;
    void consider(Map<String, Expr> l, Map<String, Expr> r) {
      for (final entry in l.entries) {
        final other = r[entry.key];
        if (other == null) continue;
        final candidate = Equation(entry.value, other);
        if (best == null || candidate.cost < best!.cost) best = candidate;
      }
    }

    // Try the balanced split first: it is the cheapest to compute.
    final n = digits.length;
    final splits = [for (var k = 1; k < n; k++) k]
      ..sort((a, b) => (a - n / 2).abs().compareTo((b - n / 2).abs()));
    for (final k in splits) {
      if (_timeUp && best != null) break;
      consider(_range(0, k), _range(k, n));
    }
    return best;
  }

  String _key(double v) =>
      v.abs() < 1e9 ? (v * 1e6).round().toString() : v.toStringAsPrecision(10);

  double? _value(Expr e) {
    try {
      final v = e.eval(rules);
      return v.isFinite ? v : null;
    } on MathError {
      return null;
    }
  }

  static int _prec(Expr e) => switch (e) {
    Num() || Bracket() => 7,
    Unary(kind: UnaryKind.sqrt || UnaryKind.cbrt) => 6,
    Unary(kind: UnaryKind.factorial) => 5,
    Binary(kind: BinaryKind.power) => 4,
    Unary(kind: UnaryKind.negate) => 3,
    Binary(kind: BinaryKind.multiply || BinaryKind.divide) => 2,
    Binary() => 1,
  };

  static Expr _paren(Expr e) => Bracket(BracketKind.paren, e);

  static Expr _atLeast(Expr e, int prec) => _prec(e) >= prec ? e : _paren(e);

  static Expr _noNegate(Expr e) =>
      e is Unary && e.kind == UnaryKind.negate ? _paren(e) : e;

  Expr _binary(BinaryKind kind, Expr a, Expr b) {
    switch (kind) {
      case BinaryKind.add:
      case BinaryKind.subtract:
        return Binary(kind, _atLeast(a, 1), _noNegate(_atLeast(b, 2)));
      case BinaryKind.multiply:
      case BinaryKind.divide:
        return Binary(
          kind,
          _noNegate(_atLeast(a, 2)),
          _noNegate(_atLeast(b, 3)),
        );
      case BinaryKind.power:
        return Binary(kind, _atLeast(a, 5), _atLeast(b, 4));
    }
  }

  void _add(Map<String, Expr> map, Expr e) {
    final v = _value(e);
    if (v == null || v.abs() > 1e12) return;
    final key = _key(v);
    final existing = map[key];
    if (existing == null || e.cost < existing.cost) map[key] = e;
  }

  /// Applies the unary operators of the level to every expression.
  Map<String, Expr> _closure(Map<String, Expr> base, int depth, int cap) {
    var frontier = Map.of(base);
    final all = Map.of(base);
    for (var d = 0; d < depth && !_timeUp; d++) {
      final next = <String, Expr>{};
      for (final e in frontier.values) {
        final v = _value(e);
        if (v == null) continue;
        final asInt = isInteger(v) ? v.round() : null;
        if (!(e is Unary && e.kind == UnaryKind.negate) && v != 0) {
          _add(next, Unary(UnaryKind.negate, _atLeast(e, 4)));
        }
        if (_allows(Op.absOpen) && v < 0) {
          _add(next, Bracket(BracketKind.abs, e));
        }
        if (_allows(Op.factorial) &&
            asInt != null &&
            asInt >= 0 &&
            asInt <= 12 &&
            asInt != 1 &&
            asInt != 2) {
          _add(next, Unary(UnaryKind.factorial, _atLeast(e, 7)));
        }
        if (_allows(Op.sqrt) && v > 1) {
          final r = math.sqrt(v);
          if (!isInteger(r) && _allows(Op.factorial) && r < 13) {
            // (√v)! truncates the inexact root, like the original: (√8)! = 2.
            _add(
              next,
              Unary(UnaryKind.factorial, Unary(UnaryKind.sqrt, _atLeast(e, 6))),
            );
          }
          if (isInteger(r)) {
            _add(next, Unary(UnaryKind.sqrt, _atLeast(e, 6)));
          } else if (_allows(Op.floorOpen)) {
            final root = Unary(UnaryKind.sqrt, _atLeast(e, 6));
            _add(next, Bracket(BracketKind.floor, root));
            _add(next, Bracket(BracketKind.ceil, root));
          }
        }
        if (_allows(Op.cbrt) && v.abs() > 1) {
          final r = math.pow(v.abs(), 1 / 3).toDouble();
          if (!isInteger(r) && _allows(Op.factorial) && v > 0 && r < 13) {
            _add(
              next,
              Unary(UnaryKind.factorial, Unary(UnaryKind.cbrt, _atLeast(e, 6))),
            );
          }
          if (isInteger(r)) {
            _add(next, Unary(UnaryKind.cbrt, _atLeast(e, 6)));
          } else if (_allows(Op.floorOpen)) {
            final root = Unary(UnaryKind.cbrt, _atLeast(e, 6));
            _add(next, Bracket(BracketKind.floor, root));
            _add(next, Bracket(BracketKind.ceil, root));
          }
        }
        if (_allows(Op.floorOpen) && !isInteger(v)) {
          _add(next, Bracket(BracketKind.floor, e));
          _add(next, Bracket(BracketKind.ceil, e));
        }
      }
      frontier = {};
      for (final entry in next.entries) {
        final existing = all[entry.key];
        if (existing == null || entry.value.cost < existing.cost) {
          all[entry.key] = entry.value;
          frontier[entry.key] = entry.value;
        }
      }
    }
    return _trim(all, cap);
  }

  Map<String, Expr> _trim(Map<String, Expr> map, int cap) {
    if (map.length <= cap) return map;
    final sorted = map.entries.toList()
      ..sort((a, b) => a.value.cost.compareTo(b.value.cost));
    return Map.fromEntries(sorted.take(cap));
  }

  /// All values reachable with the digits in `[i, j)`.
  Map<String, Expr> _range(int i, int j) {
    final cached = _cache[(i, j)];
    if (cached != null) return cached;
    final Map<String, Expr> result;
    if (j - i == 1) {
      result = _closure(
        {_key(digits[i].toDouble()): Num(digits[i])},
        2,
        _maxSingle,
      );
    } else {
      final combined = <String, Expr>{};
      for (var m = i + 1; m < j && !_timeUp; m++) {
        final left = _range(i, m);
        final right = _range(m, j);
        for (final a in left.values) {
          if (_timeUp) break;
          for (final b in right.values) {
            _add(combined, _binary(BinaryKind.add, a, b));
            _add(combined, _binary(BinaryKind.subtract, a, b));
            _add(combined, _binary(BinaryKind.multiply, a, b));
            _add(combined, _binary(BinaryKind.divide, a, b));
            if (_allows(Op.power)) {
              _add(combined, _binary(BinaryKind.power, a, b));
            }
          }
        }
      }
      final width = j - i;
      result = _closure(
        _trim(combined, _maxPerRange * 4),
        width >= 3 ? 1 : 1,
        width >= 3 ? _maxPerRange * 4 : _maxPerRange,
      );
    }
    _cache[(i, j)] = result;
    return result;
  }
}

/// Convenience: solves a plate number like "8131" and returns the tokens.
Equation? solvePlate(String plate, Difficulty level) {
  final digits = [for (final c in plate.split('')) int.parse(c)];
  return Solver(digits, level).solve();
}

/// Tokens of an equation (used to double check solver output).
List<Token> equationTokens(Equation eq) => tokensFromPlain(eq.toPlain());
