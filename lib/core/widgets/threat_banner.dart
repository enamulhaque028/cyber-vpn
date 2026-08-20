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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.fastOutSlowIn,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: accent.withValues(alpha: protected ? 0.9 : 0.45),
          width: protected ? 1.4 : 1,
        ),
        boxShadow: protected
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.28),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 320),
              curve: Curves.fastOutSlowIn,
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: protected ? FontWeight.w600 : FontWeight.w400,
                  ) ??
                  const TextStyle(),
              child: Text(message),
            ),
          ),
        ],
      ),
    );
  }
}
