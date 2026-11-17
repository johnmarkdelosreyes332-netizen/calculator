import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract final class GalaxyColors {
  static const midnight = Color(0xFF0B1026);
  static const deepPurple = Color(0xFF1A0B3B);
  static const violet = Color(0xFF7C3AED);
  static const cyan = Color(0xFF22D3EE);
  static const pink = Color(0xFFF9A8D4);
  static const white = Color(0xFFE9F3FF);
  static const gradientBlue = Color(0xFF11112F);
  static const gradientPurple = Color(0xFF100D2D);
  static const vignette = Color(0x66030718);
  static const lavenderPlanet = Color(0xFF47318A);
  static const lavenderHighlight = Color(0xFFBD9BFF);
  static const tealPlanet = Color(0xFF176B85);
  static const tealHighlight = Color(0xFF8AF0F5);
  static const rosePlanet = Color(0xFF8A476F);
  static const roseHighlight = Color(0xFFFFB8DE);
  static const lilacPlanet = Color(0xFF745D9B);
  static const lilacHighlight = Color(0xFFD8C2FF);
  static const ring = Color(0xFFD9C1FF);
  static const planetShadow = Color(0xFF080B20);
  static const transparent = Colors.transparent;
}

class GalaxyBackground extends StatefulWidget {
  const GalaxyBackground({required this.child, super.key});

  final Widget child;

  @override
  State<GalaxyBackground> createState() => _GalaxyBackgroundState();
}

class _GalaxyBackgroundState extends State<GalaxyBackground>
    with SingleTickerProviderStateMixin {
  static const _cycleSeconds = 60.0;

  late final AnimationController _animationController;
  final ValueNotifier<Offset> _pointer = ValueNotifier(Offset.zero);
  final ValueNotifier<List<_GalaxyRipple>> _ripples = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pointer.dispose();
    _ripples.dispose();
    super.dispose();
  }

  Offset _normalizedPosition(Offset localPosition, Size size) {
    if (size.isEmpty) return Offset.zero;
    return Offset(
      (localPosition.dx / size.width * 2 - 1).clamp(-1.0, 1.0),
      (localPosition.dy / size.height * 2 - 1).clamp(-1.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerMove: (event) {
            _pointer.value = _normalizedPosition(event.localPosition, size);
          },
          onPointerDown: (event) {
            _pointer.value = _normalizedPosition(event.localPosition, size);
            final currentTime = _animationController.value * _cycleSeconds;
            _ripples.value = [
              ..._ripples.value.where(
                (ripple) =>
                    (currentTime - ripple.startTime + _cycleSeconds) %
                        _cycleSeconds <
                    3,
              ),
              _GalaxyRipple(event.localPosition, currentTime),
            ];
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: _GalaxyPainter(
                    progress: _animationController,
                    pointer: _pointer,
                    ripples: _ripples,
                  ),
                  willChange: true,
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class _GalaxyRipple {
  const _GalaxyRipple(this.position, this.startTime);

  final Offset position;
  final double startTime;
}

class _GalaxyPainter extends CustomPainter {
  _GalaxyPainter({
    required this.progress,
    required this.pointer,
    required this.ripples,
  }) : super(repaint: Listenable.merge([progress, pointer, ripples]));

  static const _cycleSeconds = 60.0;
  static final _stars = List<_Star>.generate(150, (index) {
    final random = math.Random(9200 + index);
    return _Star(
      x: random.nextDouble(),
      y: random.nextDouble(),
      radius: 0.45 + random.nextDouble() * 1.1,
      phase: random.nextDouble() * math.pi * 2,
      frequency: 1 + random.nextInt(4),
      opacity: 0.22 + random.nextDouble() * 0.62,
      hue: random.nextInt(3),
    );
  }, growable: false);
  static final _dust = List<_Dust>.generate(42, (index) {
    final random = math.Random(18400 + index);
    return _Dust(
      x: random.nextDouble(),
      y: random.nextDouble(),
      radius: 0.7 + random.nextDouble() * 1.7,
      frequency: 1 + random.nextInt(3),
      phase: random.nextDouble() * math.pi * 2,
    );
  }, growable: false);

  final Animation<double> progress;
  final ValueListenable<Offset> pointer;
  final ValueListenable<List<_GalaxyRipple>> ripples;

  double get _time => progress.value * _cycleSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final time = _time;
    final parallax = pointer.value;

    _paintSky(canvas, size, time);
    _paintNebulae(canvas, size, time, parallax);
    _paintStars(canvas, size, time, parallax);
    _paintDust(canvas, size, time, parallax);
    _paintPlanets(canvas, size, time, parallax);
    _paintRipples(canvas, size, time);
  }

  void _paintSky(Canvas canvas, Size size, double time) {
    final phase = time / _cycleSeconds * math.pi * 2;
    final shift = (math.sin(phase) + 1) / 2;
    final rect = Offset.zero & size;
    final base = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height * (0.12 + shift * 0.12)),
        Offset(size.width, size.height * (0.88 - shift * 0.12)),
        const [
          GalaxyColors.midnight,
          GalaxyColors.gradientBlue,
          GalaxyColors.deepPurple,
          GalaxyColors.gradientPurple,
          GalaxyColors.midnight,
        ],
        const [0, 0.28, 0.53, 0.78, 1],
      );
    canvas.drawRect(rect, base);

    final vignette = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.5, size.height * 0.44),
        size.longestSide * 0.78,
        const [GalaxyColors.transparent, GalaxyColors.vignette],
        const [0.48, 1],
      );
    canvas.drawRect(rect, vignette);
  }

  void _paintNebulae(Canvas canvas, Size size, double time, Offset parallax) {
    final phase = time / _cycleSeconds * math.pi * 2;
    final blobs = [
      (
        x: 0.18 + math.sin(phase) * 0.045 + parallax.dx * 0.012,
        y: 0.28 + math.cos(phase) * 0.035 + parallax.dy * 0.012,
        radius: size.shortestSide * 0.48,
        color: GalaxyColors.violet,
        opacity: 0.18,
      ),
      (
        x: 0.84 + math.cos(phase + 1.2) * 0.04 + parallax.dx * 0.018,
        y: 0.54 + math.sin(phase + 1.2) * 0.05 + parallax.dy * 0.018,
        radius: size.shortestSide * 0.38,
        color: GalaxyColors.cyan,
        opacity: 0.105,
      ),
      (
        x: 0.45 + math.sin(phase + 2.4) * 0.045 + parallax.dx * 0.009,
        y: 0.88 + math.cos(phase + 2.4) * 0.04 + parallax.dy * 0.009,
        radius: size.shortestSide * 0.42,
        color: GalaxyColors.pink,
        opacity: 0.12,
      ),
    ];

    for (final blob in blobs) {
      final pulse = 0.92 + math.sin(phase + blob.x * 5) * 0.08;
      final radius = blob.radius * pulse;
      final paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width * blob.x, size.height * blob.y),
          radius,
          [
            blob.color.withValues(alpha: blob.opacity),
            blob.color.withValues(alpha: blob.opacity * 0.38),
            blob.color.withValues(alpha: 0),
          ],
          const [0, 0.52, 1],
        );
      canvas.drawCircle(
        Offset(size.width * blob.x, size.height * blob.y),
        radius,
        paint,
      );
    }
  }

  void _paintStars(Canvas canvas, Size size, double time, Offset parallax) {
    final cyclePhase = time / _cycleSeconds * math.pi * 2;
    for (final star in _stars) {
      final twinkle =
          0.5 + 0.5 * math.sin(cyclePhase * star.frequency + star.phase);
      final opacity = star.opacity * (0.34 + 0.66 * twinkle);
      final point = Offset(
        star.x * size.width + parallax.dx * (2 + star.radius * 1.8),
        star.y * size.height + parallax.dy * (2 + star.radius * 1.8),
      );
      final color = switch (star.hue) {
        0 => GalaxyColors.white,
        1 => GalaxyColors.cyan,
        _ => GalaxyColors.pink,
      };
      final paint = Paint()..color = color.withValues(alpha: opacity);
      canvas.drawCircle(point, star.radius * (0.78 + twinkle * 0.35), paint);
      if (star.radius > 1.3 && twinkle > 0.82) {
        final glow = Paint()
          ..color = color.withValues(alpha: opacity * 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(point, star.radius * 2.4, glow);
      }
    }
  }

  void _paintDust(Canvas canvas, Size size, double time, Offset parallax) {
    final cyclePhase = time / _cycleSeconds * math.pi * 2;
    for (final mote in _dust) {
      final drift = cyclePhase * mote.frequency + mote.phase;
      final x = mote.x + math.sin(drift) * 0.025;
      final y = mote.y + math.cos(drift * 0.8) * 0.035;
      final twinkle = 0.5 + 0.5 * math.sin(drift);
      final point = Offset(
        x * size.width + parallax.dx * 8,
        y * size.height + parallax.dy * 8,
      );
      final opacity = 0.16 + twinkle * 0.38;
      final paint = Paint()
        ..color =
            (mote.frequency.isEven ? GalaxyColors.cyan : GalaxyColors.pink)
                .withValues(alpha: opacity);
      canvas.drawCircle(point, mote.radius, paint);
    }
  }

  void _paintPlanets(Canvas canvas, Size size, double time, Offset parallax) {
    final phase = time / _cycleSeconds * math.pi * 2;
    _drawPlanet(
      canvas,
      center: Offset(
        size.width * 0.13 + parallax.dx * 18,
        size.height * (0.59 + math.sin(phase) * 0.018) + parallax.dy * 18,
      ),
      radius: size.shortestSide * 0.071,
      baseColor: GalaxyColors.lavenderPlanet,
      highlight: GalaxyColors.lavenderHighlight,
      time: phase * 0.35,
      ring: true,
    );
    _drawPlanet(
      canvas,
      center: Offset(
        size.width * 0.88 + parallax.dx * 24,
        size.height * (0.34 + math.sin(phase + 2) * 0.023) + parallax.dy * 24,
      ),
      radius: size.shortestSide * 0.049,
      baseColor: GalaxyColors.tealPlanet,
      highlight: GalaxyColors.tealHighlight,
      time: phase * 0.27,
    );
    _drawPlanet(
      canvas,
      center: Offset(
        size.width * 0.78 + parallax.dx * 30,
        size.height * (0.79 + math.cos(phase + 1) * 0.018) + parallax.dy * 30,
      ),
      radius: size.shortestSide * 0.036,
      baseColor: GalaxyColors.rosePlanet,
      highlight: GalaxyColors.roseHighlight,
      time: phase * 0.42,
    );
    _drawPlanet(
      canvas,
      center: Offset(
        size.width * 0.36 + parallax.dx * 13,
        size.height * (0.12 + math.cos(phase + 3) * 0.016) + parallax.dy * 13,
      ),
      radius: size.shortestSide * 0.023,
      baseColor: GalaxyColors.lilacPlanet,
      highlight: GalaxyColors.lilacHighlight,
      time: phase * 0.2,
    );
  }

  void _drawPlanet(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color baseColor,
    required Color highlight,
    required double time,
    bool ring = false,
  }) {
    final glowPaint = Paint()
      ..color = highlight.withValues(alpha: 0.16)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.62);
    canvas.drawCircle(center, radius * 1.22, glowPaint);

    if (ring) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-0.25 + math.sin(time) * 0.06);
      final ringRect = Rect.fromCenter(
        center: Offset.zero,
        width: radius * 3.3,
        height: radius * 0.72,
      );
      canvas.drawOval(
        ringRect,
        Paint()
          ..color = GalaxyColors.ring.withValues(alpha: 0.46)
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.16,
      );
      canvas.restore();
    }

    final spherePaint = Paint()
      ..shader = ui.Gradient.radial(
        center.translate(-radius * 0.34, -radius * 0.38),
        radius * 1.75,
        [highlight, baseColor, GalaxyColors.planetShadow],
        const [0, 0.45, 1],
        TileMode.clamp,
      );
    canvas.drawCircle(center, radius, spherePaint);

    final rimPaint = Paint()
      ..color = highlight.withValues(alpha: 0.44)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.7, radius * 0.045);
    canvas.drawCircle(center, radius - rimPaint.strokeWidth / 2, rimPaint);
  }

  void _paintRipples(Canvas canvas, Size size, double time) {
    for (final ripple in ripples.value) {
      final age = (time - ripple.startTime + _cycleSeconds) % _cycleSeconds;
      if (age >= 2.8) continue;

      final progress = age / 2.8;
      final radius = 8 + progress * 66;
      final opacity = (1 - progress) * 0.48;
      final center = ripple.position;
      final ringPaint = Paint()
        ..color = GalaxyColors.cyan.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius, ringPaint);

      final sparklePaint = Paint()
        ..color = GalaxyColors.pink.withValues(alpha: opacity * 0.9)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      for (var index = 0; index < 4; index++) {
        final angle = index * math.pi / 2 + math.pi / 4;
        final inner = radius * 0.55;
        final outer = inner + 5 * (1 - progress);
        canvas.drawLine(
          center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
          center + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
          sparklePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GalaxyPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.pointer != pointer ||
      oldDelegate.ripples != ripples;
}

class _Star {
  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
    required this.frequency,
    required this.opacity,
    required this.hue,
  });

  final double x;
  final double y;
  final double radius;
  final double phase;
  final int frequency;
  final double opacity;
  final int hue;
}

class _Dust {
  const _Dust({
    required this.x,
    required this.y,
    required this.radius,
    required this.frequency,
    required this.phase,
  });

  final double x;
  final double y;
  final double radius;
  final int frequency;
  final double phase;
}
