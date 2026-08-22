import 'package:cyber_vpn/core/theme/app_radii.dart';
import 'package:flutter/material.dart';

enum PingBarVariant { bar, badge }

/// TCP reachability latency bands (ms): good ≤350, ok ≤700, slow above.
const _kLatencyGoodMs = 350;
const _kLatencyOkMs = 700;

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
    final dotOnly = !loading && label.isEmpty;

    return Container(
      constraints: dotOnly ? null : const BoxConstraints(minWidth: 56),
      padding: dotOnly
          ? const EdgeInsets.all(6)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                    color: scheme.primary,
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
                if (label.isNotEmpty) ...[
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
              ],
            ),
    );
  }
}

double _fillFactor(int? milliseconds, bool loading) {
  return switch (milliseconds) {
    null when loading => 0.15,
    null => 0.08,
    final ms when ms <= _kLatencyGoodMs => 1.0,
    final ms when ms <= _kLatencyOkMs => 0.55,
    _ => 0.22,
  };
}

Color _latencyColor(ColorScheme scheme, int? milliseconds, bool loading) {
  return switch (milliseconds) {
    null when loading => scheme.primary.withValues(alpha: 0.45),
    null => _latencyOrange(scheme),
    final ms when ms <= _kLatencyGoodMs => scheme.primary,
    final ms when ms <= _kLatencyOkMs => _latencyOrange(scheme),
    _ => _latencyGrey(scheme),
  };
}

Color _latencyOrange(ColorScheme scheme) {
  return scheme.brightness == Brightness.dark
      ? const Color(0xFFFF7043)
      : const Color(0xFFE64A19);
}

Color _latencyGrey(ColorScheme scheme) => scheme.secondary;

String _label(int? milliseconds, bool loading) {
  if (loading) return '…';
  if (milliseconds == null) return '';
  return '${milliseconds}ms';
}
