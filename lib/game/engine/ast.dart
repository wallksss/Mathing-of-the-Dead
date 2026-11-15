import 'dart:math' as math;

import 'difficulty.dart';

/// Every error the engine can report. The UI translates each code.
enum MathErrorCode {
  emptyPlate,
  missingEquals,
  multipleEquals,
  emptySide,
  missingOperator,
  unexpectedToken,
  missingOperand,
  unclosedBracket,
  unmatchedClose,
  operatorNotAllowed,
  divisionByZero,
  nonIntegerDivision,
  negativeSqrt,
  factorialNotInteger,
  factorialNegative,
  factorialTooLarge,
  powerUndefined,
  outOfRange,
  notEqual,
}

class MathError implements Exception {
  const MathError(this.code, {this.tokenIndex, this.left, this.right});

  final MathErrorCode code;

  /// Index (in the plate token list) of the token that caused the error.
  final int? tokenIndex;

  /// Values of both sides, filled for [MathErrorCode.notEqual].
  final double? left;
  final double? right;

  @override
  String toString() => 'MathError($code at $tokenIndex)';
}

/// Rules used during evaluation.
class EvalRules {
  const EvalRules({required this.allowsFractionalDivision});

  factory EvalRules.of(Difficulty d) =>
      EvalRules(allowsFractionalDivision: d.allowsFractionalDivision);

  final bool allowsFractionalDivision;
}

const double _maxMagnitude = 1e100;
const double _minMagnitude = 1e-6;
const int _maxFactorial = 170;

bool isInteger(double v) =>
    v.isFinite && (v - v.roundToDouble()).abs() <= 1e-9 * math.max(1, v.abs());

bool nearlyEqual(double a, double b) =>
    (a - b).abs() <= 1e-9 * math.max(1e-3, math.max(a.abs(), b.abs()));

double _checked(double v, int? at, {bool rejectTiny = false}) {
  if (!v.isFinite || v.abs() > _maxMagnitude) {
    throw MathError(MathErrorCode.outOfRange, tokenIndex: at);
  }
  // Doubles cannot reliably tell 120^-8 apart from 0, so such values are
  // rejected instead of risking a false "correct".
  if (rejectTiny && v != 0 && v.abs() < _minMagnitude) {
    throw MathError(MathErrorCode.outOfRange, tokenIndex: at);
  }
  return v;
}

/// Snaps cancellation noise (e.g. √2·√2 − 2) to exactly zero.
double _snap(double result, double a, double b) =>
    result.abs() <= 1e-9 * math.max(a.abs(), b.abs()) ? 0 : result;

enum UnaryKind { negate, sqrt, cbrt, factorial }

enum BracketKind { paren, abs, floor, ceil }

enum BinaryKind { add, subtract, multiply, divide, power }

/// Expression tree. [at] is the index of the operator token (for errors).
sealed class Expr {
  const Expr({this.at});
  final int? at;

  double eval(EvalRules rules);

  String toLatex();

  /// Plain text (ASCII) representation, re-parseable by the parser.
  String toPlain();

  /// Rough "complexity" used by the solver to prefer simple answers.
  int get cost;

  /// Atoms never need extra parentheses around them.
  bool get isAtomic => false;
}

final class Num extends Expr {
  const Num(this.value, {super.at});
  final int value;

  @override
  double eval(EvalRules rules) => value.toDouble();

  @override
  String toLatex() => '$value';

  @override
  String toPlain() => '$value';

  @override
  int get cost => 0;

  @override
  bool get isAtomic => true;
}

final class Bracket extends Expr {
  const Bracket(this.kind, this.inner, {super.at});
  final BracketKind kind;
  final Expr inner;

  @override
  double eval(EvalRules rules) {
    final v = inner.eval(rules);
    return switch (kind) {
      BracketKind.paren => v,
      BracketKind.abs => v.abs(),
      BracketKind.floor => isInteger(v) ? v.roundToDouble() : v.floorToDouble(),
      BracketKind.ceil => isInteger(v) ? v.roundToDouble() : v.ceilToDouble(),
    };
  }

  @override
  String toLatex() => switch (kind) {
    BracketKind.paren => '\\left(${inner.toLatex()}\\right)',
    BracketKind.abs => '\\left|${inner.toLatex()}\\right|',
    BracketKind.floor => '\\left\\lfloor ${inner.toLatex()}\\right\\rfloor',
    BracketKind.ceil => '\\left\\lceil ${inner.toLatex()}\\right\\rceil',
  };

  @override
  String toPlain() => switch (kind) {
    BracketKind.paren => '(${inner.toPlain()})',
    BracketKind.abs => '|${inner.toPlain()}|',
    BracketKind.floor => '[${inner.toPlain()}]',
    BracketKind.ceil => '{${inner.toPlain()}}',
  };

  @override
  int get cost => inner.cost + (kind == BracketKind.paren ? 0 : 3);

  @override
  bool get isAtomic => true;
}

/// Removes one level of plain parentheses (√(8+1) is rendered as \sqrt{8+1}).
Expr _stripParen(Expr e) =>
    e is Bracket && e.kind == BracketKind.paren ? e.inner : e;

final class Unary extends Expr {
  const Unary(this.kind, this.operand, {super.at});
  final UnaryKind kind;
  final Expr operand;

  @override
  double eval(EvalRules rules) {
    final v = operand.eval(rules);
    switch (kind) {
      case UnaryKind.negate:
        return -v;
      case UnaryKind.sqrt:
        if (v < 0 && !nearlyEqual(v, 0)) {
          throw MathError(MathErrorCode.negativeSqrt, tokenIndex: at);
        }
        return math.sqrt(math.max(0, v));
      case UnaryKind.cbrt:
        final r = math.pow(v.abs(), 1 / 3).toDouble();
        // Snap to the exact integer root when there is one (∛27 = 3).
        final rounded = r.roundToDouble();
        final root = nearlyEqual(rounded * rounded * rounded, v.abs())
            ? rounded
            : r;
        return v < 0 ? -root : root;
      case UnaryKind.factorial:
        if (!isInteger(v)) {
          throw MathError(MathErrorCode.factorialNotInteger, tokenIndex: at);
        }
        final n = v.round();
        if (n < 0) {
          throw MathError(MathErrorCode.factorialNegative, tokenIndex: at);
        }
        if (n > _maxFactorial) {
          throw MathError(MathErrorCode.factorialTooLarge, tokenIndex: at);
        }
        var result = 1.0;
        for (var i = 2; i <= n; i++) {
          result *= i;
        }
        return result;
    }
  }

  @override
  String toLatex() => switch (kind) {
    UnaryKind.negate => '-${operand.toLatex()}',
    UnaryKind.sqrt => '\\sqrt{${_stripParen(operand).toLatex()}}',
    UnaryKind.cbrt => '\\sqrt[3]{${_stripParen(operand).toLatex()}}',
    UnaryKind.factorial => '${operand.toLatex()}!',
  };

  @override
  String toPlain() => switch (kind) {
    UnaryKind.negate => '-${operand.toPlain()}',
    UnaryKind.sqrt => 's${operand.toPlain()}',
    UnaryKind.cbrt => 'c${operand.toPlain()}',
    UnaryKind.factorial => '${operand.toPlain()}!',
  };

  @override
  int get cost => operand.cost + (kind == UnaryKind.negate ? 1 : 2);

  @override
  bool get isAtomic => kind == UnaryKind.factorial;
}

final class Binary extends Expr {
  const Binary(this.kind, this.left, this.right, {super.at});
  final BinaryKind kind;
  final Expr left;
  final Expr right;

  @override
  double eval(EvalRules rules) {
    final a = left.eval(rules);
    final b = right.eval(rules);
    switch (kind) {
      case BinaryKind.add:
        return _checked(_snap(a + b, a, b), at);
      case BinaryKind.subtract:
        return _checked(_snap(a - b, a, b), at);
      case BinaryKind.multiply:
        return _checked(a * b, at);
      case BinaryKind.divide:
        if (b.abs() < 1e-12) {
          throw MathError(MathErrorCode.divisionByZero, tokenIndex: at);
        }
        final q = a / b;
        if (!rules.allowsFractionalDivision && !isInteger(q)) {
          throw MathError(MathErrorCode.nonIntegerDivision, tokenIndex: at);
        }
        return _checked(
          isInteger(q) ? q.roundToDouble() : q,
          at,
          rejectTiny: true,
        );
      case BinaryKind.power:
        if (a.abs() < 1e-12 && b <= 0) {
          throw MathError(MathErrorCode.powerUndefined, tokenIndex: at);
        }
        if (a < 0 && !isInteger(b)) {
          throw MathError(MathErrorCode.powerUndefined, tokenIndex: at);
        }
        if (b.abs() * math.log(math.max(a.abs(), 1e-300)) / math.ln10 > 100) {
          throw MathError(MathErrorCode.outOfRange, tokenIndex: at);
        }
        final exponent = isInteger(b) ? b.roundToDouble() : b;
        return _checked(math.pow(a, exponent).toDouble(), at, rejectTiny: true);
    }
  }

  @override
  String toLatex() {
    switch (kind) {
      case BinaryKind.add:
        return '${left.toLatex()} + ${right.toLatex()}';
      case BinaryKind.subtract:
        return '${left.toLatex()} - ${right.toLatex()}';
      case BinaryKind.multiply:
        return '${left.toLatex()} \\times ${right.toLatex()}';
      case BinaryKind.divide:
        return '\\frac{${_stripParen(left).toLatex()}}'
            '{${_stripParen(right).toLatex()}}';
      case BinaryKind.power:
        final base = left is Num || left is Bracket
            ? left.toLatex()
            : '{${left.toLatex()}}';
        return '$base^{${_stripParen(right).toLatex()}}';
    }
  }

  @override
  String toPlain() {
    final op = switch (kind) {
      BinaryKind.add => '+',
      BinaryKind.subtract => '-',
      BinaryKind.multiply => '*',
      BinaryKind.divide => '/',
      BinaryKind.power => '**',
    };
    return '${left.toPlain()}$op${right.toPlain()}';
  }

  @override
  int get cost => left.cost + right.cost + (kind == BinaryKind.power ? 2 : 1);
}

/// A full equation `left = right`.
class Equation {
  const Equation(this.left, this.right);
  final Expr left;
  final Expr right;

  String toLatex() => '${left.toLatex()} = ${right.toLatex()}';

  String toPlain() => '${left.toPlain()}=${right.toPlain()}';

  int get cost => left.cost + right.cost;
}
