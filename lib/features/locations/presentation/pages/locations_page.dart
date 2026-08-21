import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cyber_vpn/app/router.dart';
import 'package:cyber_vpn/core/widgets/ping_bar.dart';
import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';
import 'package:cyber_vpn/features/locations/presentation/bloc/locations_bloc.dart';
import 'package:cyber_vpn/features/locations/presentation/locations_sync.dart';
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Locations'),
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
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Favorites'),
              Tab(text: 'Recent'),
            ],
          ),
        ),
        body: BlocBuilder<LocationsBloc, LocationsState>(
          builder: (context, state) {
            return switch (state) {
              LocationsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              LocationsFailure(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: () => syncLocationsCatalog(context),
                        child: const Text('Retry sync'),
                      ),
                    ],
                  ),
                ),
              ),
              LocationsLoaded(
                :final all,
                :final visible,
                :final rttMs,
                :final favoriteIds,
                :final recentIds,
                :final syncing,
              ) =>
                TabBarView(
                  children: [
                    _AllTab(
                      visible: visible,
                      rttMs: rttMs,
                      favoriteIds: favoriteIds,
                      syncing: syncing,
                      onSelect: (loc) => _select(context, loc),
                      onToggleFavorite: (id) => context
                          .read<LocationsBloc>()
                          .add(LocationsEvent.favoriteToggled(id)),
                      onQueryChanged: (q) => context.read<LocationsBloc>().add(
                        LocationsEvent.queryChanged(q),
                      ),
                      onRefresh: () => syncLocationsCatalog(context),
                    ),
                    _FilteredListTab(
                      emptyMessage: 'Star a location to save it here.',
                      locations: favoriteIds
                          .map((id) => _byId(all, id))
                          .whereType<VpnLocation>()
                          .toList(),
                      rttMs: rttMs,
                      favoriteIds: favoriteIds,
                      onSelect: (loc) => _select(context, loc),
                      onToggleFavorite: (id) => context
                          .read<LocationsBloc>()
                          .add(LocationsEvent.favoriteToggled(id)),
                      onRefresh: () => syncLocationsCatalog(context),
                    ),
                    _FilteredListTab(
                      emptyMessage: 'Locations you pick will show up here.',
                      locations: recentIds
                          .map((id) => _byId(all, id))
                          .whereType<VpnLocation>()
                          .toList(),
                      rttMs: rttMs,
                      favoriteIds: favoriteIds,
                      onSelect: (loc) => _select(context, loc),
                      onToggleFavorite: (id) => context
                          .read<LocationsBloc>()
                          .add(LocationsEvent.favoriteToggled(id)),
                      onRefresh: () => syncLocationsCatalog(context),
                    ),
                  ],
                ),
            };
          },
        ),
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
    required this.rttMs,
    required this.favoriteIds,
    required this.syncing,
    required this.onSelect,
    required this.onToggleFavorite,
    required this.onQueryChanged,
    required this.onRefresh,
  });

  final List<VpnLocation> visible;
  final Map<int, int?> rttMs;
  final List<int> favoriteIds;
  final bool syncing;
  final void Function(VpnLocation) onSelect;
  final void Function(int) onToggleFavorite;
  final void Function(String) onQueryChanged;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (syncing) const LinearProgressIndicator(minHeight: 2),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            onChanged: onQueryChanged,
            decoration: const InputDecoration(
              hintText: 'Search country or city',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: visible.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) => _LocationTile(
                loc: visible[index],
                rttMs: rttMs,
                favorite: favoriteIds.contains(visible[index].id),
                onSelect: onSelect,
                onToggleFavorite: onToggleFavorite,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilteredListTab extends StatelessWidget {
  const _FilteredListTab({
    required this.emptyMessage,
    required this.locations,
    required this.rttMs,
    required this.favoriteIds,
    required this.onSelect,
    required this.onToggleFavorite,
    required this.onRefresh,
  });

  final String emptyMessage;
  final List<VpnLocation> locations;
  final Map<int, int?> rttMs;
  final List<int> favoriteIds;
  final void Function(VpnLocation) onSelect;
  final void Function(int) onToggleFavorite;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: locations.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.4,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        emptyMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: locations.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) => _LocationTile(
                loc: locations[index],
                rttMs: rttMs,
                favorite: favoriteIds.contains(locations[index].id),
                onSelect: onSelect,
                onToggleFavorite: onToggleFavorite,
              ),
            ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.loc,
    required this.rttMs,
    required this.favorite,
    required this.onSelect,
    required this.onToggleFavorite,
  });

  final VpnLocation loc;
  final Map<int, int?> rttMs;
  final bool favorite;
  final void Function(VpnLocation) onSelect;
  final void Function(int) onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final probed = rttMs.containsKey(loc.id);
    return ListTile(
      leading: loc.flagUrl.isEmpty
          ? const Icon(Icons.flag_outlined)
          : ClipOval(
              child: CachedNetworkImage(
                imageUrl: loc.flagUrl,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
      title: Text(loc.displayName),
      subtitle: Text(loc.isPremium ? 'Premium' : 'Free'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => onToggleFavorite(loc.id),
            icon: Icon(
              favorite ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 22,
            ),
          ),
          PingBar(loading: !probed, milliseconds: rttMs[loc.id]),
          if (loc.isPremium) ...[
            const SizedBox(width: 8),
            const Icon(Icons.lock_outline, size: 18),
          ],
        ],
      ),
      onTap: () => onSelect(loc),
    );
  }
}
