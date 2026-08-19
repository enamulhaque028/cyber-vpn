import 'package:cyber_vpn/core/theme/app_radii.dart';
import 'package:flutter/material.dart';

class ThreatBanner extends StatelessWidget {
  const ThreatBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_find, color: scheme.secondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
