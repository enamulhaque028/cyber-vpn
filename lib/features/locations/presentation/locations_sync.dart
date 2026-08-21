import 'package:cyber_vpn/features/locations/presentation/bloc/locations_bloc.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/session_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manual catalog sync (Locations pull-to-refresh + Settings).
///
/// Uses [LocationsEvent.syncRequested] → network only (throws keep old cache).
/// On success, reseeds [SessionBloc] selected server / credentials.
Future<void> syncLocationsCatalog(BuildContext context) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final locationsBloc = context.read<LocationsBloc>();
  final sessionBloc = context.read<SessionBloc>();

  if (sessionBloc.state.phase == SessionPhase.connecting) {
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Wait until Protect finishes connecting.'),
      ),
    );
    return;
  }

  final before = locationsBloc.state;
  if (before is LocationsLoaded && before.syncing) return;

  locationsBloc.add(const LocationsEvent.syncRequested());

  final next = await locationsBloc.stream.firstWhere((s) {
    if (s is LocationsFailure) return true;
    if (s is LocationsLoaded && !s.syncing) return true;
    return false;
  });

  if (!context.mounted) return;

  if (next is LocationsLoaded) {
    if (next.syncError != null) {
      messenger?.showSnackBar(SnackBar(content: Text(next.syncError!)));
      return;
    }
    sessionBloc.add(
      SessionEvent.started(
        locations: next.all,
        credentials: next.credentials,
      ),
    );
    messenger?.showSnackBar(
      SnackBar(content: Text('Servers updated (${next.all.length})')),
    );
    return;
  }

  if (next is LocationsFailure) {
    messenger?.showSnackBar(SnackBar(content: Text(next.message)));
  }
}
