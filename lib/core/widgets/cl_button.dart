import 'package:cyber_vpn/core/theme/app_radii.dart';
import 'package:flutter/material.dart';

enum ClButtonVariant { primary, ghost, destructive }

class ClButton extends StatelessWidget {
  const ClButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ClButtonVariant.primary,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final ClButtonVariant variant;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final child = Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
    );

    final button = switch (variant) {
      ClButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: shape,
        ),
        child: child,
      ),
      ClButtonVariant.ghost => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: shape,
          side: BorderSide(color: scheme.outline),
        ),
        child: child,
      ),
      ClButtonVariant.destructive => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: scheme.error,
          foregroundColor: scheme.onError,
          minimumSize: const Size.fromHeight(52),
          shape: shape,
        ),
        child: child,
      ),
    };

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
