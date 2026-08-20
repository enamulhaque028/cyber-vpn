import 'package:cyber_vpn/core/theme/app_radii.dart';
import 'package:cyber_vpn/features/session/domain/network_kind.dart';
import 'package:flutter/material.dart';

class ThreatBanner extends StatelessWidget {
  const ThreatBanner({
    super.key,
    required this.kind,
    required this.protected,
  });

  final NetworkKind kind;
  final bool protected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, message, accent) = switch ((kind, protected)) {
      (NetworkKind.none, _) => (
        Icons.wifi_off_rounded,
        'No internet. Connect to Wi‑Fi or cellular.',
        scheme.secondary,
      ),
      (NetworkKind.wifi, true) => (
        Icons.shield_rounded,
        'Protected on this Wi‑Fi.',
        scheme.primary,
      ),
      (NetworkKind.wifi, false) => (
        Icons.wifi_find_rounded,
        'Untrusted Wi‑Fi — Protect this network.',
        scheme.tertiary,
      ),
      (NetworkKind.cellular, true) => (
        Icons.shield_rounded,
        'Protected on cellular.',
        scheme.primary,
      ),
      (NetworkKind.cellular, false) => (
        Icons.signal_cellular_alt_rounded,
        'On cellular — Protect for extra privacy.',
        scheme.secondary,
      ),
      (_, true) => (
        Icons.shield_rounded,
        'Protected on this network.',
        scheme.primary,
      ),
      (_, false) => (
        Icons.wifi_find_rounded,
        'Untrusted network — Protect this device.',
        scheme.tertiary,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
