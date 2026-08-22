import 'package:cyber_vpn/core/theme/app_radii.dart';
import 'package:flutter/material.dart';

enum PingBarVariant { bar, badge }

/// Relative latency indicator. Does not show host or IP.
class PingBar extends StatelessWidget {
  const PingBar({
    super.key,
    this.milliseconds,
    this.loading = false,
    this.variant = PingBarVariant.bar,
  });

  final int? milliseconds;
  final bool loading;
  final PingBarVariant variant;

  @override
  Widget build(BuildContext context) {
    if (variant == PingBarVariant.badge) {
      return _LatencyBadge(milliseconds: milliseconds, loading: loading);
    }
    return _LatencyBar(milliseconds: milliseconds, loading: loading);
  }
}

class _LatencyBar extends StatelessWidget {
  const _LatencyBar({required this.milliseconds, required this.loading});

  final int? milliseconds;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = _fillFactor(milliseconds, loading);
    final color = _latencyColor(scheme, milliseconds, loading);

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
            _label(milliseconds, loading),
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

class _LatencyBadge extends StatelessWidget {
  const _LatencyBadge({required this.milliseconds, required this.loading});

  final int? milliseconds;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _latencyColor(scheme, milliseconds, loading);
    final label = _label(milliseconds, loading);

    return Container(
      constraints: const BoxConstraints(minWidth: 56),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
      ),
      child: loading
          ? SizedBox(
              width: 40,
              height: 14,
              child: Center(
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: scheme.secondary,
                  ),
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ],
            ),
    );
  }
}

double _fillFactor(int? milliseconds, bool loading) {
  return switch (milliseconds) {
    null when loading => 0.15,
    null => 0.08,
    final ms when ms <= 80 => 1.0,
    final ms when ms <= 160 => 0.7,
    final ms when ms <= 280 => 0.45,
    _ => 0.22,
  };
}

Color _latencyColor(ColorScheme scheme, int? milliseconds, bool loading) {
  return switch (milliseconds) {
    null when loading => scheme.outline,
    null => scheme.error.withValues(alpha: 0.7),
    final ms when ms <= 80 => scheme.primary,
    final ms when ms <= 160 => scheme.tertiary,
    _ => scheme.error.withValues(alpha: 0.85),
  };
}

String _label(int? milliseconds, bool loading) {
  if (loading) return '…';
  if (milliseconds == null) return '—';
  return '${milliseconds}ms';
}
