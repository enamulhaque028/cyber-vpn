import 'package:flutter/material.dart';

/// Relative latency bar. Does not show host or IP.
class PingBar extends StatelessWidget {
  const PingBar({super.key, this.milliseconds, this.loading = false});

  final int? milliseconds;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = switch (milliseconds) {
      null when loading => 0.15,
      null => 0.08,
      final ms when ms <= 80 => 1.0,
      final ms when ms <= 160 => 0.7,
      final ms when ms <= 280 => 0.45,
      _ => 0.22,
    };
    final color = switch (milliseconds) {
      null when loading => scheme.outline,
      null => scheme.error.withValues(alpha: 0.7),
      final ms when ms <= 80 => scheme.primary,
      final ms when ms <= 160 => scheme.tertiary,
      _ => scheme.error.withValues(alpha: 0.85),
    };

    return SizedBox(
      width: 52,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  ColoredBox(
                    color: scheme.outline.withValues(alpha: 0.35),
                    child: const SizedBox.expand(),
                  ),
                  FractionallySizedBox(
                    widthFactor: fill,
                    alignment: Alignment.centerLeft,
                    child: ColoredBox(color: color, child: const SizedBox.expand()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loading
                ? '…'
                : (milliseconds == null ? '—' : '${milliseconds}ms'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.secondary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
