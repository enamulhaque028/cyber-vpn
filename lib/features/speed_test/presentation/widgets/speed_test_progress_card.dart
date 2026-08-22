import 'dart:math' as math;

import 'package:cyber_vpn/core/theme/app_radii.dart';
import 'package:cyber_vpn/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:cyber_vpn/features/speed_test/presentation/widgets/speed_gauge_scale.dart';
import 'package:flutter/material.dart';

class SpeedTestProgressCard extends StatefulWidget {
  const SpeedTestProgressCard({
    super.key,
    required this.phase,
    required this.elapsedSeconds,
    required this.preparing,
  });

  final SpeedTestMeasurePhase phase;
  final int elapsedSeconds;
  final bool preparing;

  @override
  State<SpeedTestProgressCard> createState() => _SpeedTestProgressCardState();
}

class _SpeedTestProgressCardState extends State<SpeedTestProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  String _title() {
    if (widget.preparing) return 'Preparing speed test…';
    return switch (widget.phase) {
      SpeedTestMeasurePhase.ping => 'Measuring ping…',
      SpeedTestMeasurePhase.download => 'Testing download…',
      SpeedTestMeasurePhase.upload => 'Testing upload…',
    };
  }

  int _filledDots() {
    if (widget.preparing) return 1;
    return switch (widget.phase) {
      SpeedTestMeasurePhase.ping => 1,
      SpeedTestMeasurePhase.download => 2,
      SpeedTestMeasurePhase.upload => 4,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final remaining = (speedTestTotalSeconds - widget.elapsedSeconds)
        .clamp(0, speedTestTotalSeconds);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 24,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _PulseWavePainter(
                    color: scheme.primary,
                    phase: _waveController.value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.preparing ? 'Starting' : '$remaining s remaining',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.secondary,
                      ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (index) {
              final active = index < _filledDots();
              return Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.only(left: index == 0 ? 0 : 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? scheme.primary
                      : scheme.outline.withValues(alpha: 0.55),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.45),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PulseWavePainter extends CustomPainter {
  _PulseWavePainter({required this.color, required this.phase});

  final Color color;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (var x = 0.0; x <= size.width; x += 1) {
      final t = (x / size.width + phase) * math.pi * 4;
      final y = size.height / 2 + math.sin(t) * (size.height * 0.35);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PulseWavePainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.color != color;
  }
}
