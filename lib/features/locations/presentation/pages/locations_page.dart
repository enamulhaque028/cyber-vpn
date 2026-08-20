import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cyber_vpn/app/router.dart';
import 'package:cyber_vpn/core/widgets/ping_bar.dart';
import 'package:cyber_vpn/features/locations/presentation/bloc/locations_bloc.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/session_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Locations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (q) => context.read<LocationsBloc>().add(
                LocationsEvent.queryChanged(q),
              ),
              decoration: const InputDecoration(
                hintText: 'Search country or city',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<LocationsBloc, LocationsState>(
              builder: (context, state) {
                return switch (state) {
                  LocationsLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  LocationsFailure(:final message) => Center(
                    child: Text(message),
                  ),
                  LocationsLoaded(:final visible, :final rttMs) =>
                    ListView.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final loc = visible[index];
                      final probed = rttMs.containsKey(loc.id);
                      return ListTile(
                        leading: loc.networkFlagUrl.isEmpty
                            ? const Icon(Icons.flag_outlined)
                            : ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: loc.networkFlagUrl,
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
                            PingBar(
                              loading: !probed,
                              milliseconds: rttMs[loc.id],
                            ),
                            if (loc.isPremium) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.lock_outline, size: 18),
                            ],
                          ],
                        ),
                        onTap: () {
                          if (loc.isPremium) {
                            context.router.push(const PaywallRoute());
                            return;
                          }
                          context.read<SessionBloc>().add(
                            SessionEvent.serverChosen(loc),
                          );
                          context.router.maybePop();
                        },
                      );
                    },
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
