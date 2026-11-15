import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

/// Values that change every frame.
class _SceneClock extends ChangeNotifier {
  double time = 0;
  double progress = 0;
  double death = 0;
  double bite = 0;
  String plate = '';
  int seed = 0;

  void tick() => notifyListeners();
}

/// Graveyard scene with a zombie walking towards the player, holding the
/// licence plate. It reports when the zombie arrives.
class ZombieScene extends StatefulWidget {
  const ZombieScene({
    super.key,
    required this.plate,
    required this.plateSerial,
    required this.walkDuration,
    this.initialProgress = 0,
    this.paused = false,
    this.deathSerial = 0,
    this.biteSerial = 0,
    this.onArrived,
    this.onProgress,
  }) : still = false,
       progress = 0;

  /// A decorative, non-walking version (login page).
  const ZombieScene.still({super.key, required this.plate, this.progress = 0.6})
    : still = true,
      plateSerial = 0,
      walkDuration = null,
      initialProgress = progress,
      paused = false,
      deathSerial = 0,
      biteSerial = 0,
      onArrived = null,
      onProgress = null;

  final String plate;
  final int plateSerial;

  /// `null` = zen mode, the zombie waits at a distance.
  final Duration? walkDuration;
  final double initialProgress;
  final bool paused;

  /// Incremented when the zombie is shot (plays the death animation).
  final int deathSerial;

  /// Incremented when the zombie bites the player.
  final int biteSerial;
  final VoidCallback? onArrived;
  final ValueChanged<double>? onProgress;
  final bool still;
  final double progress;

  @override
  State<ZombieScene> createState() => _ZombieSceneState();
}

class _ZombieSceneState extends State<ZombieScene>
    with SingleTickerProviderStateMixin {
  final _clock = _SceneClock();
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  bool _dying = false;
  bool _arrivedReported = false;
  double _sinceReport = 0;

  @override
  void initState() {
    super.initState();
    _clock
      ..plate = widget.plate
      ..progress = widget.still
          ? widget.progress
          : (widget.walkDuration == null ? 0.25 : widget.initialProgress)
      ..seed = widget.plateSerial;
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(ZombieScene old) {
    super.didUpdateWidget(old);
    if (widget.still) {
      _clock
        ..plate = widget.plate
        ..progress = widget.progress;
      return;
    }
    if (widget.biteSerial != old.biteSerial) {
      _clock.bite = 1;
    }
    if (widget.plateSerial != old.plateSerial) {
      if (widget.deathSerial != old.deathSerial) {
        _dying = true; // keep the old plate until the zombie falls
        _clock.death = 0.0001;
      } else {
        _newZombie();
      }
    }
    if (widget.walkDuration == null && old.walkDuration != null) {
      _clock.progress = math.min(_clock.progress, 0.25);
    }
  }

  void _newZombie() {
    _dying = false;
    _arrivedReported = false;
    _clock
      ..death = 0
      ..plate = widget.plate
      ..seed = widget.plateSerial
      ..progress = widget.walkDuration == null ? 0.25 : widget.initialProgress;
  }

  void _onTick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _last = elapsed;
    _clock.time += dt;
    if (_clock.bite > 0) _clock.bite = math.max(0, _clock.bite - dt / 0.7);
    if (_dying) {
      _clock.death = math.min(1, _clock.death + dt / 0.9);
      if (_clock.death >= 1) _newZombie();
    } else if (!widget.still && !widget.paused) {
      final duration = widget.walkDuration;
      if (duration != null) {
        _clock.progress = math.min(
          1,
          _clock.progress + dt / (duration.inMilliseconds / 1000),
        );
        _sinceReport += dt;
        if (_sinceReport > 1) {
          _sinceReport = 0;
          widget.onProgress?.call(_clock.progress);
        }
        if (_clock.progress >= 1 && !_arrivedReported) {
          _arrivedReported = true;
          widget.onArrived?.call();
        }
      }
    }
    _clock.tick();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _ScenePainter(_clock, dark: dark),
        size: Size.infinite,
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.c, {required this.dark}) : super(repaint: c);

  final _SceneClock c;
  final bool dark;

  static final _plateFont = GoogleFonts.oswald().fontFamily;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;
    canvas.clipRect(Offset.zero & size);
    final horizon = h * 0.5;
    _sky(canvas, w, h, horizon);
    _ground(canvas, w, h, horizon);
    _fog(canvas, w, horizon);
    _zombie(canvas, w, h, horizon);
    _danger(canvas, size);
    _bite(canvas, size);
  }

  void _sky(Canvas canvas, double w, double h, double horizon) {
    final sky = dark
        ? const [Color(0xFF070A1F), Color(0xFF2B1640)]
        : const [Color(0xFF5B3F8C), Color(0xFFF4A261)];
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, horizon + 1),
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, horizon), sky),
    );
    if (dark) {
      final rnd = math.Random(3);
      for (var i = 0; i < 40; i++) {
        final p = Offset(
          rnd.nextDouble() * w,
          rnd.nextDouble() * horizon * 0.9,
        );
        final twinkle = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(c.time * 2 + i));
        canvas.drawCircle(
          p,
          rnd.nextDouble() * 1.2 + 0.4,
          Paint()..color = Colors.white.withValues(alpha: 0.7 * twinkle),
        );
      }
    }
    final r = math.min(w, h) * 0.08;
    final moon = Offset(w * 0.82, horizon * 0.32);
    canvas.drawCircle(
      moon,
      r * 1.8,
      Paint()
        ..color = const Color(0xFFFFF4D6).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawCircle(moon, r, Paint()..color = const Color(0xFFFFF4D6));
    canvas.drawCircle(
      moon + Offset(-r * 0.3, -r * 0.2),
      r * 0.18,
      Paint()..color = const Color(0x22000000),
    );
    canvas.drawCircle(
      moon + Offset(r * 0.35, r * 0.3),
      r * 0.12,
      Paint()..color = const Color(0x22000000),
    );

    // Hills and the graveyard silhouette.
    final hills = Path()..moveTo(0, horizon);
    for (var x = 0.0; x <= w; x += w / 12) {
      hills.lineTo(x, horizon - 12 - 10 * math.sin(x / w * 7 + 1));
    }
    hills
      ..lineTo(w, horizon + 1)
      ..lineTo(0, horizon + 1)
      ..close();
    final silhouette = dark ? const Color(0xFF140C24) : const Color(0xFF3A2752);
    canvas.drawPath(hills, Paint()..color = silhouette);
    final stone = Paint()..color = silhouette;
    for (var i = 0; i < 7; i++) {
      final x = w * (0.06 + i * 0.145);
      if ((x - w / 2).abs() < w * 0.08) continue;
      final sh = 12.0 + (i % 3) * 5;
      final sw = 9.0 + (i % 2) * 4;
      if (i % 3 == 1) {
        canvas.drawRect(
          Rect.fromLTWH(x - 2, horizon - sh - 6, 4, sh + 6),
          stone,
        );
        canvas.drawRect(Rect.fromLTWH(x - 7, horizon - sh, 14, 4), stone);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x - sw / 2, horizon - sh, sw, sh),
            topLeft: Radius.circular(sw / 2),
            topRight: Radius.circular(sw / 2),
          ),
          stone,
        );
      }
    }
    // Dead tree.
    final tree = Paint()
      ..color = silhouette
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final base = Offset(w * 0.12, horizon);
    final top = Offset(w * 0.11, horizon - h * 0.28);
    canvas.drawLine(base, top, tree);
    tree.strokeWidth = 2.5;
    canvas.drawLine(
      top + Offset(0, h * 0.08),
      top + Offset(w * 0.06, -h * 0.02),
      tree,
    );
    canvas.drawLine(
      top + Offset(0, h * 0.13),
      top + Offset(-w * 0.05, h * 0.02),
      tree,
    );
    canvas.drawLine(
      top + Offset(w * 0.03, h * 0.03),
      top + Offset(w * 0.05, -h * 0.04),
      tree,
    );
  }

  void _ground(Canvas canvas, double w, double h, double horizon) {
    final ground = dark
        ? const [Color(0xFF1C2A1E), Color(0xFF0B120C)]
        : const [Color(0xFF55703F), Color(0xFF2C3F22)];
    canvas.drawRect(
      Rect.fromLTWH(0, horizon, w, h - horizon),
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, horizon), Offset(0, h), ground),
    );
    final road = Path()
      ..moveTo(w * 0.47, horizon)
      ..lineTo(w * 0.53, horizon)
      ..lineTo(w * 0.85, h)
      ..lineTo(w * 0.15, h)
      ..close();
    canvas.drawPath(
      road,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, horizon),
          Offset(0, h),
          dark
              ? const [Color(0xFF2A2A33), Color(0xFF3A3A44)]
              : const [Color(0xFF7D6A55), Color(0xFF9C876C)],
        ),
    );
  }

  void _fog(Canvas canvas, double w, double horizon) {
    for (var i = 0; i < 3; i++) {
      final x = (c.time * (14 + i * 6) + i * w / 2.5) % (w * 1.6) - w * 0.3;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, horizon + 8 + i * 10),
          width: w * 0.6,
          height: 30,
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: dark ? 0.06 : 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }
  }

  void _zombie(Canvas canvas, double w, double h, double horizon) {
    final p = Curves.easeIn.transform(c.progress.clamp(0.0, 1.0));
    final scale = ui.lerpDouble(0.22, 1.0, p)! * h / 300;
    final feetY = ui.lerpDouble(horizon + 4, h * 0.985, p)!;
    final sway = math.sin(c.time * 1.7) * w * 0.025 * (1 - p * 0.6);
    final x = w / 2 + sway;
    final phase = c.time * math.pi * 2 * 0.9;

    canvas.save();
    canvas.translate(x, feetY);
    canvas.scale(scale);
    if (c.death > 0) {
      canvas.rotate(Curves.easeIn.transform(c.death) * 1.4);
      canvas.saveLayer(
        null,
        Paint()..color = Colors.white.withValues(alpha: 1 - c.death * 0.85),
      );
    }
    _drawZombieBody(canvas, phase, frozen: c.death > 0);
    if (c.death > 0) canvas.restore();
    canvas.restore();

    if (c.death > 0 && c.death < 0.6) {
      final head = Offset(x, feetY - 215 * scale);
      _impact(canvas, head, scale, c.death / 0.6);
    }
  }

  void _drawZombieBody(Canvas canvas, double phase, {required bool frozen}) {
    final step = frozen ? 0.0 : math.sin(phase);
    const skin = Color(0xFF8DB86B);
    const skinDark = Color(0xFF5E8A47);
    const shirt = Color(0xFF6B5B95);
    const pants = Color(0xFF34384F);

    // Shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 100, height: 16),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // Legs.
    final leg = Paint()
      ..color = pants
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    for (final side in [-1.0, 1.0]) {
      final angle = step * 0.3 * side;
      final hip = Offset(13 * side, -108);
      final foot = hip + Offset(math.sin(angle) * 100, 100 * math.cos(angle));
      canvas.drawLine(hip, foot, leg);
      canvas.drawOval(
        Rect.fromCenter(
          center: foot + const Offset(0, 4),
          width: 30,
          height: 14,
        ),
        Paint()..color = const Color(0xFF2A1E14),
      );
    }

    // Torso with a torn hem.
    final torso = Path()
      ..moveTo(-34, -188)
      ..quadraticBezierTo(0, -198, 34, -188)
      ..lineTo(38, -104)
      ..lineTo(26, -96)
      ..lineTo(18, -106)
      ..lineTo(6, -94)
      ..lineTo(-6, -105)
      ..lineTo(-18, -95)
      ..lineTo(-28, -104)
      ..lineTo(-38, -100)
      ..close();
    canvas.drawPath(torso, Paint()..color = shirt);
    canvas.drawCircle(
      const Offset(14, -128),
      7,
      Paint()..color = const Color(0xFF8E1B1B),
    );
    canvas.drawCircle(
      const Offset(-18, -116),
      4,
      Paint()..color = const Color(0xFF8E1B1B).withValues(alpha: 0.8),
    );

    // Arms reaching to hold the plate.
    final arm = Paint()
      ..color = skinDark
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    final reach = frozen ? 0.0 : math.sin(phase * 0.5) * 4;
    for (final side in [-1.0, 1.0]) {
      final shoulder = Offset(32 * side, -180);
      final elbow = Offset(52 * side, -150 + reach * side);
      final hand = Offset(46 * side, -146);
      canvas.drawLine(shoulder, elbow, arm);
      canvas.drawLine(elbow, hand, arm);
    }

    // Licence plate.
    final plateRect = Rect.fromCenter(
      center: const Offset(0, -146),
      width: 96,
      height: 40,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(plateRect, const Radius.circular(5)),
      Paint()..color = const Color(0xFFF7F7F2),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(plateRect.left, plateRect.top, plateRect.width, 9),
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF1A3D8F),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(plateRect, const Radius.circular(5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF222222),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: c.plate.split('').join(' '),
        style: TextStyle(
          fontFamily: _plateFont,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111111),
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(-tp.width / 2, plateRect.top + 9 + (31 - tp.height) / 2),
    );
    for (final side in [-1.0, 1.0]) {
      canvas.drawCircle(Offset(48 * side, -146), 9, Paint()..color = skin);
    }

    // Head.
    final bob = frozen ? 0.0 : math.sin(phase * 2) * 2;
    canvas.save();
    canvas.translate(0, -215 + bob);
    canvas.rotate(frozen ? 0 : math.sin(phase) * 0.08);
    canvas.drawRect(
      const Rect.fromLTWH(-7, 12, 14, 16),
      Paint()..color = skinDark,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 54, height: 60),
      Paint()..color = skin,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(12, -12), width: 14, height: 10),
      Paint()..color = skinDark,
    );
    final hair = Paint()
      ..color = const Color(0xFF2B2B2B)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = -2; i <= 2; i++) {
      canvas.drawLine(Offset(i * 7.0, -26), Offset(i * 9.0 + 3, -36), hair);
    }
    final glow = Paint()
      ..color = const Color(0xFFFF3B30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    for (final side in [-1.0, 1.0]) {
      final eye = Offset(10 * side, -4);
      canvas.drawCircle(eye, 8, glow);
      canvas.drawCircle(eye, 5.5, Paint()..color = const Color(0xFFFFE0D6));
      canvas.drawCircle(eye, 2.6, Paint()..color = const Color(0xFFD50000));
    }
    final mouth = Path()..moveTo(-12, 14);
    for (var i = 0; i < 6; i++) {
      mouth.lineTo(-12 + (i + 1) * 4, 14 + (i.isEven ? 4 : 0));
    }
    canvas.drawPath(
      mouth,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xFF3A1010),
    );
    canvas.restore();
  }

  void _impact(Canvas canvas, Offset head, double scale, double t) {
    final flash = Paint()
      ..color = const Color(0xFFFFE082).withValues(alpha: 1 - t)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final star = Path();
    const spikes = 9;
    final outer = 46 * scale * (0.6 + t);
    for (var i = 0; i < spikes * 2; i++) {
      final r = i.isEven ? outer : outer * 0.4;
      final a = i * math.pi / spikes;
      final p = head + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    star.close();
    canvas.drawPath(star, flash);
    final rnd = math.Random(c.seed);
    for (var i = 0; i < 14; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final speed = (40 + rnd.nextDouble() * 90) * scale;
      final p =
          head +
          Offset(math.cos(a) * speed * t, math.sin(a) * speed * t + 60 * t * t);
      canvas.drawCircle(
        p,
        (2 + rnd.nextDouble() * 4) * scale.clamp(0.5, 2),
        Paint()..color = const Color(0xFF9B0000).withValues(alpha: 1 - t),
      );
    }
  }

  void _danger(Canvas canvas, Size size) {
    if (c.progress < 0.6 || c.death > 0) return;
    final pulse = 0.75 + 0.25 * math.sin(c.time * 6);
    final alpha = ((c.progress - 0.6) / 0.4).clamp(0.0, 1.0) * 0.55 * pulse;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.radial(
          size.center(Offset.zero),
          size.longestSide * 0.7,
          [
            Colors.transparent,
            const Color(0xFFB00020).withValues(alpha: alpha),
          ],
          [0.55, 1],
        ),
    );
  }

  void _bite(Canvas canvas, Size size) {
    if (c.bite <= 0) return;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFB00020).withValues(alpha: c.bite * 0.45),
    );
    final claw = Paint()
      ..color = const Color(0xFF5A0000).withValues(alpha: c.bite)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    for (var i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(cx - 60 + i * 26, cy - 50),
        Offset(cx + 30 + i * 26, cy + 60),
        claw,
      );
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.dark != dark || old.c != c;
}
