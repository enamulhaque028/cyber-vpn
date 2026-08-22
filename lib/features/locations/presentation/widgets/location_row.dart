import 'package:cached_network_image/cached_network_image.dart';
import 'package:cyber_vpn/core/theme/app_radii.dart';
import 'package:cyber_vpn/core/widgets/ping_bar.dart';
import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';
import 'package:flutter/material.dart';

class LocationRow extends StatelessWidget {
  const LocationRow({
    super.key,
    required this.location,
    required this.rttMs,
    required this.favorite,
    required this.selected,
    required this.onSelect,
    required this.onToggleFavorite,
  });

  final VpnLocation location;
  final Map<int, int?> rttMs;
  final bool favorite;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final probed = rttMs.containsKey(location.id);
    final muted = location.isPremium;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? scheme.primary.withValues(alpha: 0.06)
            : scheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          side: BorderSide(
            color: selected
                ? scheme.primary.withValues(alpha: 0.28)
                : scheme.outline.withValues(alpha: 0.45),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _FlagAvatar(
                  flagUrl: location.flagUrl,
                  selected: selected,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              color: muted
                                  ? scheme.onSurface.withValues(alpha: 0.55)
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          Text(
                            location.listSubtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: scheme.secondary,
                                  height: 1.35,
                                ),
                          ),
                          if (location.isPremium)
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: scheme.secondary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PingBar(
                      variant: PingBarVariant.badge,
                      loading: !probed,
                      milliseconds: rttMs[location.id],
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      tooltip: favorite ? 'Remove favorite' : 'Add favorite',
                      onPressed: onToggleFavorite,
                      icon: Icon(
                        favorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 20,
                        color: favorite ? scheme.primary : scheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlagAvatar extends StatelessWidget {
  const _FlagAvatar({required this.flagUrl, required this.selected});

  final String flagUrl;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const size = 44.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? scheme.primary.withValues(alpha: 0.55)
              : scheme.outline.withValues(alpha: 0.35),
          width: selected ? 2 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.12),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: flagUrl.isEmpty
            ? ColoredBox(
                color: scheme.surface,
                child: Icon(
                  Icons.public_rounded,
                  color: scheme.secondary,
                  size: 22,
                ),
              )
            : CachedNetworkImage(
                imageUrl: flagUrl,
                fit: BoxFit.cover,
                width: size,
                height: size,
                placeholder: (_, _) => ColoredBox(
                  color: scheme.surface,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.outline,
                      ),
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => ColoredBox(
                  color: scheme.surface,
                  child: Icon(
                    Icons.public_rounded,
                    color: scheme.secondary,
                    size: 22,
                  ),
                ),
              ),
      ),
    );
  }
}
