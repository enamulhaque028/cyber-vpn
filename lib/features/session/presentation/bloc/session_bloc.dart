import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
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
  SessionBloc(
    this._tunnel,
    this._locations,
    this._prefs, {
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity(),
       super(
         SessionState(
           killSwitchEnabled: _prefs.getBool(AppConfig.prefsKillSwitch) ?? true,
         ),
       ) {
    on<SessionStarted>(_onStarted);
    on<SessionConnectPressed>(_onConnect);
    on<SessionDisconnectPressed>(_onDisconnect);
    on<SessionServerChosen>(_onServerChosen);
    on<SessionStageUpdated>(_onStage);
    on<SessionStatusUpdated>(_onStatus);
    on<SessionConnectTimedOut>(_onConnectTimedOut);
    on<SessionKillSwitchChanged>(_onKillSwitchChanged);
    on<SessionNetworkPathChanged>(_onNetworkPathChanged);
    on<SessionOpenSystemVpnSettings>(_onOpenSystemVpnSettings);
  }

  final TunnelRepository _tunnel;
  final LocationsRepository _locations;
  final SharedPreferences _prefs;
  final Connectivity _connectivity;
  bool _initialized = false;
  bool _intended = false;
  int _reconnectAttempts = 0;
  Timer? _connectTimer;
  Timer? _reconnectTimer;
  StreamSubscription<List<ConnectivityResult>>? _pathSub;

  @override
  Future<void> close() {
    _connectTimer?.cancel();
    _reconnectTimer?.cancel();
    _pathSub?.cancel();
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

  void _listenToPath() {
    _pathSub ??= _connectivity.onConnectivityChanged.listen((_) {
      add(const SessionEvent.networkPathChanged());
    });
  }

  Future<void> _onStarted(
    SessionStarted event,
    Emitter<SessionState> emit,
  ) async {
    _listenToPath();
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
    _intended = true;
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

    emit(
      state.copyWith(
        phase: SessionPhase.connecting,
        reconnecting: _reconnectAttempts > 0,
        message: _reconnectAttempts > 0 ? 'Reconnecting…' : null,
      ),
    );
    try {
      await _tunnel.connect(
        config: location.config,
        country: location.country,
        username: creds.username,
        password: creds.password,
        killSwitch: state.killSwitchEnabled,
      );
      _armConnectTimeout();
    } catch (e) {
      _connectTimer?.cancel();
      emit(state.copyWith(phase: SessionPhase.failed, message: e.toString()));
      _scheduleReconnect();
    }
  }

  void _armConnectTimeout() {
    _connectTimer?.cancel();
    final seconds = state.credentials?.connectionTimeoutSeconds ?? 30;
    _connectTimer = Timer(Duration(seconds: seconds), () {
      add(const SessionEvent.connectTimedOut());
    });
  }

  void _scheduleReconnect() {
    if (!_intended) return;
    _reconnectTimer?.cancel();
    if (_reconnectAttempts >= 5) {
      return;
    }
    final delaySeconds = min(8, 1 << _reconnectAttempts);
    _reconnectAttempts++;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (_intended) add(const SessionEvent.connectPressed());
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
        reconnecting: false,
        message: 'Could not connect. Try another location.',
      ),
    );
    _scheduleReconnect();
  }

  Future<void> _onDisconnect(
    SessionDisconnectPressed event,
    Emitter<SessionState> emit,
  ) async {
    _intended = false;
    _reconnectAttempts = 0;
    _connectTimer?.cancel();
    _reconnectTimer?.cancel();
    await _tunnel.disconnect();
    emit(
      state.copyWith(
        phase: SessionPhase.idle,
        duration: '00:00:00',
        reconnecting: false,
        message: null,
      ),
    );
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

  Future<void> _onKillSwitchChanged(
    SessionKillSwitchChanged event,
    Emitter<SessionState> emit,
  ) async {
    await _prefs.setBool(AppConfig.prefsKillSwitch, event.enabled);
    emit(state.copyWith(killSwitchEnabled: event.enabled));
    if (_intended &&
        (state.phase == SessionPhase.protected ||
            state.phase == SessionPhase.connecting)) {
      await _tunnel.disconnect();
      add(const SessionEvent.connectPressed());
    }
  }

  void _onNetworkPathChanged(
    SessionNetworkPathChanged event,
    Emitter<SessionState> emit,
  ) {
    if (!_intended) return;
    if (state.phase == SessionPhase.protected) return;
    if (state.phase == SessionPhase.connecting) return;
    _scheduleReconnect();
  }

  Future<void> _onOpenSystemVpnSettings(
    SessionOpenSystemVpnSettings event,
    Emitter<SessionState> emit,
  ) async {
    try {
      await _tunnel.openSystemVpnSettings();
    } catch (e) {
      emit(
        state.copyWith(
          message:
              'Open Settings → Network & internet → VPN. Enable Always-on and Block connections without VPN.',
        ),
      );
    }
  }

  void _onStage(SessionStageUpdated event, Emitter<SessionState> emit) {
    final raw = event.stage.toLowerCase();
    if (raw.contains('connected') && !raw.contains('disconnected')) {
      _connectTimer?.cancel();
      _reconnectTimer?.cancel();
      _reconnectAttempts = 0;
      emit(
        state.copyWith(
          phase: SessionPhase.protected,
          didRefreshOnFailure: false,
          reconnecting: false,
          message: null,
        ),
      );
    } else if (raw.contains('reconnect')) {
      emit(
        state.copyWith(
          phase: SessionPhase.connecting,
          reconnecting: true,
          message: 'Reconnecting…',
        ),
      );
    } else if (raw.contains('connecting') || raw.contains('wait')) {
      emit(state.copyWith(phase: SessionPhase.connecting));
    } else if (raw.contains('denied')) {
      _intended = false;
      _reconnectTimer?.cancel();
      emit(state.copyWith(phase: SessionPhase.idle, reconnecting: false));
    } else if (raw.contains('disconnect') ||
        raw.contains('error') ||
        raw.contains('exit')) {
      if (!_intended) {
        emit(
          state.copyWith(
            phase: SessionPhase.idle,
            reconnecting: false,
            duration: '00:00:00',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          phase: SessionPhase.connecting,
          reconnecting: true,
          message: state.killSwitchEnabled
              ? 'Tunnel dropped. Reconnecting…'
              : 'Reconnecting…',
        ),
      );
      _scheduleReconnect();
    }
  }

  void _onStatus(SessionStatusUpdated event, Emitter<SessionState> emit) {
    emit(state.copyWith(duration: event.duration));
  }
}
