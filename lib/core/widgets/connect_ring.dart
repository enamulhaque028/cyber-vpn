import 'package:flutter/material.dart';

enum ConnectRingPhase { idle, connecting, protected }

class ConnectRing extends StatelessWidget {
  const ConnectRing({super.key, required this.phase, required this.onPressed});

  final ConnectRingPhase phase;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isOn = phase == ConnectRingPhase.protected;
    final color = isOn ? scheme.primary : scheme.secondary;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        width: 196,
        height: 196,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.surfaceContainerHighest,
          border: Border.all(
            color: color.withValues(alpha: isOn ? 0.9 : 0.35),
            width: 3,
          ),
          boxShadow: isOn
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.28),
                    blurRadius: 32,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (phase == ConnectRingPhase.connecting)
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: scheme.primary,
                ),
              )
            else
              Icon(
                isOn ? Icons.shield : Icons.shield_outlined,
                size: 44,
                color: color,
              ),
            const SizedBox(height: 12),
            Text(
              switch (phase) {
                ConnectRingPhase.idle => 'Protect',
                ConnectRingPhase.connecting => 'Connecting',
                ConnectRingPhase.protected => 'Protected',
              },
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
