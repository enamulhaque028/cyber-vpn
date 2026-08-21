import 'dart:async';
import 'dart:math' as math;

import 'package:cyber_vpn/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ConnectRingPhase { idle, connecting, protected }

/// 3-phase Protect control: Idle → Connecting → Protected.
///
/// Idle is a glowing empty ring. Connecting shows an assembling crest with
/// arc microcopy + a clean "Connecting" label; Protected uses filled crest.
/// Drive with [phase] from SessionBloc. Tap via [onPressed] / [onTap].
class ConnectRing extends StatefulWidget {
  const ConnectRing({
    super.key,
    required this.phase,
    required this.onPressed,
    this.locationLabel,
  });

  final ConnectRingPhase phase;
  final VoidCallback onPressed;
  final String? locationLabel;

  VoidCallback get onTap => onPressed;

  static const outlineAsset = 'assets/icons/shield_outline.svg';
  static const fillAsset = 'assets/icons/shield_fill.svg';

  @override
  State<ConnectRing> createState() => _ConnectRingState();
}

class _ConnectRingState extends State<ConnectRing>
    with TickerProviderStateMixin {
  static const _size = 216.0;
  static const _ease = Curves.fastOutSlowIn;

  late final AnimationController _breath;
  late final AnimationController _press;
  late final AnimationController _spin;
  late final AnimationController _wave;
  late final AnimationController _ripple;
  late final AnimationController _check;
  late final AnimationController _labelFade;
  Timer? _microTimer;

  int _microIndex = 0;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _check = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _labelFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..value = 1;

    _syncPhase(widget.phase, animateEnter: false);
    _breath.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breath.reverse();
      } else if (status == AnimationStatus.dismissed &&
          widget.phase == ConnectRingPhase.idle) {
        _breath.forward();
      }
    });
  }

  void _startMicroCycle() {
    _microTimer?.cancel();
    _microIndex = 0;
    _microTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (!mounted || widget.phase != ConnectRingPhase.connecting) return;
      setState(() {
        _microIndex = (_microIndex + 1) % _arcMicroLines().length;
      });
    });
  }

  void _stopMicroCycle() {
    _microTimer?.cancel();
    _microTimer = null;
  }

  /// Short arc captions around the connecting HUD (not under the crest).
  List<String> _arcMicroLines() {
    final loc = widget.locationLabel?.trim();
    final place = (loc == null || loc.isEmpty) ? 'server' : loc;
    return ['Securing tunnel…', 'Encrypting packet…', 'Handshake with $place…'];
  }

  @override
  void didUpdateWidget(covariant ConnectRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) {
      _syncPhase(widget.phase, animateEnter: true);
    }
  }

  void _syncPhase(ConnectRingPhase phase, {required bool animateEnter}) {
    switch (phase) {
      case ConnectRingPhase.idle:
        _stopMicroCycle();
        _spin.stop();
        _wave.stop();
        _check.value = 0;
        _ripple.value = 0;
        _breath
          ..value = 0
          ..forward();
        _microIndex = 0;
      case ConnectRingPhase.connecting:
        _breath.stop();
        _breath.value = 0;
        _check.value = 0;
        _ripple.value = 0;
        _spin.repeat();
        _wave.repeat();
        _startMicroCycle();
        _labelFade
          ..value = 0
          ..forward();
      case ConnectRingPhase.protected:
        _stopMicroCycle();
        _breath.stop();
        _spin.stop();
        _wave.stop();
        if (animateEnter) {
          _ripple.forward(from: 0);
          _check.forward(from: 0);
          _labelFade
            ..value = 0
            ..forward();
        } else {
          _ripple.value = 1;
          _check.value = 1;
          _labelFade.value = 1;
        }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _stopMicroCycle();
    _breath.dispose();
    _press.dispose();
    _spin.dispose();
    _wave.dispose();
    _ripple.dispose();
    _check.dispose();
    _labelFade.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _press.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 300, damping: 15),
        _press.value,
        1,
        0,
      ),
    );
  }

  void _onTapUp(TapUpDetails _) {
    _releasePress();
    widget.onPressed();
  }

  void _onTapCancel() => _releasePress();

  void _releasePress() {
    _press.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 300, damping: 15),
        _press.value,
        0,
        0,
      ),
    );
  }

  String? _statusLabel() {
    return switch (widget.phase) {
      ConnectRingPhase.idle => null,
      // Clean hero label under the crest; arc micros live on the HUD.
      ConnectRingPhase.connecting => 'Connecting',
      ConnectRingPhase.protected => 'Protected',
    };
  }

  /// Shield box sized so crest + label under it still sit inside the ring.
  double get _shieldBox {
    return switch (widget.phase) {
      ConnectRingPhase.connecting => 78,
      ConnectRingPhase.protected => 96,
      ConnectRingPhase.idle => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final accent = scheme.primary;
    final inactive = isDark
        ? AppColors.inactiveOutline
        : AppColors.inactiveOutlineLight;

    final pressScale = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _press, curve: _ease));
    final breathScale = Tween<double>(
      begin: 1,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _breath, curve: Curves.easeInOut));

    final label = _statusLabel();
    final filled = widget.phase == ConnectRingPhase.protected;
    final isIdle = widget.phase == ConnectRingPhase.idle;
    final isConnecting = widget.phase == ConnectRingPhase.connecting;
    final labelColor = scheme.onSurface;
    final arcLines = _arcMicroLines();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _breath,
          _press,
          _spin,
          _wave,
          _ripple,
          _check,
          _labelFade,
        ]),
        builder: (context, _) {
          final scale = pressScale.value * (isIdle ? breathScale.value : 1.0);
          final shieldSize = _shieldBox;
          final groupNudge = filled ? -4.0 : (isConnecting ? -6.0 : 0.0);
          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: _size,
              height: _size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(_size, _size),
                    painter: _ConnectRingPainter(
                      phase: widget.phase,
                      accent: accent,
                      inactive: inactive,
                      isDark: isDark,
                      spin: _spin.value,
                      wave: _wave.value,
                      ripple: _ripple.value,
                      breath: _breath.value,
                      arcLines: isConnecting ? arcLines : const [],
                      activeArc: _microIndex,
                    ),
                  ),
                  // Idle: empty glowing ring only (no crest / label).
                  if (!isIdle && label != null)
                    Transform.translate(
                      offset: Offset(0, groupNudge),
                      child: SizedBox(
                        width: _size * 0.7,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: shieldSize,
                              height: shieldSize,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (isConnecting)
                                    // Soft bloom behind assembling crest.
                                    Container(
                                      width: shieldSize * 0.7,
                                      height: shieldSize * 0.7,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: accent.withValues(
                                              alpha: 0.35,
                                            ),
                                            blurRadius: 22,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  SvgPicture.asset(
                                    filled
                                        ? ConnectRing.fillAsset
                                        : ConnectRing.outlineAsset,
                                    width: shieldSize,
                                    height: shieldSize,
                                    colorFilter: ColorFilter.mode(
                                      accent,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  // Digital assemble wash (left) — connecting only.
                                  if (isConnecting)
                                    CustomPaint(
                                      size: Size(shieldSize, shieldSize),
                                      painter: _ShieldAssemblePainter(
                                        accent: accent,
                                        progress: _wave.value,
                                      ),
                                    ),
                                  if (filled)
                                    SvgPicture.asset(
                                      ConnectRing.fillAsset,
                                      width: shieldSize,
                                      height: shieldSize,
                                      colorFilter: ColorFilter.mode(
                                        Colors.white.withValues(alpha: 0.1),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  if (filled)
                                    CustomPaint(
                                      size: Size(
                                        shieldSize * 0.34,
                                        shieldSize * 0.24,
                                      ),
                                      painter: _CheckPainter(
                                        progress: Curves.easeOutCubic.transform(
                                          _check.value,
                                        ),
                                        color: const Color(0xFF031510),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: filled ? 10 : 8),
                            FadeTransition(
                              opacity: CurvedAnimation(
                                parent: _labelFade,
                                curve: _ease,
                              ),
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: isConnecting ? 0.4 : -0.2,
                                      height: 1.1,
                                      fontSize: filled
                                          ? 15
                                          : (isConnecting ? 15 : 16),
                                      color: labelColor,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.55)
      ..lineTo(size.width * 0.38, size.height * 0.88)
      ..lineTo(size.width * 0.92, size.height * 0.12);
    final metrics = path.computeMetrics().first;
    final extract = metrics.extractPath(0, metrics.length * progress);
    canvas.drawPath(
      extract,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) =>
      old.progress != progress || old.color != color;
}

/// Sparse digital bits assembling into the left side of the crest.
class _ShieldAssemblePainter extends CustomPainter {
  _ShieldAssemblePainter({required this.accent, required this.progress});

  final Color accent;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final clip = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width * 0.52, size.height));
    canvas.save();
    canvas.clipPath(clip);

    final bitPaint = Paint();
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i < 28; i++) {
      final t = (progress + i * 0.07) % 1.0;
      final x = size.width * (0.06 + rnd.nextDouble() * 0.4);
      final y = size.height * (0.12 + rnd.nextDouble() * 0.72);
      final drift = (t - 0.5) * 6;
      final alpha = (1 - (t - 0.5).abs() * 2).clamp(0.15, 0.7);

      if (i.isEven) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x + drift, y),
              width: 2.2 + rnd.nextDouble() * 2.4,
              height: 2.2 + rnd.nextDouble() * 2.4,
            ),
            const Radius.circular(0.6),
          ),
          bitPaint..color = accent.withValues(alpha: alpha * 0.75),
        );
      } else {
        textPainter.text = TextSpan(
          text: rnd.nextBool() ? '1' : '0',
          style: TextStyle(
            color: accent.withValues(alpha: alpha * 0.85),
            fontSize: 6.5,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x + drift - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShieldAssemblePainter old) =>
      old.progress != progress || old.accent != accent;
}

/// Rings / radar — crest SVG is layered above for connecting / protected.
class _ConnectRingPainter extends CustomPainter {
  _ConnectRingPainter({
    required this.phase,
    required this.accent,
    required this.inactive,
    required this.isDark,
    required this.spin,
    required this.wave,
    required this.ripple,
    required this.breath,
    this.arcLines = const [],
    this.activeArc = 0,
  });

  final ConnectRingPhase phase;
  final Color accent;
  final Color inactive;
  final bool isDark;
  final double spin;
  final double wave;
  final double ripple;
  final double breath;
  final List<String> arcLines;
  final int activeArc;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    switch (phase) {
      case ConnectRingPhase.idle:
        _paintIdle(canvas, center, radius);
      case ConnectRingPhase.connecting:
        _paintConnecting(canvas, center, radius);
      case ConnectRingPhase.protected:
        _paintProtected(canvas, center, radius);
    }
  }

  void _paintIdle(Canvas canvas, Offset c, double r) {
    final pulse = breath;
    // Soft radial core — quieter so concentric strokes stay the focus.
    canvas.drawCircle(
      c,
      r * 0.42,
      Paint()
        ..color = accent.withValues(alpha: 0.14 + 0.08 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36),
    );
    canvas.drawCircle(
      c,
      r * 0.2,
      Paint()
        ..color = accent.withValues(alpha: 0.16 + 0.1 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    // Quiet concentric depth rings (calm standby — not connecting HUD).
    final midPulse = (1 - pulse); // slightly out of phase with outer.
    canvas.drawCircle(
      c,
      r * (0.58 + 0.01 * pulse),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15
        ..color = accent.withValues(alpha: 0.12 + 0.1 * midPulse),
    );
    canvas.drawCircle(
      c,
      r * (0.78 + 0.008 * pulse),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.35
        ..color = accent.withValues(alpha: 0.22 + 0.12 * pulse),
    );

    // Outer neon hero ring + bloom.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..color = accent.withValues(alpha: 0.28 + 0.1 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = accent.withValues(alpha: 0.55 + 0.2 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = accent.withValues(alpha: 0.98),
    );
  }

  void _paintConnecting(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(
      c,
      r * 0.5,
      Paint()
        ..color = accent.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    final outerAngle = spin * 2 * math.pi * (1.8 / 1.2);
    _drawDashedArc(
      canvas,
      c,
      r,
      start: outerAngle,
      sweep: math.pi * 1.55,
      color: accent.withValues(alpha: 0.5),
      stroke: 7,
      dash: 11,
      gap: 6,
      blur: 11,
    );
    _drawDashedArc(
      canvas,
      c,
      r,
      start: outerAngle,
      sweep: math.pi * 1.55,
      color: accent,
      stroke: 2.8,
      dash: 11,
      gap: 6,
    );
    _drawDashedArc(
      canvas,
      c,
      r - 10,
      start: -outerAngle * 0.7,
      sweep: math.pi * 0.9,
      color: accent.withValues(alpha: 0.45),
      stroke: 1.8,
      dash: 6,
      gap: 5,
    );

    final innerAngle = -spin * 2 * math.pi;
    final innerRect = Rect.fromCircle(center: c, radius: r * 0.74);
    canvas.drawArc(
      innerRect,
      innerAngle,
      math.pi * 0.8,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = accent.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawArc(
      innerRect,
      innerAngle,
      math.pi * 0.8,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = accent,
    );

    _drawGlyphRing(canvas, c, r * 0.9, spin);
    _drawArcCaptions(canvas, c, r * 0.58);

    final t = wave % 1.0;
    canvas.drawCircle(
      c,
      r * 0.18 + t * r * 0.42,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = accent.withValues(alpha: (1 - t) * 0.22),
    );
  }

  void _drawArcCaptions(Canvas canvas, Offset c, double r) {
    if (arcLines.isEmpty) return;
    const slots = <double>[-2.35, -0.55, 1.15];
    final painter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i < arcLines.length && i < slots.length; i++) {
      final active = i == activeArc % arcLines.length;
      final angle = slots[i];
      final pos = c + Offset(math.cos(angle) * r, math.sin(angle) * r);
      painter.text = TextSpan(
        text: arcLines[i],
        style: TextStyle(
          color: accent.withValues(alpha: active ? 0.95 : 0.4),
          fontSize: active ? 8.5 : 7.5,
          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          letterSpacing: 0.15,
        ),
      );
      painter.layout(maxWidth: 96);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      final rot = (angle + math.pi / 2).clamp(-0.55, 0.55);
      canvas.rotate(rot);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    }
  }

  void _paintProtected(Canvas canvas, Offset c, double r) {
    if (ripple < 1) {
      final rr = r * (0.65 + ripple * 1.0);
      canvas.drawCircle(
        c,
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5 * (1 - ripple)
          ..color = accent.withValues(alpha: (1 - ripple) * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    canvas.drawCircle(
      c,
      r * 0.75,
      Paint()
        ..color = accent.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36),
    );
    canvas.drawCircle(
      c,
      r + 6,
      Paint()
        ..color = accent.withValues(alpha: 0.38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..color = accent.withValues(alpha: 0.26)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = accent.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..color = accent,
    );

    canvas.drawCircle(
      c,
      r - 8,
      Paint()..color = accent.withValues(alpha: isDark ? 0.08 : 0.06),
    );
  }

  void _drawDashedArc(
    Canvas canvas,
    Offset c,
    double r, {
    required double start,
    required double sweep,
    required Color color,
    required double stroke,
    required double dash,
    required double gap,
    double? blur,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    if (blur != null) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    }
    final circumference = r * sweep.abs();
    final count = math.max(1, (circumference / (dash + gap)).floor());
    final step = sweep / count;
    for (var i = 0; i < count; i++) {
      final a0 = start + step * i;
      final a1 = a0 + step * (dash / (dash + gap));
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        a0,
        a1 - a0,
        false,
        paint,
      );
    }
  }

  void _drawGlyphRing(Canvas canvas, Offset c, double r, double t) {
    const glyphs = 'A7F3C91E0B8D2465';
    const count = 22;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final glyphColor = isDark
        ? const Color(0xFF7A9A8E)
        : accent.withValues(alpha: 0.55);

    for (var i = 0; i < count; i++) {
      final angle = -math.pi / 2 + (i / count) * math.pi * 2 + t * math.pi * 2;
      final ch = glyphs[i % glyphs.length];
      final style = TextStyle(
        color: glyphColor,
        fontSize: 8.5,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

      textPainter.text = TextSpan(
        text: ch,
        style: style.copyWith(
          shadows: [
            Shadow(color: accent.withValues(alpha: 0.35), blurRadius: 4),
          ],
        ),
      );
      textPainter.layout();
      final pos = c + Offset(math.cos(angle) * r, math.sin(angle) * r);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle + math.pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectRingPainter old) {
    return old.phase != phase ||
        old.spin != spin ||
        old.wave != wave ||
        old.ripple != ripple ||
        old.breath != breath ||
        old.accent != accent ||
        old.inactive != inactive ||
        old.activeArc != activeArc ||
        old.arcLines != arcLines;
  }
}
