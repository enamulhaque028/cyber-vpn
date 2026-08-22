import 'dart:async';
import 'dart:convert';

import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';
import 'package:cyber_vpn/features/locations/domain/repositories/locations_repository.dart';
import 'package:cyber_vpn/features/locations/domain/repositories/server_probe.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locations_bloc.freezed.dart';
part 'locations_event.dart';
part 'locations_state.dart';

class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  LocationsBloc(this._repository, this._probe, this._prefs)
    : super(const LocationsState.loading()) {
    on<LocationsStarted>(_onStarted);
    on<LocationsQueryChanged>(_onQuery);
    on<LocationsRttMeasured>(_onRtt);
    on<LocationsFavoriteToggled>(_onFavorite);
    on<LocationsRecentRemembered>(_onRecent);
    on<LocationsSyncRequested>(_onSync);
  }

  final LocationsRepository _repository;
  final ServerProbe _probe;
  final SharedPreferences _prefs;
  int _probeEpoch = 0;

  List<int> _readIds(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => (e as num).toInt())
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeIds(String key, List<int> ids) async {
    await _prefs.setString(key, jsonEncode(ids));
  }

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
        LocationsState.loaded(
          all: all,
          visible: all,
          credentials: credentials,
          favoriteIds: _readIds(AppConfig.prefsFavoriteServerIds),
          recentIds: _readIds(AppConfig.prefsRecentServerIds),
        ),
      );
      unawaited(_probeAll(all));
    } catch (e) {
      emit(LocationsState.failure(e.toString()));
    }
  }

  Future<void> _onSync(
    LocationsSyncRequested event,
    Emitter<LocationsState> emit,
  ) async {
    final previous = state;
    if (previous is LocationsLoaded) {
      if (previous.syncing) return;
      emit(previous.copyWith(syncing: true, syncError: null));
    } else {
      emit(const LocationsState.loading());
    }

    try {
      final synced = await _repository.syncFromNetwork();
      final q = previous is LocationsLoaded ? previous.query : '';
      final visible = q.isEmpty
          ? synced.servers
          : synced.servers
                .where(
                  (l) =>
                      l.country.toLowerCase().contains(q.toLowerCase()) ||
                      l.region.toLowerCase().contains(q.toLowerCase()) ||
                      l.city.toLowerCase().contains(q.toLowerCase()) ||
                      l.title.toLowerCase().contains(q.toLowerCase()) ||
                      l.protocol.toLowerCase().contains(q.toLowerCase()) ||
                      l.source.toLowerCase().contains(q.toLowerCase()),
                )
                .toList();
      emit(
        LocationsState.loaded(
          all: synced.servers,
          visible: visible,
          credentials: synced.credentials,
          query: q,
          favoriteIds: _readIds(AppConfig.prefsFavoriteServerIds),
          recentIds: _readIds(AppConfig.prefsRecentServerIds),
        ),
      );
      unawaited(_probeAll(synced.servers));
    } catch (e) {
      if (previous is LocationsLoaded) {
        emit(
          previous.copyWith(
            syncing: false,
            syncError: 'Couldn’t sync. Check your connection.',
          ),
        );
      } else {
        emit(LocationsState.failure(e.toString()));
      }
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
                    l.region.toLowerCase().contains(q) ||
                    l.city.toLowerCase().contains(q) ||
                    l.title.toLowerCase().contains(q) ||
                    l.protocol.toLowerCase().contains(q) ||
                    l.source.toLowerCase().contains(q),
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

  Future<void> _onFavorite(
    LocationsFavoriteToggled event,
    Emitter<LocationsState> emit,
  ) async {
    final current = state;
    if (current is! LocationsLoaded) return;
    final next = [...current.favoriteIds];
    if (next.contains(event.id)) {
      next.remove(event.id);
    } else {
      next.insert(0, event.id);
    }
    await _writeIds(AppConfig.prefsFavoriteServerIds, next);
    emit(current.copyWith(favoriteIds: next));
  }

  Future<void> _onRecent(
    LocationsRecentRemembered event,
    Emitter<LocationsState> emit,
  ) async {
    final current = state;
    final base = current is LocationsLoaded
        ? current.recentIds
        : _readIds(AppConfig.prefsRecentServerIds);
    final next = [event.id, ...base.where((e) => e != event.id)].take(5).toList();
    await _writeIds(AppConfig.prefsRecentServerIds, next);
    if (current is LocationsLoaded) {
      emit(current.copyWith(recentIds: next));
    }
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
