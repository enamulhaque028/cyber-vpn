import 'package:flutter/material.dart';

class SpeedTestGradientButton extends StatelessWidget {
  const SpeedTestGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  static const _green = Color(0xFF00E6A1);
  static const _blue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: enabled
            ? const LinearGradient(
                colors: [_green, _blue],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: enabled ? null : Theme.of(context).colorScheme.outline,
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: _green.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: _blue.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: enabled
                          ? const Color(0xFF031510)
                          : Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
