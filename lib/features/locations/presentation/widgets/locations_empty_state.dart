import 'package:cyber_vpn/core/theme/app_radii.dart';
import 'package:flutter/material.dart';

enum LocationsEmptyKind { empty, error, loading }

class LocationsEmptyState extends StatelessWidget {
  const LocationsEmptyState({
    super.key,
    required this.kind,
    this.icon,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  const LocationsEmptyState.loading({super.key})
      : kind = LocationsEmptyKind.loading,
        icon = null,
        title = null,
        message = null,
        actionLabel = null,
        onAction = null;

  const LocationsEmptyState.empty({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  })  : kind = LocationsEmptyKind.empty,
        actionLabel = null,
        onAction = null;

  const LocationsEmptyState.error({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  })  : kind = LocationsEmptyKind.error,
        icon = Icons.cloud_off_outlined,
        title = 'Could not load servers';

  final LocationsEmptyKind kind;
  final IconData? icon;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (kind == LocationsEmptyKind.loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading servers…',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.secondary,
                  ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: scheme.outline),
                  ),
                  child: Icon(icon, size: 36, color: scheme.secondary),
                ),
                const SizedBox(height: 20),
              ],
              if (title != null)
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              if (title != null && message != null) const SizedBox(height: 8),
              if (message != null)
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.secondary,
                        height: 1.4,
                      ),
                ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
