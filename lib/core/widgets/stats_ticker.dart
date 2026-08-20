import 'package:cyber_vpn/core/theme/app_radii.dart';
import 'package:flutter/material.dart';

class StatsTicker extends StatelessWidget {
  const StatsTicker({
    super.key,
    required this.duration,
    required this.downRate,
    required this.upRate,
    this.active = false,
  });

  final String duration;
  final String downRate;
  final String upRate;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: active ? scheme.onSurface : scheme.secondary,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontWeight: FontWeight.w600,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(duration, style: style)),
          Text('↓ $downRate', style: style),
          const SizedBox(width: 12),
          Text('↑ $upRate', style: style),
        ],
      ),
    );
  }
}
