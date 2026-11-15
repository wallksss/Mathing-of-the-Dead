import 'tokens.dart';

/// Game levels. Each one decides which operators are loaded on the ammo belt.
enum Difficulty {
  easy(
    buttons: {
      OpButton.plus,
      OpButton.minus,
      OpButton.times,
      OpButton.divide,
      OpButton.lparen,
      OpButton.rparen,
      OpButton.sqrt,
      OpButton.cbrt,
      OpButton.factorial,
      OpButton.power,
      OpButton.abs,
      OpButton.floor,
      OpButton.ceil,
    },
    allowsFractionalDivision: true,
    basePoints: 10,
    zombieSeconds: 90,
  ),
  intermediate(
    buttons: {
      OpButton.plus,
      OpButton.minus,
      OpButton.times,
      OpButton.divide,
      OpButton.lparen,
      OpButton.rparen,
      OpButton.sqrt,
      OpButton.cbrt,
      OpButton.factorial,
      OpButton.power,
      OpButton.abs,
    },
    allowsFractionalDivision: false,
    basePoints: 20,
    zombieSeconds: 120,
  ),
  advanced(
    buttons: {
      OpButton.plus,
      OpButton.minus,
      OpButton.times,
      OpButton.divide,
      OpButton.lparen,
      OpButton.rparen,
      OpButton.sqrt,
      OpButton.factorial,
      OpButton.abs,
    },
    allowsFractionalDivision: false,
    basePoints: 35,
    zombieSeconds: 150,
  ),
  hard(
    buttons: {
      OpButton.plus,
      OpButton.minus,
      OpButton.times,
      OpButton.divide,
      OpButton.lparen,
      OpButton.rparen,
      OpButton.abs,
    },
    allowsFractionalDivision: false,
    basePoints: 50,
    zombieSeconds: 180,
  );

  const Difficulty({
    required Set<OpButton> buttons,
    required this.allowsFractionalDivision,
    required this.basePoints,
    required this.zombieSeconds,
  }) : _operators = buttons;

  final Set<OpButton> _operators;

  /// Only the "Easy" level accepts divisions such as 5/2 = 2.5.
  final bool allowsFractionalDivision;

  /// Points earned for each plate solved at this level (before bonuses).
  final int basePoints;

  /// Seconds the zombie needs to reach the player at "normal" speed.
  final int zombieSeconds;

  /// The "=" sign is always available.
  Set<OpButton> get buttons => {..._operators, OpButton.equals};

  bool allows(Op op) => buttons.any((b) => b.ops.contains(op));

  static Difficulty fromName(String? name) => Difficulty.values.firstWhere(
    (d) => d.name == name,
    orElse: () => Difficulty.easy,
  );
}
