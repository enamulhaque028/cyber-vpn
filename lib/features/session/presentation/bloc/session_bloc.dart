import 'dart:async';

import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';
import 'package:cyber_vpn/features/locations/domain/repositories/locations_repository.dart';
import 'package:cyber_vpn/features/session/domain/repositories/tunnel_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'session_bloc.freezed.dart';
part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc(this._tunnel, this._locations, this._prefs)
    : super(const SessionState()) {
    on<SessionStarted>(_onStarted);
    on<SessionConnectPressed>(_onConnect);
    on<SessionDisconnectPressed>(_onDisconnect);
    on<SessionServerChosen>(_onServerChosen);
    on<SessionStageUpdated>(_onStage);
    on<SessionStatusUpdated>(_onStatus);
    on<SessionConnectTimedOut>(_onConnectTimedOut);
  }

  final TunnelRepository _tunnel;
  final LocationsRepository _locations;
  final SharedPreferences _prefs;
  bool _initialized = false;
  Timer? _connectTimer;

  @override
  Future<void> close() {
    _connectTimer?.cancel();
    return super.close();
  }

  Future<void> _ensureTunnel() async {
    if (_initialized) return;
    await _tunnel.initialize(
      onStage: (stage) => add(SessionEvent.stageUpdated(stage)),
      onStatus: (d, i, o) =>
          add(SessionEvent.statusUpdated(duration: d, byteIn: i, byteOut: o)),
    );
    _initialized = true;
  }

  Future<void> _onStarted(
    SessionStarted event,
    Emitter<SessionState> emit,
  ) async {
    try {
      await _ensureTunnel();
    } catch (e) {
      emit(state.copyWith(message: e.toString()));
    }

    var locations = event.locations;
    var creds = event.credentials ?? state.credentials;
    try {
      creds ??= await _locations.getCredentials();
      if (locations.isEmpty) {
        locations = await _locations.getLocations();
      }
    } catch (e) {
      emit(
        state.copyWith(
          phase: SessionPhase.failed,
          message: 'Could not load servers. Check your connection.',
        ),
      );
      return;
    }

    VpnLocation? selected = state.selected;
    if (locations.isNotEmpty) {
      final savedId = _prefs.getInt(AppConfig.prefsSelectedServerId);
      selected =
          locations.where((l) => l.id == savedId).firstOrNull ??
          selected ??
          locations.first;
    }

    emit(state.copyWith(selected: selected, credentials: creds, message: null));
  }

  Future<void> _onConnect(
    SessionConnectPressed event,
    Emitter<SessionState> emit,
  ) async {
    try {
      await _ensureTunnel();
    } catch (e) {
      emit(state.copyWith(phase: SessionPhase.failed, message: e.toString()));
      return;
    }

    var location = state.selected;
    var creds = state.credentials;
    if (location == null || creds == null) {
      try {
        creds ??= await _locations.getCredentials();
        if (location == null) {
          final locations = await _locations.getLocations();
          if (locations.isNotEmpty) {
            final savedId = _prefs.getInt(AppConfig.prefsSelectedServerId);
            location =
                locations.where((l) => l.id == savedId).firstOrNull ??
                locations.first;
          }
        }
        emit(state.copyWith(selected: location, credentials: creds));
      } catch (e) {
        emit(state.copyWith(phase: SessionPhase.failed, message: e.toString()));
        return;
      }
    }

    location = state.selected;
    creds = state.credentials;
    if (location == null || creds == null) {
      emit(
        state.copyWith(
          phase: SessionPhase.failed,
          message: 'No server or credentials yet',
        ),
      );
      return;
    }
    if (location.config.trim().isEmpty) {
      emit(
        state.copyWith(
          phase: SessionPhase.failed,
          message: 'This location has no tunnel config.',
        ),
      );
      return;
    }

    emit(state.copyWith(phase: SessionPhase.connecting, message: null));
    try {
      await _tunnel.connect(
        config: location.config,
        country: location.country,
        username: creds.username,
        password: creds.password,
      );
      _armConnectTimeout();
    } catch (e) {
      _connectTimer?.cancel();
      emit(state.copyWith(phase: SessionPhase.failed, message: e.toString()));
    }
  }

  void _armConnectTimeout() {
    _connectTimer?.cancel();
    final seconds = state.credentials?.connectionTimeoutSeconds ?? 30;
    _connectTimer = Timer(Duration(seconds: seconds), () {
      add(const SessionEvent.connectTimedOut());
    });
  }

  Future<void> _onConnectTimedOut(
    SessionConnectTimedOut event,
    Emitter<SessionState> emit,
  ) async {
    if (state.phase != SessionPhase.connecting) return;
    await _tunnel.disconnect();
    if (!state.didRefreshOnFailure) {
      emit(
        state.copyWith(
          didRefreshOnFailure: true,
          message: 'Refreshing servers…',
        ),
      );
      try {
        final creds = await _locations.getCredentials(forceRefresh: true);
        final locs = await _locations.getLocations(forceRefresh: true);
        VpnLocation? selected = state.selected;
        if (locs.isNotEmpty) {
          selected =
              locs.where((l) => l.id == selected?.id).firstOrNull ?? locs.first;
        }
        emit(state.copyWith(credentials: creds, selected: selected));
        add(const SessionEvent.connectPressed());
      } catch (e) {
        emit(state.copyWith(phase: SessionPhase.failed, message: e.toString()));
      }
      return;
    }
    emit(
      state.copyWith(
        phase: SessionPhase.failed,
        message: 'Could not connect. Try another location.',
      ),
    );
  }

  Future<void> _onDisconnect(
    SessionDisconnectPressed event,
    Emitter<SessionState> emit,
  ) async {
    _connectTimer?.cancel();
    await _tunnel.disconnect();
    emit(state.copyWith(phase: SessionPhase.idle, duration: '00:00:00'));
  }

  Future<void> _onServerChosen(
    SessionServerChosen event,
    Emitter<SessionState> emit,
  ) async {
    await _prefs.setInt(AppConfig.prefsSelectedServerId, event.location.id);
    final wasOn =
        state.phase == SessionPhase.protected ||
        state.phase == SessionPhase.connecting;
    if (wasOn) {
      await _tunnel.disconnect();
    }
    emit(state.copyWith(selected: event.location, phase: SessionPhase.idle));
    if (wasOn) {
      add(const SessionEvent.connectPressed());
    }
  }

  void _onStage(SessionStageUpdated event, Emitter<SessionState> emit) {
    final raw = event.stage.toLowerCase();
    if (raw.contains('connected') && !raw.contains('disconnected')) {
      _connectTimer?.cancel();
      emit(
        state.copyWith(
          phase: SessionPhase.protected,
          didRefreshOnFailure: false,
          message: null,
        ),
      );
    } else if (raw.contains('connecting') || raw.contains('wait')) {
      emit(state.copyWith(phase: SessionPhase.connecting));
    } else if (raw.contains('disconnect') || raw.contains('denied')) {
      emit(state.copyWith(phase: SessionPhase.idle));
    }
  }

  void _onStatus(SessionStatusUpdated event, Emitter<SessionState> emit) {
    emit(state.copyWith(duration: event.duration));
  }
}
