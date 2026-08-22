import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cyber_vpn/app/router.dart';
import 'package:cyber_vpn/core/theme/app_radii.dart';
import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';
import 'package:cyber_vpn/features/locations/presentation/bloc/locations_bloc.dart';
import 'package:cyber_vpn/features/locations/presentation/locations_list_utils.dart';
import 'package:cyber_vpn/features/locations/presentation/locations_sync.dart';
import 'package:cyber_vpn/features/locations/presentation/widgets/location_row.dart';
import 'package:cyber_vpn/features/locations/presentation/widgets/locations_empty_state.dart';
import 'package:cyber_vpn/features/locations/presentation/widgets/locations_search_field.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/session_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  void _select(BuildContext context, VpnLocation loc) {
    if (loc.isPremium) {
      context.router.push(const PaywallRoute());
      return;
    }
    context.read<LocationsBloc>().add(LocationsEvent.recentRemembered(loc.id));
    context.read<SessionBloc>().add(SessionEvent.serverChosen(loc));
    context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Locations',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
          ),
          actions: [
            BlocBuilder<LocationsBloc, LocationsState>(
              buildWhen: (p, n) =>
                  (p is LocationsLoaded && p.syncing) !=
                  (n is LocationsLoaded && n.syncing),
              builder: (context, state) {
                final syncing = state is LocationsLoaded && state.syncing;
                return IconButton(
                  tooltip: 'Sync servers',
                  onPressed: syncing
                      ? null
                      : () => syncLocationsCatalog(context),
                  icon: syncing
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.primary,
                          ),
                        )
                      : const Icon(Icons.sync_rounded),
                );
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocBuilder<LocationsBloc, LocationsState>(
              buildWhen: (p, n) =>
                  (p is LocationsLoaded && p.syncing) !=
                  (n is LocationsLoaded && n.syncing),
              builder: (context, state) {
                final syncing = state is LocationsLoaded && state.syncing;
                if (!syncing) return const SizedBox.shrink();
                return LinearProgressIndicator(
                  minHeight: 2,
                  color: scheme.primary,
                  backgroundColor: scheme.outline.withValues(alpha: 0.25),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: _LocationsTabBar(scheme: scheme),
            ),
            Expanded(
              child: BlocBuilder<LocationsBloc, LocationsState>(
                builder: (context, state) {
                  return switch (state) {
                    LocationsLoading() => const LocationsEmptyState.loading(),
                    LocationsFailure(:final message) =>
                      LocationsEmptyState.error(
                        message: message,
                        actionLabel: 'Retry sync',
                        onAction: () => syncLocationsCatalog(context),
                      ),
                    LocationsLoaded(
                      :final all,
                      :final visible,
                      :final rttMs,
                      :final favoriteIds,
                      :final recentIds,
                      :final query,
                    ) =>
                      BlocBuilder<SessionBloc, SessionState>(
                        buildWhen: (p, n) => p.selected?.id != n.selected?.id,
                        builder: (context, session) {
                          final selectedId = session.selected?.id;
                          return TabBarView(
                            children: [
                              _AllTab(
                                visible: visible,
                                query: query,
                                rttMs: rttMs,
                                favoriteIds: favoriteIds,
                                selectedId: selectedId,
                                onSelect: (loc) => _select(context, loc),
                                onToggleFavorite: (id) => context
                                    .read<LocationsBloc>()
                                    .add(LocationsEvent.favoriteToggled(id)),
                                onQueryChanged: (q) => context
                                    .read<LocationsBloc>()
                                    .add(LocationsEvent.queryChanged(q)),
                              ),
                              _FilteredListTab(
                                icon: Icons.star_outline_rounded,
                                title: 'No favorites yet',
                                emptyMessage:
                                    'Star a location on the All tab to save it here.',
                                locations: favoriteIds
                                    .map((id) => _byId(all, id))
                                    .whereType<VpnLocation>()
                                    .toList(),
                                rttMs: rttMs,
                                favoriteIds: favoriteIds,
                                selectedId: selectedId,
                                onSelect: (loc) => _select(context, loc),
                                onToggleFavorite: (id) => context
                                    .read<LocationsBloc>()
                                    .add(LocationsEvent.favoriteToggled(id)),
                              ),
                              _FilteredListTab(
                                icon: Icons.history_rounded,
                                title: 'No recent locations',
                                emptyMessage:
                                    'Locations you pick will show up here.',
                                locations: recentIds
                                    .map((id) => _byId(all, id))
                                    .whereType<VpnLocation>()
                                    .toList(),
                                rttMs: rttMs,
                                favoriteIds: favoriteIds,
                                selectedId: selectedId,
                                onSelect: (loc) => _select(context, loc),
                                onToggleFavorite: (id) => context
                                    .read<LocationsBloc>()
                                    .add(LocationsEvent.favoriteToggled(id)),
                              ),
                            ],
                          );
                        },
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationsTabBar extends StatelessWidget {
  const _LocationsTabBar({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
      ),
      child: TabBar(
        dividerHeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm - 4),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        labelColor: scheme.onSurface,
        unselectedLabelColor: scheme.secondary,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Favorites'),
          Tab(text: 'Recent'),
        ],
      ),
    );
  }
}

VpnLocation? _byId(List<VpnLocation> all, int id) {
  for (final l in all) {
    if (l.id == id) return l;
  }
  return null;
}

class _AllTab extends StatelessWidget {
  const _AllTab({
    required this.visible,
    required this.query,
    required this.rttMs,
    required this.favoriteIds,
    required this.selectedId,
    required this.onSelect,
    required this.onToggleFavorite,
    required this.onQueryChanged,
  });

  final List<VpnLocation> visible;
  final String query;
  final Map<int, int?> rttMs;
  final List<int> favoriteIds;
  final int? selectedId;
  final void Function(VpnLocation) onSelect;
  final void Function(int) onToggleFavorite;
  final void Function(String) onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final searching = query.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: LocationsSearchField(
            initialValue: query,
            onChanged: onQueryChanged,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: visible.isEmpty
              ? ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.35,
                      child: LocationsEmptyState.empty(
                        icon: Icons.search_off_rounded,
                        title: 'No matches',
                        message: searching
                            ? 'Try another country, city, or region.'
                            : 'No servers in the catalog.',
                      ),
                    ),
                  ],
                )
              : searching
                  ? _FlatLocationList(
                      locations: sortByPing(visible, rttMs),
                      rttMs: rttMs,
                      favoriteIds: favoriteIds,
                      selectedId: selectedId,
                      onSelect: onSelect,
                      onToggleFavorite: onToggleFavorite,
                    )
                  : _GroupedLocationList(
                      grouped: groupByCountry(visible, rttMs),
                      rttMs: rttMs,
                      favoriteIds: favoriteIds,
                      selectedId: selectedId,
                      onSelect: onSelect,
                      onToggleFavorite: onToggleFavorite,
                    ),
        ),
      ],
    );
  }
}

class _FilteredListTab extends StatelessWidget {
  const _FilteredListTab({
    required this.icon,
    required this.title,
    required this.emptyMessage,
    required this.locations,
    required this.rttMs,
    required this.favoriteIds,
    required this.selectedId,
    required this.onSelect,
    required this.onToggleFavorite,
  });

  final IconData icon;
  final String title;
  final String emptyMessage;
  final List<VpnLocation> locations;
  final Map<int, int?> rttMs;
  final List<int> favoriteIds;
  final int? selectedId;
  final void Function(VpnLocation) onSelect;
  final void Function(int) onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.4,
            child: LocationsEmptyState.empty(
              icon: icon,
              title: title,
              message: emptyMessage,
            ),
          ),
        ],
      );
    }

    return _FlatLocationList(
      locations: sortByPing(locations, rttMs),
      rttMs: rttMs,
      favoriteIds: favoriteIds,
      selectedId: selectedId,
      onSelect: onSelect,
      onToggleFavorite: onToggleFavorite,
    );
  }
}

class _FlatLocationList extends StatelessWidget {
  const _FlatLocationList({
    required this.locations,
    required this.rttMs,
    required this.favoriteIds,
    required this.selectedId,
    required this.onSelect,
    required this.onToggleFavorite,
    this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 24),
  });

  final List<VpnLocation> locations;
  final Map<int, int?> rttMs;
  final List<int> favoriteIds;
  final int? selectedId;
  final void Function(VpnLocation) onSelect;
  final void Function(int) onToggleFavorite;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final loc = locations[index];
        return LocationRow(
          location: loc,
          rttMs: rttMs,
          favorite: favoriteIds.contains(loc.id),
          selected: selectedId == loc.id,
          onSelect: () => onSelect(loc),
          onToggleFavorite: () => onToggleFavorite(loc.id),
        );
      },
    );
  }
}

class _GroupedLocationList extends StatelessWidget {
  const _GroupedLocationList({
    required this.grouped,
    required this.rttMs,
    required this.favoriteIds,
    required this.selectedId,
    required this.onSelect,
    required this.onToggleFavorite,
  });

  final Map<String, List<VpnLocation>> grouped;
  final Map<int, int?> rttMs;
  final List<int> favoriteIds;
  final int? selectedId;
  final void Function(VpnLocation) onSelect;
  final void Function(int) onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final entries = <Object>[];
    for (final country in grouped.keys) {
      final list = grouped[country]!;
      entries.add(_CountryHeader(country, list.length, list.first.flagUrl));
      entries.addAll(list);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        if (entry is _CountryHeader) {
          return _CountrySectionHeader(
            country: entry.country,
            count: entry.count,
            flagUrl: entry.flagUrl,
          );
        }
        final loc = entry as VpnLocation;
        return LocationRow(
          location: loc,
          rttMs: rttMs,
          favorite: favoriteIds.contains(loc.id),
          selected: selectedId == loc.id,
          onSelect: () => onSelect(loc),
          onToggleFavorite: () => onToggleFavorite(loc.id),
        );
      },
    );
  }
}

class _CountryHeader {
  const _CountryHeader(this.country, this.count, this.flagUrl);

  final String country;
  final int count;
  final String flagUrl;
}

class _CountrySectionHeader extends StatelessWidget {
  const _CountrySectionHeader({
    required this.country,
    required this.count,
    required this.flagUrl,
  });

  final String country;
  final int count;
  final String flagUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          if (flagUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: flagUrl,
                width: 24,
                height: 16,
                fit: BoxFit.cover,
              ),
            )
          else
            Icon(Icons.flag_outlined, size: 18, color: scheme.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              country,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
