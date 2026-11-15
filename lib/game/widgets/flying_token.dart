import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../engine/tokens.dart';
import 'plate_editor.dart';

/// An operator flying from the plate back to its button on the belt.
class Flight {
  Flight({
    required this.op,
    required this.from,
    required this.to,
    required this.size,
    this.delay = Duration.zero,
  }) : id = _next++;

  static int _next = 0;
  final int id;
  final Op op;
  final Rect from;
  final Rect to;
  final double size;
  final Duration delay;
}

class FlyingToken extends StatefulWidget {
  const FlyingToken({super.key, required this.flight, required this.onDone});

  final Flight flight;
  final VoidCallback onDone;

  @override
  State<FlyingToken> createState() => _FlyingTokenState();
}

class _FlyingTokenState extends State<FlyingToken>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.flight.delay, () {
      if (mounted) _c.forward().whenComplete(widget.onDone);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.flight;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeInOutCubic.transform(_c.value);
        final from = f.from.center;
        final to = f.to.center;
        // Arc upwards while travelling.
        final lift = math.sin(t * math.pi) * 60;
        final pos = Offset.lerp(from, to, t)! - Offset(0, lift);
        final scale = 1 - 0.35 * t;
        return Positioned(
          left: pos.dx - f.from.width / 2,
          top: pos.dy - f.from.height / 2,
          width: f.from.width,
          height: f.from.height,
          child: Opacity(
            opacity: _c.value < 0.9 ? 1 : (1 - _c.value) * 10,
            child: Transform.rotate(
              angle: t * math.pi * 2,
              child: Transform.scale(scale: scale, child: child),
            ),
          ),
        );
      },
      child: FittedBox(
        child: OperatorChip(op: f.op, size: f.size),
      ),
    );
  }
}
