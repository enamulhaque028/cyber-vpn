import 'dart:async';

import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';
import 'package:cyber_vpn/features/locations/domain/repositories/locations_repository.dart';
import 'package:cyber_vpn/features/locations/domain/repositories/server_probe.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'locations_bloc.freezed.dart';
part 'locations_event.dart';
part 'locations_state.dart';

class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  LocationsBloc(this._repository, this._probe)
    : super(const LocationsState.loading()) {
    on<LocationsStarted>(_onStarted);
    on<LocationsQueryChanged>(_onQuery);
    on<LocationsRttMeasured>(_onRtt);
  }

  final LocationsRepository _repository;
  final ServerProbe _probe;
  int _probeEpoch = 0;

  Future<void> _onStarted(
    LocationsStarted event,
    Emitter<LocationsState> emit,
  ) async {
    emit(const LocationsState.loading());
    try {
      final credentials = await _repository.getCredentials(
        forceRefresh: event.forceRefresh,
      );
      final all = await _repository.getLocations(
        forceRefresh: event.forceRefresh,
      );
      emit(
        LocationsState.loaded(all: all, visible: all, credentials: credentials),
      );
      unawaited(_probeAll(all));
    } catch (e) {
      emit(LocationsState.failure(e.toString()));
    }
  }

  void _onQuery(LocationsQueryChanged event, Emitter<LocationsState> emit) {
    final current = state;
    if (current is! LocationsLoaded) return;
    final q = event.query.toLowerCase();
    final visible = q.isEmpty
        ? current.all
        : current.all
              .where(
                (l) =>
                    l.country.toLowerCase().contains(q) ||
                    l.city.toLowerCase().contains(q) ||
                    l.title.toLowerCase().contains(q),
              )
              .toList();
    emit(current.copyWith(visible: visible, query: event.query));
  }

  void _onRtt(LocationsRttMeasured event, Emitter<LocationsState> emit) {
    final current = state;
    if (current is! LocationsLoaded) return;
    emit(
      current.copyWith(
        rttMs: {...current.rttMs, event.id: event.milliseconds},
      ),
    );
  }

  Future<void> _probeAll(List<VpnLocation> all) async {
    final epoch = ++_probeEpoch;
    var next = 0;
    Future<void> worker() async {
      while (true) {
        if (epoch != _probeEpoch || isClosed) return;
        final index = next++;
        if (index >= all.length) return;
        final loc = all[index];
        final ms = await _probe.measureMs(loc.config);
        if (epoch != _probeEpoch || isClosed) return;
        add(LocationsEvent.rttMeasured(loc.id, ms));
      }
    }

    await Future.wait(List.generate(4, (_) => worker()));
  }
}
