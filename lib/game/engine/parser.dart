import 'ast.dart';
import 'difficulty.dart';
import 'tokens.dart';

/// Result of checking a plate.
class CheckResult {
  const CheckResult._({this.equation, this.error, this.left, this.right});

  factory CheckResult.ok(Equation eq, double l, double r) =>
      CheckResult._(equation: eq, left: l, right: r);

  factory CheckResult.fail(MathError e, [Equation? eq]) =>
      CheckResult._(error: e, equation: eq);

  final Equation? equation;
  final MathError? error;
  final double? left;
  final double? right;

  bool get isCorrect => error == null && equation != null;
}

/// Recursive-descent parser over the plate tokens.
///
/// Grammar (highest precedence last):
/// ```
/// equation := expr '=' expr
/// expr     := term (('+' | '-') term)*
/// term     := unary (('*' | '/') unary)*
/// unary    := '-' unary | power
/// power    := root ('**' unary)?          (right associative)
/// root     := ('√' | '∛') root | postfix
/// postfix  := atom '!'*
/// atom     := digit | '(' expr ')' | '|' expr '|' | '⌊' expr '⌋' | '⌈' expr '⌉'
/// ```
/// Two numbers next to each other without an operator are an error: the
/// digits of the plate are never concatenated.
class _Parser {
  _Parser(this.tokens, this.start, this.end) : pos = start;

  final List<Token> tokens;
  final int start;
  final int end;
  int pos;

  bool get atEnd => pos >= end;

  Token? get current => atEnd ? null : tokens[pos];

  Op? get currentOp {
    final t = current;
    return t is OpToken ? t.op : null;
  }

  int get _lastIndex => end - 1 < start ? start : end - 1;

  Expr parseAll() {
    final e = _expr();
    if (!atEnd) {
      _unexpected();
    }
    return e;
  }

  Never _unexpected() {
    final t = current;
    if (t is DigitToken) {
      throw MathError(MathErrorCode.missingOperator, tokenIndex: pos);
    }
    final op = (t as OpToken).op;
    if (op.isOpening || op == Op.sqrt || op == Op.cbrt) {
      throw MathError(MathErrorCode.missingOperator, tokenIndex: pos);
    }
    if (op.isClosing) {
      throw MathError(MathErrorCode.unmatchedClose, tokenIndex: pos);
    }
    throw MathError(MathErrorCode.unexpectedToken, tokenIndex: pos);
  }

  Expr _expr() {
    var left = _term();
    while (currentOp == Op.plus || currentOp == Op.minus) {
      final at = pos;
      final kind = currentOp == Op.plus ? BinaryKind.add : BinaryKind.subtract;
      pos++;
      left = Binary(kind, left, _term(), at: at);
    }
    return left;
  }

  Expr _term() {
    var left = _unary();
    while (currentOp == Op.times || currentOp == Op.divide) {
      final at = pos;
      final kind = currentOp == Op.times
          ? BinaryKind.multiply
          : BinaryKind.divide;
      pos++;
      left = Binary(kind, left, _unary(), at: at);
    }
    return left;
  }

  Expr _unary() {
    if (currentOp == Op.minus) {
      final at = pos;
      pos++;
      return Unary(UnaryKind.negate, _unary(), at: at);
    }
    return _power();
  }

  Expr _power() {
    final base = _root();
    if (currentOp == Op.power) {
      final at = pos;
      pos++;
      return Binary(BinaryKind.power, base, _unary(), at: at);
    }
    return base;
  }

  Expr _root() {
    if (currentOp == Op.sqrt || currentOp == Op.cbrt) {
      final at = pos;
      final kind = currentOp == Op.sqrt ? UnaryKind.sqrt : UnaryKind.cbrt;
      pos++;
      return Unary(kind, _root(), at: at);
    }
    return _postfix();
  }

  Expr _postfix() {
    var e = _atom();
    while (currentOp == Op.factorial) {
      e = Unary(UnaryKind.factorial, e, at: pos);
      pos++;
    }
    return e;
  }

  Expr _atom() {
    final t = current;
    if (t == null) {
      throw MathError(MathErrorCode.missingOperand, tokenIndex: _lastIndex);
    }
    if (t is DigitToken) {
      pos++;
      return Num(t.value, at: pos - 1);
    }
    final op = (t as OpToken).op;
    if (op.isOpening) {
      final openAt = pos;
      pos++;
      final inner = _expr();
      final closing = currentOp;
      if (atEnd) {
        throw MathError(MathErrorCode.unclosedBracket, tokenIndex: openAt);
      }
      if (closing != op.partner) {
        if (closing != null && closing.isClosing) {
          throw MathError(MathErrorCode.unmatchedClose, tokenIndex: pos);
        }
        _unexpected();
      }
      pos++;
      final kind = switch (op) {
        Op.lparen => BracketKind.paren,
        Op.absOpen => BracketKind.abs,
        Op.floorOpen => BracketKind.floor,
        _ => BracketKind.ceil,
      };
      return Bracket(kind, inner, at: openAt);
    }
    if (op.isClosing) {
      throw MathError(MathErrorCode.missingOperand, tokenIndex: pos);
    }
    throw MathError(MathErrorCode.missingOperand, tokenIndex: pos);
  }
}

/// Parses one side of the equation (tokens in `[start, end)`).
Expr parseSide(List<Token> tokens, int start, int end) {
  if (start >= end) {
    throw MathError(
      MathErrorCode.emptySide,
      tokenIndex: start < tokens.length ? start : tokens.length - 1,
    );
  }
  return _Parser(tokens, start, end).parseAll();
}

/// Parses the full plate into an [Equation] (structure only).
Equation parseEquation(List<Token> tokens, Difficulty level) {
  if (tokens.isEmpty) throw const MathError(MathErrorCode.emptyPlate);
  for (var i = 0; i < tokens.length; i++) {
    final t = tokens[i];
    if (t is OpToken && !level.allows(t.op)) {
      throw MathError(MathErrorCode.operatorNotAllowed, tokenIndex: i);
    }
  }
  final equals = <int>[
    for (var i = 0; i < tokens.length; i++)
      if (tokens[i] case OpToken(op: Op.equals)) i,
  ];
  if (equals.isEmpty) throw const MathError(MathErrorCode.missingEquals);
  if (equals.length > 1) {
    throw MathError(MathErrorCode.multipleEquals, tokenIndex: equals[1]);
  }
  final eq = equals.single;
  if (eq == 0 || eq == tokens.length - 1) {
    throw MathError(MathErrorCode.emptySide, tokenIndex: eq);
  }
  return Equation(
    parseSide(tokens, 0, eq),
    parseSide(tokens, eq + 1, tokens.length),
  );
}

/// Parses and evaluates the plate. Never throws.
CheckResult checkPlate(List<Token> tokens, Difficulty level) {
  Equation? eq;
  try {
    eq = parseEquation(tokens, level);
    final rules = EvalRules.of(level);
    final l = eq.left.eval(rules);
    final r = eq.right.eval(rules);
    if (!nearlyEqual(l, r)) {
      return CheckResult.fail(
        MathError(MathErrorCode.notEqual, left: l, right: r),
        eq,
      );
    }
    return CheckResult.ok(eq, l, r);
  } on MathError catch (e) {
    return CheckResult.fail(e, eq);
  }
}

String _tokenLatex(Token t) {
  if (t is DigitToken) return '${t.value}';
  return switch ((t as OpToken).op) {
    Op.plus => '+',
    Op.minus => '-',
    Op.times => '\\times',
    Op.divide => '\\div',
    Op.power => '\\ast\\ast',
    Op.lparen => '(',
    Op.rparen => ')',
    Op.sqrt => '\\surd',
    Op.cbrt => '\\sqrt[3]{\\,}',
    Op.factorial => '!',
    Op.absOpen || Op.absClose => '|',
    Op.floorOpen => '\\lfloor',
    Op.floorClose => '\\rfloor',
    Op.ceilOpen => '\\lceil',
    Op.ceilClose => '\\rceil',
    Op.equals => '=',
  };
}

String _sideLatex(List<Token> tokens, int start, int end) {
  if (start >= end) return '\\square';
  try {
    return parseSide(tokens, start, end).toLatex();
  } on MathError {
    final parts = <String>[];
    for (var i = start; i < end; i++) {
      // Two digits side by side are NOT a two-digit number: show the gap.
      if (i > start && tokens[i] is DigitToken && tokens[i - 1] is DigitToken) {
        parts.add('\\,{\\color{gray}\\square}\\,');
      }
      parts.add(_tokenLatex(tokens[i]));
    }
    return parts.join(' ');
  }
}

/// LaTeX for whatever is currently on the plate. Valid sides are rendered
/// properly (√(8+1) → \sqrt{8+1}); incomplete sides fall back to a symbol by
/// symbol rendering so the player always sees a live preview.
String plateToLatex(List<Token> tokens) {
  if (tokens.isEmpty) return '';
  final equals = <int>[
    for (var i = 0; i < tokens.length; i++)
      if (tokens[i] case OpToken(op: Op.equals)) i,
  ];
  if (equals.length != 1) {
    return _sideLatex(tokens, 0, tokens.length);
  }
  final eq = equals.single;
  return '${_sideLatex(tokens, 0, eq)} = '
      '${_sideLatex(tokens, eq + 1, tokens.length)}';
}

/// Converts an ASCII expression (e.g. `s(8+1)=3**1`) to tokens. Used by the
/// solver, by tests and to restore saved games.
List<Token> tokensFromPlain(String plain, {int firstId = 0}) {
  final result = <Token>[];
  var id = firstId;
  var i = 0;
  final absStack = <bool>[];
  while (i < plain.length) {
    final ch = plain[i];
    if (ch == ' ') {
      i++;
      continue;
    }
    final digit = int.tryParse(ch);
    if (digit != null) {
      result.add(DigitToken(id++, digit));
      i++;
      continue;
    }
    if (ch == '*' && i + 1 < plain.length && plain[i + 1] == '*') {
      result.add(OpToken(id++, Op.power));
      i += 2;
      continue;
    }
    final Op op;
    if (ch == '|') {
      final prev = result.isEmpty ? null : result.last;
      final closes = absStack.isNotEmpty && endsOperand(prev);
      op = closes ? Op.absClose : Op.absOpen;
      if (closes) {
        absStack.removeLast();
      } else {
        absStack.add(true);
      }
    } else {
      op = Op.values.firstWhere(
        (o) => o.plain == ch && o != Op.absOpen && o != Op.absClose,
        orElse: () => throw FormatException('Unknown symbol $ch'),
      );
    }
    result.add(OpToken(id++, op));
    i++;
  }
  return result;
}

/// Whether a token ends an operand (a digit, `!`, or a closing bracket).
bool endsOperand(Token? t) =>
    t is DigitToken ||
    (t is OpToken && (t.op.isClosing || t.op == Op.factorial));
