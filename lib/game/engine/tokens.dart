/// Tokens that make up an equation on the zombie's licence plate.
///
/// The four digits of the plate are fixed tokens (they can never be removed or
/// reordered). Every other token is an operator the player "loads" between the
/// digits.
library;

enum Op {
  plus('+', '+'),
  minus('-', '-'),
  times('*', '*'),
  divide('/', '/'),
  power('**', '**'),
  lparen('(', '('),
  rparen(')', ')'),
  sqrt('√', 's'),
  cbrt('∛', 'c'),
  factorial('!', '!'),
  absOpen('|', '|'),
  absClose('|', '|'),
  floorOpen('⌊', '['),
  floorClose('⌋', ']'),
  ceilOpen('⌈', '{'),
  ceilClose('⌉', '}'),
  equals('=', '=');

  const Op(this.symbol, this.plain);

  /// Symbol shown on the plate.
  final String symbol;

  /// ASCII representation (used when serialising an expression).
  final String plain;

  bool get isOpening =>
      this == lparen ||
      this == absOpen ||
      this == floorOpen ||
      this == ceilOpen;

  bool get isClosing =>
      this == rparen ||
      this == absClose ||
      this == floorClose ||
      this == ceilClose;

  /// The closing partner of an opening bracket.
  Op get partner => switch (this) {
    lparen => rparen,
    rparen => lparen,
    absOpen => absClose,
    absClose => absOpen,
    floorOpen => floorClose,
    floorClose => floorOpen,
    ceilOpen => ceilClose,
    ceilClose => ceilOpen,
    _ => this,
  };
}

/// The buttons available on the ammo belt. "Smart" buttons (abs, floor, ceil)
/// insert the opening or closing bracket depending on the context, so the
/// player only needs one button for each pair.
enum OpButton {
  plus([Op.plus]),
  minus([Op.minus]),
  times([Op.times]),
  divide([Op.divide]),
  lparen([Op.lparen]),
  rparen([Op.rparen]),
  power([Op.power]),
  sqrt([Op.sqrt]),
  cbrt([Op.cbrt]),
  factorial([Op.factorial]),
  abs([Op.absOpen, Op.absClose]),
  floor([Op.floorOpen, Op.floorClose]),
  ceil([Op.ceilOpen, Op.ceilClose]),
  equals([Op.equals]);

  const OpButton(this.ops);

  final List<Op> ops;

  String get label => switch (this) {
    OpButton.abs => '|x|',
    OpButton.floor => '⌊x⌋',
    OpButton.ceil => '⌈x⌉',
    OpButton.power => 'xʸ',
    OpButton.sqrt => '√',
    OpButton.cbrt => '∛',
    OpButton.times => '×',
    OpButton.divide => '÷',
    OpButton.minus => '−',
    _ => ops.first.symbol,
  };

  static OpButton of(Op op) =>
      OpButton.values.firstWhere((b) => b.ops.contains(op));
}

/// A single token on the plate. Each token has a unique [id] so that widgets
/// can follow it while it is animated.
sealed class Token {
  const Token(this.id);
  final int id;

  String get plain;
  String get symbol;
}

final class DigitToken extends Token {
  const DigitToken(super.id, this.value);
  final int value;

  @override
  String get plain => '$value';

  @override
  String get symbol => '$value';

  @override
  bool operator ==(Object other) =>
      other is DigitToken && other.id == id && other.value == value;

  @override
  int get hashCode => Object.hash(id, value);
}

final class OpToken extends Token {
  const OpToken(super.id, this.op);
  final Op op;

  @override
  String get plain => op.plain;

  @override
  String get symbol => op.symbol;

  @override
  bool operator ==(Object other) =>
      other is OpToken && other.id == id && other.op == op;

  @override
  int get hashCode => Object.hash(id, op);
}

/// Human readable version of a token list, e.g. `√(8+1) = 3**1`.
String tokensToDisplay(List<Token> tokens) {
  final buffer = StringBuffer();
  for (final t in tokens) {
    if (t is OpToken && t.op == Op.equals) {
      buffer.write(' = ');
    } else if (t is OpToken &&
        (t.op == Op.plus || t.op == Op.times || t.op == Op.divide)) {
      buffer.write(' ${t.symbol} ');
    } else if (t is OpToken && t.op == Op.minus) {
      buffer.write(' - ');
    } else {
      buffer.write(t.symbol);
    }
  }
  return buffer
      .toString()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll('( ', '(')
      .trim();
}
