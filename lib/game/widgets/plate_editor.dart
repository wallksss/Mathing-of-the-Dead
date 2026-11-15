import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../engine/tokens.dart';

/// The big licence plate where the player builds the equation.
///
/// Between every pair of tokens there is a "gap": tapping it moves the cursor
/// there. Tapping an operator removes it (it flies back to the belt).
class PlateEditor extends StatefulWidget {
  const PlateEditor({
    super.key,
    required this.tokens,
    required this.cursor,
    required this.header,
    required this.tokenKeys,
    required this.onGapTap,
    required this.onOperatorTap,
    this.errorIndex,
    this.shakeSerial = 0,
  });

  final List<Token> tokens;
  final int cursor;
  final String header;
  final Map<int, GlobalKey> tokenKeys;
  final ValueChanged<int> onGapTap;
  final ValueChanged<OpToken> onOperatorTap;
  final int? errorIndex;

  /// Incremented to shake the plate (wrong answer).
  final int shakeSerial;

  @override
  State<PlateEditor> createState() => _PlateEditorState();
}

class _PlateEditorState extends State<PlateEditor>
    with TickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void didUpdateWidget(PlateEditor old) {
    super.didUpdateWidget(old);
    if (widget.shakeSerial != old.shakeSerial) _shake.forward(from: 0);
    if (widget.cursor != old.cursor) _blink.forward(from: 0);
  }

  @override
  void dispose() {
    _blink.dispose();
    _shake.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(Token t) => widget.tokenKeys.putIfAbsent(
    t.id,
    () => GlobalKey(debugLabel: '${t.id}'),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final t = _shake.value;
        final dx = math.sin(t * math.pi * 6) * 12 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final digitSize = (constraints.maxWidth / 13)
              .clamp(30.0, 52.0)
              .toDouble();
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1F1F1F), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A3D8F),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.header.toUpperCase(),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      fontSize: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 6,
                    children: [
                      for (var i = 0; i <= widget.tokens.length; i++) ...[
                        _Gap(
                          active: widget.cursor == i,
                          blink: _blink,
                          height: digitSize * 1.15,
                          color: scheme.primary,
                          onTap: () => widget.onGapTap(i),
                        ),
                        if (i < widget.tokens.length)
                          _TokenView(
                            key: _keyFor(widget.tokens[i]),
                            token: widget.tokens[i],
                            size: digitSize,
                            error: widget.errorIndex == i,
                            onTap: () {
                              final t = widget.tokens[i];
                              if (t is OpToken) {
                                widget.onOperatorTap(t);
                              } else {
                                widget.onGapTap(i + 1);
                              }
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Gap extends StatelessWidget {
  const _Gap({
    required this.active,
    required this.blink,
    required this.height,
    required this.color,
    required this.onTap,
  });

  final bool active;
  final Animation<double> blink;
  final double height;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        child: SizedBox(
          width: 16,
          height: height,
          child: Center(
            child: active
                ? FadeTransition(
                    opacity: blink.drive(
                      TweenSequence([
                        TweenSequenceItem(
                          tween: ConstantTween(1.0),
                          weight: 55,
                        ),
                        TweenSequenceItem(
                          tween: ConstantTween(0.15),
                          weight: 45,
                        ),
                      ]),
                    ),
                    child: Container(
                      width: 4,
                      height: height * 0.9,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    width: 2,
                    height: height * 0.35,
                    color: const Color(0x22000000),
                  ),
          ),
        ),
      ),
    );
  }
}

class _TokenView extends StatelessWidget {
  const _TokenView({
    super.key,
    required this.token,
    required this.size,
    required this.error,
    required this.onTap,
  });

  final Token token;
  final double size;
  final bool error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final errorBox = BoxDecoration(
      color: scheme.error.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: scheme.error, width: 2),
    );
    final t = token;
    if (t is DigitToken) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: error ? errorBox : null,
          child: Text(
            '${t.value}',
            style: plateTextStyle(
              size: size * 1.1,
              color: const Color(0xFF111111),
            ),
          ),
        ),
      );
    }
    final op = (t as OpToken).op;
    return Semantics(
      button: true,
      label: op.symbol,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: OperatorChip(
            op: op,
            size: size,
            decoration: error ? errorBox : null,
          ),
        ),
      ),
    );
  }
}

/// Visual of an operator token (also used by the flying animation).
class OperatorChip extends StatelessWidget {
  const OperatorChip({
    super.key,
    required this.op,
    required this.size,
    this.decoration,
  });

  final Op op;
  final double size;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEquals = op == Op.equals;
    final bg = isEquals ? scheme.tertiary : scheme.primary;
    final fg = isEquals ? scheme.onTertiary : scheme.onPrimary;
    return Container(
      constraints: BoxConstraints(minWidth: size * 0.62),
      padding: EdgeInsets.symmetric(horizontal: size * 0.12, vertical: 2),
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration:
          decoration ??
          BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(size * 0.2),
            boxShadow: [
              BoxShadow(
                color: bg.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
      child: Text(
        op.symbol,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size * 0.72,
          fontWeight: FontWeight.w700,
          color: decoration == null ? fg : scheme.error,
          height: 1.25,
        ),
      ),
    );
  }
}
