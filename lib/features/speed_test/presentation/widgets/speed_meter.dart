import 'dart:math' as math;

import 'package:cyber_vpn/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:cyber_vpn/features/speed_test/presentation/widgets/speed_gauge_scale.dart';
import 'package:flutter/material.dart';

enum SpeedMeterPhase { idle, preparing, running, complete, error }

class SpeedMeter extends StatefulWidget {
  const SpeedMeter({
    super.key,
    required this.phase,
    required this.mbps,
    this.peakMbps,
    this.measurePhase = SpeedTestMeasurePhase.download,
    this.pingMs,
  });

  final SpeedMeterPhase phase;
  final double mbps;
  final double? peakMbps;
  final SpeedTestMeasurePhase measurePhase;
  final int? pingMs;

  @override
  State<SpeedMeter> createState() => _SpeedMeterState();
}

class _SpeedMeterState extends State<SpeedMeter> with TickerProviderStateMixin {
  late AnimationController _valueController;
  late AnimationController _pulseController;
  late Animation<double> _mbpsAnimation;
  late Animation<double> _fillAnimation;
  double _displayMbps = 0;
  double _displayFill = 0;

  @override
  void initState() {
    super.initState();
    _mbpsAnimation = AlwaysStoppedAnimation(0);
    _fillAnimation = AlwaysStoppedAnimation(0);
    _valueController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    )..addListener(() {
        setState(() {
          _displayMbps = _mbpsAnimation.value;
          _displayFill = _fillAnimation.value;
        });
      });
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyTarget(animate: false);
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant SpeedMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyTarget(animate: !MediaQuery.disableAnimationsOf(context));
    _syncPulse();
  }

  void _applyTarget({required bool animate}) {
    final target = _targetMbps();
    final fill = widget.measurePhase == SpeedTestMeasurePhase.ping
        ? 0.0
        : mbpsToGaugeFraction(target);

    if (!animate) {
      _valueController.stop();
      setState(() {
        _displayMbps = target;
        _displayFill = fill;
      });
      return;
    }

    _mbpsAnimation = Tween<double>(begin: _displayMbps, end: target).animate(
      CurvedAnimation(parent: _valueController, curve: Curves.easeOutCubic),
    );
    _fillAnimation = Tween<double>(begin: _displayFill, end: fill).animate(
      CurvedAnimation(parent: _valueController, curve: Curves.easeOutCubic),
    );
    _valueController.forward(from: 0);
  }

  void _syncPulse() {
    final active = widget.phase == SpeedMeterPhase.running ||
        widget.phase == SpeedMeterPhase.preparing;
    if (active && !MediaQuery.disableAnimationsOf(context)) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController
        ..stop()
        ..value = 0;
    }
  }

  double _targetMbps() {
    if (widget.measurePhase == SpeedTestMeasurePhase.ping) return 0;
    return switch (widget.phase) {
      SpeedMeterPhase.complete => widget.peakMbps ?? widget.mbps,
      SpeedMeterPhase.idle => 0,
      _ => widget.mbps,
    };
  }

  @override
  void dispose() {
    _valueController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = _displayFill.clamp(0.0, 1.0);
    final isPing = widget.measurePhase == SpeedTestMeasurePhase.ping &&
        widget.phase != SpeedMeterPhase.idle;
    final valueLabel = switch (widget.phase) {
      SpeedMeterPhase.preparing => '…',
      SpeedMeterPhase.idle => '—',
      SpeedMeterPhase.error => '—',
      _ when isPing => formatPingMs(widget.pingMs),
      SpeedMeterPhase.complete => formatGaugeMbps(_displayMbps),
      _ => formatGaugeMbps(_displayMbps),
    };
    final unitLabel = isPing ? 'ms' : 'Mbps';

    return SizedBox(
      width: 320,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return CustomPaint(
                size: const Size(320, 280),
                painter: _SpeedGaugePainter(
                  scheme: scheme,
                  fill: fill,
                  pulse: _pulseController.value,
                  phase: widget.phase,
                ),
              );
            },
          ),
          Positioned(
            top: 88,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  valueLabel,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  unitLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 14),
                _MeasureBadge(
                  active: widget.phase != SpeedMeterPhase.idle,
                  phase: widget.measurePhase,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasureBadge extends StatelessWidget {
  const _MeasureBadge({required this.active, required this.phase});

  final bool active;
  final SpeedTestMeasurePhase phase;

  static const _uploadBlue = Color(0xFF3B82F6);
  static const _pingPurple = Color(0xFFA78BFA);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, label, color) = switch (phase) {
      SpeedTestMeasurePhase.ping => (
          Icons.show_chart_rounded,
          'Ping',
          _pingPurple,
        ),
      SpeedTestMeasurePhase.upload => (
          Icons.arrow_upward_rounded,
          'Upload',
          _uploadBlue,
        ),
      SpeedTestMeasurePhase.download => (
          Icons.arrow_downward_rounded,
          'Download',
          scheme.primary,
        ),
    };
    final tint = active ? color : scheme.secondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tint.withValues(alpha: 0.15),
            border: Border.all(color: tint.withValues(alpha: 0.45)),
          ),
          child: Icon(icon, size: 16, color: tint),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: tint,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _SpeedGaugePainter extends CustomPainter {
  _SpeedGaugePainter({
    required this.scheme,
    required this.fill,
    required this.pulse,
    required this.phase,
  });

  final ColorScheme scheme;
  final double fill;
  final double pulse;
  final SpeedMeterPhase phase;

  static const _startAngle = math.pi * 0.75;
  static const _sweep = math.pi * 1.5;
  static const _neonCyan = Color(0xFF00FFD1);
  static const _neonGreen = Color(0xFF00FF9D);
  static const _neonBlue = Color(0xFF00B4FF);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.56);
    final outerRadius = size.width * 0.39;
    const outerStroke = 3.0;
    const innerStroke = 12.0;
    final innerRadius = outerRadius - 18;

    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    _drawDashedArc(
      canvas,
      Rect.fromCircle(center: center, radius: outerRadius),
      _startAngle,
      _sweep,
      Paint()
        ..color = _neonCyan.withValues(alpha: 0.22 + pulse * 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerStroke,
      dashLength: 4,
      gapLength: 6,
    );

    _drawDashedArc(
      canvas,
      Rect.fromCircle(center: center, radius: innerRadius - 16),
      _startAngle,
      _sweep,
      Paint()
        ..color = scheme.outline.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
      dashLength: 2,
      gapLength: 5,
    );

    canvas.drawArc(
      innerRect,
      _startAngle,
      _sweep,
      false,
      Paint()
        ..color = scheme.outline.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = innerStroke
        ..strokeCap = StrokeCap.round,
    );

    if (fill > 0 && phase != SpeedMeterPhase.error) {
      final fillPaint = Paint()
        ..shader = SweepGradient(
          colors: const [_neonCyan, _neonGreen, _neonBlue],
          stops: const [0.0, 0.42, 1.0],
          transform: GradientRotation(_startAngle - math.pi / 2),
        ).createShader(innerRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = innerStroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(innerRect, _startAngle, _sweep * fill, false, fillPaint);

      for (final blur in [22.0, 14.0, 8.0]) {
        final glow = Paint()
          ..color = _neonGreen.withValues(alpha: 0.12 + pulse * 0.06)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur)
          ..style = PaintingStyle.stroke
          ..strokeWidth = innerStroke + 4
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(innerRect, _startAngle, _sweep * fill, false, glow);
      }

      final dotAngle = _startAngle + _sweep * fill;
      final dotCenter = Offset(
        center.dx + innerRadius * math.cos(dotAngle),
        center.dy + innerRadius * math.sin(dotAngle),
      );
      canvas.drawCircle(
        dotCenter,
        10,
        Paint()
          ..color = _neonCyan.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawCircle(
        dotCenter,
        6,
        Paint()..color = Colors.white.withValues(alpha: 0.98),
      );
    }

    _drawTicks(canvas, center, outerRadius + 4, scheme);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius, ColorScheme scheme) {
    final textStyle = TextStyle(
      color: scheme.secondary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    for (var i = 0; i < speedGaugeTickMbps.length; i++) {
      final fraction = i / (speedGaugeTickMbps.length - 1);
      final angle = _startAngle + _sweep * fraction;
      final outer = Offset(
        center.dx + (radius + 8) * math.cos(angle),
        center.dy + (radius + 8) * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - 4) * math.cos(angle),
        center.dy + (radius - 4) * math.sin(angle),
      );
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = scheme.outline.withValues(alpha: 0.65)
          ..strokeWidth = 1.5,
      );

      final value = speedGaugeTickMbps[i];
      final label = value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(1);
      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelRadius = radius + 22;
      final lp = Offset(
        center.dx + labelRadius * math.cos(angle) - tp.width / 2,
        center.dy + labelRadius * math.sin(angle) - tp.height / 2,
      );
      tp.paint(canvas, lp);
    }
  }

  void _drawDashedArc(
    Canvas canvas,
    Rect rect,
    double startAngle,
    double sweep,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    final path = Path()..addArc(rect, startAngle, sweep);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        final extractPath = metric.extractPath(
          distance,
          next.clamp(0, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedGaugePainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.pulse != pulse ||
        oldDelegate.phase != phase;
  }
}
